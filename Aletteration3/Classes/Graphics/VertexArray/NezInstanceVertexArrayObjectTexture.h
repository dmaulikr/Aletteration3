//
//  NezInstanceVertexArrayObjectTexture.h
//  Aletteration3
//
//  Created by David Nesbitt on 2013/10/07.
//  Copyright (c) 2013 David Nesbitt. All rights reserved.
//

#import "NezInstanceVertexArrayObject.h"
#import "NezVertexTypes.h"
#import "NezInstanceAttributeTypes.h"

@class NezVertexBufferObjectInstanceTextureVertex;
@class NezInstanceAttributeBufferObjectTexture;

@interface NezInstanceVertexArrayObjectTexture : NezInstanceVertexArrayObject

@property (readonly, getter = getVertexBufferObject) NezVertexBufferObjectInstanceTextureVertex *vertexBufferObject;
@property (readonly, getter = getInstanceAttributeBufferObject) NezInstanceAttributeBufferObjectTexture *instanceAttributeBufferObject;

@property (readonly, getter = getVertexList) NezInstanceTextureVertex *vertexList;
@property (readonly, getter = getInstanceAttributeList) NezInstanceAttributeTexture *instanceAttributeList;
@property GLKTextureInfo *textureInfo;

@end
