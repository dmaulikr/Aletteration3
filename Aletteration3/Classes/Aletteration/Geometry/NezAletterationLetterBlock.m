//
//  NezAletterationLetterBlock.m
//  Aletteration3
//
//  Created by David Nesbitt on 2013-09-21.
//  Copyright (c) 2013 David Nesbitt. All rights reserved.
//

#import "NezAletterationLetterBlock.h"
#import "NezAletterationAppDelegate.h"
#import "NezAletterationGraphics.h"
#import "NezInstanceVertexArrayObjectLitColor.h"
#import "NezInstanceVertexArrayObjectLitColorTintTexture.h"

@interface NezAletterationLetterBlock() {
	NezInstanceVertexArrayObjectLitColor *_blockVao;
	NSInteger _blockAttributeIndex;
	NezInstanceAttributeColor *_blockAttributePtr;
	
	NezInstanceVertexArrayObjectLitColorTintTexture *_letterVao;
	NSInteger _letterAttributeIndex;
	NezInstanceAttributeColorTintTexture *_letterAttributePtr;
	
	float _luma;
}

@end

@implementation NezAletterationLetterBlock

-(instancetype)initWithBlockVao:(NezInstanceVertexArrayObjectLitColor*)blockVao blockAttributeIndex:(NSInteger)blockAttributeIndex letterVao:(NezInstanceVertexArrayObjectLitColorTintTexture*)letterVao letterAttributeIndex:(NSInteger)letterAttributeIndex {
	if ((self = [super init])) {
		_blockVao = blockVao;
		_blockAttributeIndex = blockAttributeIndex;
		_blockAttributePtr = _blockVao.instanceAttributeList+_blockAttributeIndex;

		_letterVao = letterVao;
		_letterAttributeIndex = letterAttributeIndex;
		_letterAttributePtr = _letterVao.instanceAttributeList+_letterAttributeIndex;

		_dimensions = [NezAletterationAppDelegate sharedAppDelegate].graphics.letterBlockDimensions;
		
		_index = -1;
		
		_isLowercase = NO;
	}
	return self;
}

-(void)encodeRestorableStateWithCoder:(NSCoder*)coder {
	[super encodeRestorableStateWithCoder:coder];
	
	[coder encodeInteger:_index forKey:@"_index"];
	[coder encodeInteger:_letter forKey:@"_letter"];

	[coder encodeObject:_blockVao forKey:@"_blockVao"];
	[coder encodeInteger:_blockAttributeIndex forKey:@"_blockAttributeIndex"];

	[coder encodeObject:_letterVao forKey:@"_letterVao"];
	[coder encodeInteger:_letterAttributeIndex forKey:@"_letterAttributeIndex"];

	[coder encodeBool:_isLowercase forKey:@"_isLowercase"];
}

-(void)decodeRestorableStateWithCoder:(NSCoder*)coder {
	[super decodeRestorableStateWithCoder:coder];

	_index = [coder decodeIntegerForKey:@"_index"];
	_letter = (char)[coder decodeIntegerForKey:@"_letter"];

	_blockVao = [coder decodeObjectForKey:@"_blockVao"];
	_blockAttributeIndex = [coder decodeIntegerForKey:@"_blockAttributeIndex"];

	_letterVao = [coder decodeObjectForKey:@"_letterVao"];;
	_letterAttributeIndex = [coder decodeIntegerForKey:@"_letterAttributeIndex"];

	_isLowercase = [coder decodeBoolForKey:@"_isLowercase"];
}

-(void)applicationFinishedRestoringState {
	_blockAttributePtr = _blockVao.instanceAttributeList+_blockAttributeIndex;
	_letterAttributePtr = _letterVao.instanceAttributeList+_letterAttributeIndex;
}

-(void)setLetter:(char)letter {
	if (_letter != letter) {
		_letter = letter;
		[self setUV];
	}
}

-(BOOL)getIsBonus {
	return _letter == 'z' || _letter == 'j' || _letter == 'q' || _letter == 'x';
}

-(GLKVector4)getColor {
	return _blockAttributePtr->color;
}

-(void)setColor:(GLKVector4)color {
	_blockAttributePtr->color = color;
	_letterAttributePtr->color = color;
	_luma = [NezAletterationGraphics getLuma:color];
	if (_luma > 0.5) {
		_letterAttributePtr->tint = GLKVector4Make(0.0f, 0.0f, 0.0f, 1.0f);
	} else {
		_letterAttributePtr->tint = GLKVector4Make(1.0f, 1.0f, 1.0f, 1.0f);
	}
}

-(void)setIsLowercase:(BOOL)isLowercase {
	_isLowercase = isLowercase;
	[self setUV];
}

-(void)setUV {
	int index = _letter-'a';
	int x = index%8;
	int y = 8-index/8;

	if (_isLowercase) {
		y -= 4;
	}
	float s = ((float)x)/8.0;
	float t = ((float)y)/8.0;
	float p = ((float)x+1)/8.0;
	float q = ((float)y-1)/8.0;

	_letterAttributePtr->uv0 = GLKVector2Make(p, t);
	_letterAttributePtr->uv1 = GLKVector2Make(s, t);
	_letterAttributePtr->uv2 = GLKVector2Make(s, q);
	_letterAttributePtr->uv3 = GLKVector2Make(p, q);
}

-(void)setCenter:(GLKVector3)center {
	[super setCenter:center];
	_blockAttributePtr->matrix = _modelMatrix;
	_letterAttributePtr->matrix = _modelMatrix;
}

-(void)setModelMatrix:(GLKMatrix4)modelMatrix {
	_blockAttributePtr->matrix = modelMatrix;
	_letterAttributePtr->matrix = modelMatrix;
	[super setModelMatrix:modelMatrix];
}

-(NSString*)description {
	return [NSString stringWithFormat:@"NezAletterationLetterBlock[%ld]:%c", (long)_index, _letter];
}

@end
