//
//  NezAletterationLetterGroup.m
//  Aletteration3
//
//  Created by David Nesbitt on 2013/10/25.
//  Copyright (c) 2013 David Nesbitt. All rights reserved.
//

#import "NezAletterationLetterGroup.h"
#import "NezAletterationAppDelegate.h"
#import "NezAletterationGraphics.h"
#import "NezAletterationLetterBlock.h"

@implementation NezAletterationLetterGroup

-(instancetype)initWithLetter:(char)letter {
	if ((self=[super init])) {
		_letter = letter;
		_letterBlockList = [NSMutableArray array];
		[self calculateDimensions];

	}
	return self;
}

-(void)encodeRestorableStateWithCoder:(NSCoder*)coder {
	[super encodeRestorableStateWithCoder:coder];
	
	[coder encodeInteger:_letter forKey:@"_letter"];
	[coder encodeObject:_letterBlockList forKey:@"_letterBlockList"];
	[coder encodeFloat:_offset.x forKey:@"_offset.x"];
	[coder encodeFloat:_offset.y forKey:@"_offset.y"];
	[coder encodeFloat:_offset.z forKey:@"_offset.z"];
}

-(void)decodeRestorableStateWithCoder:(NSCoder*)coder {
	[super decodeRestorableStateWithCoder:coder];
	
	_letter = (char)[coder decodeIntegerForKey:@"_letter"];
	_letterBlockList = [coder decodeObjectForKey:@"_letterBlockList"];
	_offset.x = [coder decodeFloatForKey:@"_offset.x"];
	_offset.y = [coder decodeFloatForKey:@"_offset.y"];
	_offset.z = [coder decodeFloatForKey:@"_offset.z"];
}

-(NSInteger)getCount {
	return _letterBlockList.count;
}

-(GLKMatrix4)nextModelMatrix {
	return [self modelMatrixForIndex:_letterBlockList.count];
}

-(GLKMatrix4)topModelMatrix {
	if (_letterBlockList.count > 0) {
		return [self modelMatrixForIndex:_letterBlockList.count-1];
	}
	return [self modelMatrixForIndex:0];
}

-(GLKMatrix4)modelMatrixForIndex:(NSInteger)index {
	GLKVector3 blockDimensions = [NezAletterationAppDelegate sharedAppDelegate].graphics.letterBlockDimensions;
	return GLKMatrix4Translate(_modelMatrix, 0.0f, 0.0f, blockDimensions.z/2.0f+(blockDimensions.z*index));
}

-(NezAletterationLetterBlock*)pop {
	if (self.count > 0) {
		NezAletterationLetterBlock *letterBlock = _letterBlockList.lastObject;
		[_letterBlockList removeLastObject];
		[self calculateDimensions];
		return letterBlock;
	}
	return nil;
}

-(void)push:(NezAletterationLetterBlock*)letterBlock {
	[_letterBlockList addObject:letterBlock];
	[self calculateDimensions];
}

-(void)removeAllLetterBlocks {
	[_letterBlockList removeAllObjects];
	[self calculateDimensions];
}

-(void)setModelMatrix:(GLKMatrix4)modelMatrix {
	GLKVector3 blockDimensions = [NezAletterationAppDelegate sharedAppDelegate].graphics.letterBlockDimensions;
	GLKMatrix4 m = GLKMatrix4Translate(modelMatrix, 0.0f, 0.0f, blockDimensions.z/2.0f);
	for (NezAletterationLetterBlock *letterBlock in _letterBlockList) {
		letterBlock.modelMatrix = m;
		m = GLKMatrix4Translate(m, 0.0f, 0.0f, blockDimensions.z);
	}
	[super setModelMatrix:modelMatrix];
}

-(void)calculateDimensions {
	_dimensions = [NezAletterationAppDelegate sharedAppDelegate].graphics.letterBlockDimensions;
	_dimensions.z *= self.count;
}

@end
