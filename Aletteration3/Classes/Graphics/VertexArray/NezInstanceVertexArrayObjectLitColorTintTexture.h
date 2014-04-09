//
//  NezInstanceVertexArrayObjectLitColorTintTexture.h
//  Aletteration3
//
//  Created by David Nesbitt on 2013/10/07.
//  Copyright (c) 2013 David Nesbitt. All rights reserved.
//

#import "NezInstanceVertexArrayObject.h"
#import "NezVertexTypes.h"
#import "NezInstanceAttributeTypes.h"

@class NezVertexBufferObjectLitInstanceTextureVertex;
@class NezInstanceAttributeBufferObjectColorTintTexture;

@interface NezInstanceVertexArrayObjectLitColorTintTexture : NezInstanceVertexArrayObject

@property (readonly, getter = getVertexBufferObject) NezVertexBufferObjectLitInstanceTextureVertex *vertexBufferObject;
@property (readonly, getter = getInstanceAttributeBufferObject) NezInstanceAttributeBufferObjectColorTintTexture *instanceAttributeBufferObject;

@property (readonly, getter = getVertexList) NezLitInstanceTextureVertex *vertexList;
@property (readonly, getter = getInstanceAttributeList) NezInstanceAttributeColorTintTexture *instanceAttributeList;
@property GLKTextureInfo *textureInfo;

@end
