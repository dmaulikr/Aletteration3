//
//  NezAletterationLid.h
//  Aletteration3
//
//  Created by David Nesbitt on 2013/10/23.
//  Copyright (c) 2013 David Nesbitt. All rights reserved.
//

#import "NezAletterationRestorableGeometry.h"

@class NezInstanceAttributeBufferObjectColor;

@interface NezAletterationLid : NezAletterationRestorableGeometry

@property (getter = getColor, setter = setColor:) GLKVector4 color;

-(instancetype)initWithInstanceAbo:(NezInstanceAttributeBufferObjectColor*)instanceAbo index:(NSInteger)instanceAttributeIndex andDimensions:(GLKVector3)dimensions;

@end
