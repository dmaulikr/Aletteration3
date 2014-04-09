//
//  NezInstanceAttributeBufferObjectColor.h
//  Aletteration3
//
//  Created by David Nesbitt on 2013/12/19.
//  Copyright (c) 2013 David Nesbitt. All rights reserved.
//

#import "NezInstanceAttributeBufferObject.h"

@interface NezInstanceAttributeBufferObjectColor : NezInstanceAttributeBufferObject

@property (readonly, getter = getInstanceAttributeList) NezInstanceAttributeColor *instanceAttributeList;

@end
