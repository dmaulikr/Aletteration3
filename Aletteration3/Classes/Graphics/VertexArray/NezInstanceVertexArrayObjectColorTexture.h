//
//  NezInstanceVertexArrayObjectColorTexture.h
//  Aletteration3
//
//  Created by David Nesbitt on 2013/11/21.
//  Copyright (c) 2013 David Nesbitt. All rights reserved.
//

#import "NezInstanceVertexArrayObject.h"
#import "NezVertexTypes.h"
#import "NezInstanceAttributeTypes.h"

@class NezVertexBufferObjectInstanceTextureVertex;
@class NezInstanceAttributeBufferObjectColorTexture;

@interface NezInstanceVertexArrayObjectColorTexture : NezInstanceVertexArrayObject

@property (readonly, getter = getVertexBufferObject) NezVertexBufferObjectInstanceTextureVertex *vertexBufferObject;
@property (readonly, getter = getInstanceAttributeBufferObject) NezInstanceAttributeBufferObjectColorTexture *instanceAttributeBufferObject;

@property (readonly, getter = getVertexList) NezInstanceTextureVertex *vertexList;
@property (readonly, getter = getInstanceAttributeList) NezInstanceAttributeColorTexture *instanceAttributeList;
@property GLKTextureInfo *textureInfo;

@end
