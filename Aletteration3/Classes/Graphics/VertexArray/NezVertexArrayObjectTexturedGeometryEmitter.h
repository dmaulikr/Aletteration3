//
//  NezVertexArrayObjectCircularRaysEmitter.h
//  Aletteration3
//
//  Created by David Nesbitt on 2013/12/18.
//  Copyright (c) 2013 David Nesbitt. All rights reserved.
//

#import "NezVertexArrayObjectEmitter.h"
#import "NezVertexTypes.h"
#import "NezInstanceAttributeTypes.h"

@class NezVertexBufferObjectLitTextureVertex;
@class NezInstanceAttributeBufferObjectGeometryParticle;

@interface NezVertexArrayObjectTexturedGeometryEmitter : NezVertexArrayObjectEmitter

@property GLKVector3 center;

@property (readonly, getter = getVertexBufferObject) NezVertexBufferObjectLitTextureVertex *vertexBufferObject;
@property (readonly, getter = getInstanceAttributeBufferObject) NezInstanceAttributeBufferObjectGeometryParticle *instanceAttributeBufferObject;

@property (readonly, getter = getVertexList) NezLitTextureVertex *vertexList;
@property (readonly, getter = getInstanceAttributeList) NezInstanceAttributeGeometryParticle *instanceAttributeList;

@property GLKTextureInfo *textureInfo;

@end
