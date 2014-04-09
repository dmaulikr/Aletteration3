//
//  NezInstanceAttributeBufferObjectColorTexture.h
//  Aletteration3
//
//  Created by David Nesbitt on 2013/12/19.
//  Copyright (c) 2013 David Nesbitt. All rights reserved.
//

#import "NezInstanceAttributeBufferObject.h"

@interface NezInstanceAttributeBufferObjectColorTexture : NezInstanceAttributeBufferObject

@property (readonly, getter = getInstanceAttributeList) NezInstanceAttributeColorTexture *instanceAttributeList;

@end
