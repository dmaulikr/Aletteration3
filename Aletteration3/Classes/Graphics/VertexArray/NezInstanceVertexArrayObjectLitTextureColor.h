//
//  NezInstanceVertexArrayObjectLitTextureColor.h
//  Aletteration3
//
//  Created by David Nesbitt on 2013/10/21.
//  Copyright (c) 2013 David Nesbitt. All rights reserved.
//

#import "NezInstanceVertexArrayObject.h"
#import "NezVertexTypes.h"
#import "NezInstanceAttributeTypes.h"

@class NezVertexBufferObjectLitTextureVertex;
@class NezInstanceAttributeBufferObjectColor;

@interface NezInstanceVertexArrayObjectLitTextureColor : NezInstanceVertexArrayObject

@property (readonly, getter = getVertexBufferObject) NezVertexBufferObjectLitTextureVertex *vertexBufferObject;
@property (readonly, getter = getInstanceAttributeBufferObject) NezInstanceAttributeBufferObjectColor *instanceAttributeBufferObject;

@property (readonly, getter = getVertexList) NezLitTextureVertex *vertexList;
@property (readonly, getter = getInstanceAttributeList) NezInstanceAttributeColor *instanceAttributeList;
@property GLKTextureInfo *textureInfo;

@end
