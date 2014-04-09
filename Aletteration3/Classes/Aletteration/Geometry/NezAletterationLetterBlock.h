//
//  NezAletterationLetterBlock.h
//  Aletteration3
//
//  Created by David Nesbitt on 2013-09-21.
//  Copyright (c) 2013 David Nesbitt. All rights reserved.
//

#import "NezAletterationRestorableGeometry.h"
#import "NezInstanceAttributeTypes.h"

@class NezInstanceVertexArrayObjectLitColor;
@class NezInstanceVertexArrayObjectLitColorTintTexture;

@interface NezAletterationLetterBlock : NezAletterationRestorableGeometry

@property NSInteger index;
@property (nonatomic, setter = setLetter:) char letter;
@property (getter = getColor, setter = setColor:) GLKVector4 color;
@property (nonatomic, setter = setIsLowercase:) BOOL isLowercase;
@property (readonly, getter = getIsBonus) BOOL isBonus;

-(instancetype)initWithBlockVao:(NezInstanceVertexArrayObjectLitColor*)blockVao blockAttributeIndex:(NSInteger)blockAttributeIndex letterVao:(NezInstanceVertexArrayObjectLitColorTintTexture*)letterVao letterAttributeIndex:(NSInteger)letterAttributeIndex;

@end
