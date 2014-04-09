//
//  NezAletterationRetiredWord.m
//  Aletteration3
//
//  Created by David Nesbitt on 2013/10/09.
//  Copyright (c) 2013 David Nesbitt. All rights reserved.
//

#import "NezAletterationRetiredWord.h"
#import "NezAletterationGameStateRetiredWord.h"
#import "NezAletterationLetterBlock.h"

@interface NezAletterationRetiredWord() {
	NSMutableArray *_letterBlockRestoreList;
}

@end

@implementation NezAletterationRetiredWord

-(instancetype)initWithGameStateRetiredWord:(NezAletterationGameStateRetiredWord*)retiredWord turnIndex:(NSInteger)turnIndex andLetterBlockList:(NSArray*)letterBlockList {
	if ((self = [super init])) {
		_retiredWord = retiredWord;
		_letterBlockList = letterBlockList;
		_letterBlockRestoreList = nil;
		_turnIndex = turnIndex;
		
		[self setupMatrix];
	}
	return self;
}

-(void)encodeWithCoder:(NSCoder*)coder {
	_letterBlockRestoreList = [NSMutableArray arrayWithCapacity:_letterBlockList.count];
	for (NezAletterationLetterBlock *letterBlock in _letterBlockList) {
		[_letterBlockRestoreList addObject:[NSNumber numberWithInteger:letterBlock.index]];
	}
	[coder encodeObject:_retiredWord forKey:@"_retiredWord"];
	[coder encodeObject:_letterBlockRestoreList forKey:@"_letterBlockRestoreList"];
	[coder encodeInteger:_turnIndex forKey:@"_turnIndex"];
}

-(instancetype)initWithCoder:(NSCoder*)coder {
	if ((self = [super init])) {
		_retiredWord = [coder decodeObjectForKey:@"_retiredWord"];
		_letterBlockRestoreList = [coder decodeObjectForKey:@"_letterBlockRestoreList"];
		_turnIndex = [coder decodeIntegerForKey:@"_turnIndex"];
	}
	return self;
}

-(void)setupMatrix {
	NezAletterationLetterBlock *letterBlock = _letterBlockList.firstObject;
	
	self.modelMatrix = letterBlock.modelMatrix;
	_dimensions = letterBlock.dimensions;
	_dimensions.x *= _letterBlockList.count;
}

-(void)restoreLetterBlockListWithLetterBlockList:(NSArray*)gameBoardLetterBlockList {
	if (_letterBlockRestoreList) {
		NSMutableArray *letterBlockList = [NSMutableArray arrayWithCapacity:_letterBlockRestoreList.count];
		for (NSNumber *index in _letterBlockRestoreList) {
			[letterBlockList addObject:gameBoardLetterBlockList[[index integerValue]]];
		}
		_letterBlockList = [NSArray arrayWithArray:letterBlockList];
		_letterBlockRestoreList = nil;
	}
}

-(void)setModelMatrix:(GLKMatrix4)modelMatrix {
	[super setModelMatrix:modelMatrix];
	for (NezAletterationLetterBlock *letterBlock in self.letterBlockList) {
		letterBlock.modelMatrix = modelMatrix;
		modelMatrix = GLKMatrix4Translate(modelMatrix, letterBlock.dimensions.x, 0.0f, 0.0);
	}
}

-(NSInteger)getBonusLetterCount {
	NSInteger count = 0;
	for (NezAletterationLetterBlock *letterBlock in self.letterBlockList) {
		if (letterBlock.isBonus) {
			count++;
		}
	}
	return count;
}


@end
