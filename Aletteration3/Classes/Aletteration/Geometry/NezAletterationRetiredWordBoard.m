//
//  NezAletterationScoreboard.m
//  Aletteration3
//
//  Created by David Nesbitt on 2013/10/09.
//  Copyright (c) 2013 David Nesbitt. All rights reserved.
//

#import "NezAletterationRetiredWordBoard.h"
#import "NezAletterationAppDelegate.h"
#import "NezAletterationGraphics.h"
#import "NezAletterationRetiredWord.h"
#import "NezAletterationLetterBlock.h"

typedef struct {
	GLKMatrix4 originalMatrix;
	GLKMatrix4 firstWordMatrix;
	float originalWidth;
	float originalHeight;
	float spaceMultiplier;
} NezAletterationRetiredWordBoardStruct;

@interface NezAletterationRetiredWordBoard() {
	NSMutableArray *_retiredWordList;
	float _originalWidth;
	float _originalHeight;
}

@end

@implementation NezAletterationRetiredWordBoard

-(instancetype)initWithWidth:(float)width andHeight:(float)height {
	if ((self = [super init])) {
		_retiredWordList = [NSMutableArray array];
		_spaceMultiplier = 1.0f;
		_originalWidth = width;
		_originalHeight = height;
		[self resetDimensions];
	}
	return self;
}

-(void)encodeWithCoder:(NSCoder*)coder {
	NezAletterationRetiredWordBoardStruct retiredWordBoard;
	retiredWordBoard.originalMatrix = _originalMatrix;
	retiredWordBoard.firstWordMatrix = _firstWordMatrix;
	retiredWordBoard.originalWidth = _originalWidth;
	retiredWordBoard.originalHeight = _originalHeight;
	retiredWordBoard.spaceMultiplier = _spaceMultiplier;
	
	NSData *retiredWordBoardData = [NSData dataWithBytes:&retiredWordBoard length:sizeof(NezAletterationRetiredWordBoardStruct)];
	[coder encodeObject:retiredWordBoardData forKey:@"retiredWordBoardData"];
	[coder encodeObject:_retiredWordList forKey:@"_retiredWordList"];
}

-(instancetype)initWithCoder:(NSCoder *)coder {
	if ((self = [super init])) {
		NSData *retiredWordBoardData = [coder decodeObjectForKey:@"retiredWordBoardData"];
		
		NezAletterationRetiredWordBoardStruct *retiredWordBoard = (NezAletterationRetiredWordBoardStruct*)retiredWordBoardData.bytes;

		_retiredWordList = [coder decodeObjectForKey:@"_retiredWordList"];
		_spaceMultiplier = retiredWordBoard->spaceMultiplier;
		_originalWidth = retiredWordBoard->originalWidth;
		_originalHeight = retiredWordBoard->originalHeight;
		_originalMatrix = retiredWordBoard->originalMatrix;
		_firstWordMatrix = retiredWordBoard->firstWordMatrix;
		[self resetDimensions];
	}
	return self;
}

-(void)restoreRetiredWordsWithLetterBlockList:(NSArray*)letterBlockList {
	for (NezAletterationRetiredWord *retiredWord in _retiredWordList) {
		[retiredWord restoreLetterBlockListWithLetterBlockList:letterBlockList];
	}
	[self resetDimensions];
}

-(void)resetDimensions {
	GLKVector3 letterBlockDimensions = [NezAletterationAppDelegate sharedAppDelegate].graphics.letterBlockDimensions;
	_dimensions = GLKVector3Make(_originalWidth, letterBlockDimensions.y, letterBlockDimensions.z);
	if (_retiredWordList.count > 1) {
		_dimensions.y += (letterBlockDimensions.y*(_retiredWordList.count-1)*_spaceMultiplier);
	}
	if (_dimensions.y < _originalHeight) {
		_dimensions.y = _originalHeight;
	}
	for (NezAletterationRetiredWord *retiredWord in _retiredWordList) {
		if (_dimensions.x < retiredWord.dimensions.x) {
			_dimensions.x  = retiredWord.dimensions.x;
		}
	}
	self.modelMatrix = GLKMatrix4Translate(self.originalMatrix, (_dimensions.x-_originalWidth), -(_dimensions.y-_originalHeight)/2.0, 0.0);
}

-(void)resetAllWordMatrices {
	[_retiredWordList enumerateObjectsWithOptions:NSEnumerationReverse usingBlock:^(NezAletterationRetiredWord *retiredWord, NSUInteger idx, BOOL *stop) {
		retiredWord.modelMatrix = [self wordMatrixForIndex:idx];
	}];
}

-(void)addRetiredWord:(NezAletterationRetiredWord*)retiredWord {
	retiredWord.modelMatrix = [self nextWordMatrix];
	[_retiredWordList addObject:retiredWord];
	[self resetDimensions];
}

-(NSMutableArray*)removeRetiredWordsForTurnIndex:(NSInteger)turnIndex {
	NSMutableArray *removedWordList = [NSMutableArray array];
	[_retiredWordList enumerateObjectsWithOptions:NSEnumerationReverse usingBlock:^(NezAletterationRetiredWord *retiredWord, NSUInteger idx, BOOL *stop) {
		if (turnIndex != retiredWord.turnIndex) {
			*stop = YES;
		} else {
			[removedWordList addObject:retiredWord];
		}
	}];
	[_retiredWordList removeObjectsInArray:removedWordList];
	[self resetDimensions];
	return removedWordList;
}

-(void)setFirstWordMatrix:(GLKMatrix4)firstWordMatrix {
	_firstWordMatrix = firstWordMatrix;
	[self resetAllWordMatrices];
}

-(void)setOriginalMatrix:(GLKMatrix4)originalMatrix {
	_originalMatrix = originalMatrix;
	self.modelMatrix = originalMatrix;
	[self resetDimensions];
}

-(GLKMatrix4)nextWordMatrix {
	return [self wordMatrixForIndex:_retiredWordList.count];
}

-(GLKMatrix4)wordMatrixForIndex:(NSInteger)index {
	GLKVector3 letterBlockDimensions = [NezAletterationAppDelegate sharedAppDelegate].graphics.letterBlockDimensions;
	return GLKMatrix4Translate(self.firstWordMatrix, 0.0f, -letterBlockDimensions.y*index*_spaceMultiplier, letterBlockDimensions.z/2.0f);
}

@end