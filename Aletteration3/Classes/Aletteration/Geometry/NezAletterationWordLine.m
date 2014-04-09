//
//  NezAletterationLetterLine.m
//  Aletteration3
//
//  Created by David Nesbitt on 2013-09-23.
//  Copyright (c) 2013 David Nesbitt. All rights reserved.
//

#import "NezAletterationWordLine.h"
#import "NezAletterationAppDelegate.h"
#import "NezAletterationGraphics.h"
#import "NezAletterationLetterBlock.h"
#import "NezAletterationGameStateLineState.h"
#import "NezAletterationSQLiteDictionary.h"
#import "NezAnimation.h"
#import "NezAnimator.h"
#import "NezRay.h"
#import "NezInstanceVertexArrayObjectColor.h"

@interface NezAletterationWordLine() {
	NezInstanceVertexArrayObjectColor *_lineVao;
	NSInteger _lineAttributeIndex;
	NezInstanceAttributeColor *_lineAttributePtr;
	
	NSMutableArray *_letterBlockList;
	NSInteger _junkOffset;

	NezAnimation *_selectAnimation;
	NezAnimation *_deselectAnimation;
	
	GLKVector3 _v1;
	GLKVector3 _v2;
	GLKVector3 _v3;
	GLKVector3 _v4;
}

@end

typedef struct {
	GLKVector4 defaultColor;
	GLKVector4 selectedColor;
	GLKVector3 v1;
	GLKVector3 v2;
	GLKVector3 v3;
	GLKVector3 v4;
	NSInteger lineAttributeIndex;
	NSInteger lineIndex;
	NSInteger junkOffset;
} NezAletterationWordLineStruct;

@implementation NezAletterationWordLine

-(instancetype)initWithLineVao:(NezInstanceVertexArrayObjectColor*)lineVao lineAttributeIndex:(NSInteger)lineAttributeIndex {
	if ((self = [super init])) {
		_lineVao = lineVao;
		_lineAttributeIndex = lineAttributeIndex;
		_lineAttributePtr = _lineVao.instanceAttributeList+_lineAttributeIndex;
		
		_letterBlockList = [NSMutableArray array];
		_dimensions = [NezAletterationAppDelegate sharedAppDelegate].graphics.wordLineDimensions;
	}
	return self;
}

-(void)encodeRestorableStateWithCoder:(NSCoder*)coder {
	[super encodeRestorableStateWithCoder:coder];

	NezAletterationWordLineStruct wordLineStruct;
	wordLineStruct.defaultColor = _defaultColor;
	wordLineStruct.selectedColor = _selectedColor;
	wordLineStruct.v1 = _v1;
	wordLineStruct.v2 = _v2;
	wordLineStruct.v3 = _v3;
	wordLineStruct.v4 = _v4;
	wordLineStruct.lineAttributeIndex = _lineAttributeIndex;
	wordLineStruct.lineIndex = _lineIndex;
	wordLineStruct.junkOffset = _junkOffset;
	NSData *wordLineData = [NSData dataWithBytes:&wordLineStruct length:sizeof(wordLineStruct)];
	[coder encodeObject:wordLineData forKey:@"wordLineData"];

	[coder encodeObject:_lineVao forKey:@"_lineVao"];
	[coder encodeObject:_letterBlockList forKey:@"_letterBlockList"];
}

-(void)decodeRestorableStateWithCoder:(NSCoder*)coder {
	[super decodeRestorableStateWithCoder:coder];
	
	NSData *wordLineData = [coder decodeObjectForKey:@"wordLineData"];
	NezAletterationWordLineStruct *wordLineStructPtr = (NezAletterationWordLineStruct*)wordLineData.bytes;
	_defaultColor = wordLineStructPtr->defaultColor;
	_selectedColor = wordLineStructPtr->selectedColor;
	_v1 = wordLineStructPtr->v1;
	_v2 = wordLineStructPtr->v2;
	_v3 = wordLineStructPtr->v3;
	_v4 = wordLineStructPtr->v4;
	_lineAttributeIndex = wordLineStructPtr->lineAttributeIndex;
	_lineIndex = wordLineStructPtr->lineIndex;
	_junkOffset = wordLineStructPtr->junkOffset;

	_lineVao = [coder decodeObjectForKey:@"_lineVao"];
	_letterBlockList = [coder decodeObjectForKey:@"_letterBlockList"];
}

-(void)applicationFinishedRestoringState {
	_dimensions = [NezAletterationAppDelegate sharedAppDelegate].graphics.wordLineDimensions;
	_lineAttributePtr = _lineVao.instanceAttributeList+_lineAttributeIndex;
}

-(void)setModelMatrix:(GLKMatrix4)modelMatrix {
	_lineAttributePtr->matrix = modelMatrix;
	[super setModelMatrix:modelMatrix];

	GLKVector3 center = self.center;
	float hw = _dimensions.x*0.5;
	float hh = _dimensions.y*0.5;
	GLKQuaternion orientation = self.orientation;
	_v1 = GLKVector3Add(GLKQuaternionRotateVector3(orientation, GLKVector3Make(-hw, -hh, 0.0f)), center);
	_v2 = GLKVector3Add(GLKQuaternionRotateVector3(orientation, GLKVector3Make( hw, -hh, 0.0f)), center);
	_v3 = GLKVector3Add(GLKQuaternionRotateVector3(orientation, GLKVector3Make( hw,  hh, 0.0f)), center);
	_v4 = GLKVector3Add(GLKQuaternionRotateVector3(orientation, GLKVector3Make(-hw,  hh, 0.0f)), center);
}

-(void)setColor:(GLKVector4)color {
	_lineAttributePtr->color = color;
}

-(GLKVector4)getColor {
	return _lineAttributePtr->color;
}

-(BOOL)intersect:(NezRay*)ray {
	if ([ray intersectsTriangleV0:_v3 V1:_v4 V2:_v1]) {
		return YES;
	}
	if ([ray intersectsTriangleV0:_v2 V1:_v3 V2:_v1]) {
		return YES;
	}
	return NO;
}

-(GLKMatrix4)nextLetterBlockMatrix {
	return [self letterBlockMatrixForIndex:_letterBlockList.count];
}

-(GLKMatrix4)letterBlockMatrixForIndex:(NSInteger)index {
	GLKVector3 letterBlockDimensions = [NezAletterationAppDelegate sharedAppDelegate].graphics.letterBlockDimensions;
	float blockX = letterBlockDimensions.x;
	return GLKMatrix4Translate(_modelMatrix, -_dimensions.x/2.0+blockX/2.0+blockX*index-blockX*_junkOffset, 0.0, letterBlockDimensions.z/2.0);
}

-(void)addLetterBlock:(NezAletterationLetterBlock*)letterBlock {
	[_letterBlockList addObject:letterBlock];
}

-(void)addLetterBlocks:(NSArray*)letterBlockList {
	[_letterBlockList addObjectsFromArray:letterBlockList];
}

-(void)setupBlocksForState:(NezAletterationGameStateLineState*)lineState isAnimated:(BOOL)isAnimated {
	GLKVector4 blockColor = self.color;
	blockColor.a = 1.0;
	
	GLKVector4 junkColor = {
		0.85, 0.85, 0.85, 1.0
	};
	
	for (NSInteger idx=0; idx<_letterBlockList.count; idx++) {
		NezAletterationLetterBlock *letterBlock = _letterBlockList[idx];
//	[_letterBlockList enumerateObjectsUsingBlock:^(NezAletterationLetterBlock *letterBlock, NSUInteger idx, BOOL *stop) {
		GLKVector4 color;
		if (idx < lineState.index) {
			color = junkColor;
		} else {
			if (lineState.state == NEZ_DIC_INPUT_ISPREFIX || lineState.state == NEZ_DIC_INPUT_ISWORD || lineState.state == NEZ_DIC_INPUT_ISBOTH) {
				color = blockColor;
			} else {
				color = junkColor;
			}
		}
		if (isAnimated) {
			[NezAnimator animateVec4WithFromData:letterBlock.color ToData:color Duration:0.25 EasingFunction:easeInOutCubic UpdateBlock:^(NezAnimation *ani) {
				letterBlock.color = (*(GLKVector4*)ani.newData);
			} DidStopBlock:^(NezAnimation *ani) {
			}];
		} else {
			letterBlock.color = color;
		}
	}
	if (lineState.index != _junkOffset) {
		if (isAnimated) {
			[self slideJunkToOffset:lineState.index];
		} else {
			_junkOffset = lineState.index;
			[self setAllBlockMatrices];
		}
	}
}

-(void)slideJunkToOffset:(NSInteger)junkOffset {
	GLKMatrix4 fromMatrix = [self letterBlockMatrixForIndex:0];
	float dJunk = fabs(_junkOffset-junkOffset);
	_junkOffset = junkOffset;
	GLKMatrix4 toMatrix = [self letterBlockMatrixForIndex:0];
	
	[NezAnimator animateMat4WithFromData:fromMatrix ToData:toMatrix Duration:0.15*dJunk EasingFunction:easeInOutCubic UpdateBlock:^(NezAnimation *ani) {
		[self setAllBlockMatrices:(*(GLKMatrix4*)ani.newData)];
	} DidStopBlock:^(NezAnimation *ani) {
	}];
}

-(void)setAllBlockMatrices {
	[self setAllBlockMatrices:[self letterBlockMatrixForIndex:0]];
}

-(void)setAllBlockMatrices:(GLKMatrix4)matrix {
	GLKVector3 letterBlockDimensions = [NezAletterationAppDelegate sharedAppDelegate].graphics.letterBlockDimensions;
	NSInteger stackCount = _junkOffset-14;
	if (stackCount > 0) {
		matrix = GLKMatrix4Translate(matrix, letterBlockDimensions.x*stackCount, 0.0f, letterBlockDimensions.z*stackCount);
	}
	for (NezAletterationLetterBlock *letterBlock in _letterBlockList) {
		if (stackCount > 0) {
			letterBlock.modelMatrix = matrix;
			matrix = GLKMatrix4Translate(matrix, 0.0f, 0.0f, -letterBlockDimensions.z);
			stackCount--;
		} else {
			letterBlock.modelMatrix = matrix;
			matrix = GLKMatrix4Translate(matrix, letterBlockDimensions.x, 0.0f, 0.0f);
		}
	};
}

-(NSArray*)removeBlocksInRange:(NSRange)range {
	NSArray *blockList = [NSMutableArray array];
	blockList = [_letterBlockList subarrayWithRange:range];
	[_letterBlockList removeObjectsInRange:range];
	return blockList;
}

-(NezAletterationLetterBlock*)removeLastLetterBlock {
	if (_letterBlockList.count > 0) {
		NezAletterationLetterBlock *letterBlock = _letterBlockList.lastObject;
		[_letterBlockList removeLastObject];
		return letterBlock;
	}
	return nil;
}

-(void)removeAllLetterBlocks {
	[_letterBlockList removeAllObjects];
	_junkOffset = 0;
}

-(void)animateSelected {
	if (_selectAnimation) {
		return;
	}
	if (_deselectAnimation) {
		[NezAnimator removeAnimation:_deselectAnimation];
		_deselectAnimation = nil;
	}
	_selectAnimation = [NezAnimator animateVec4WithFromData:self.color ToData:self.selectedColor Duration:0.25 EasingFunction:easeLinear UpdateBlock:^(NezAnimation *ani) {
		self.color = (*(GLKVector4*)ani.newData);
	} DidStopBlock:^(NezAnimation *ani) {
		_selectAnimation = nil;
	}];
}

-(void)animateDeselected {
	if (_deselectAnimation) {
		return;
	}
	if (_selectAnimation) {
		[NezAnimator removeAnimation:_selectAnimation];
		_selectAnimation = nil;
	}
	_deselectAnimation = [NezAnimator animateVec4WithFromData:self.color ToData:self.defaultColor Duration:0.25 EasingFunction:easeLinear UpdateBlock:^(NezAnimation *ani) {
		self.color = (*(GLKVector4*)ani.newData);
	} DidStopBlock:^(NezAnimation *ani) {
		_deselectAnimation = nil;
	}];
}

@end
