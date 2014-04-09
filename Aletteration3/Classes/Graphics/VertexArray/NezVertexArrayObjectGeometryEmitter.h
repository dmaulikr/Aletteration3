//
//  NezVertexArrayObjectGeometryEmitter.h
//  Aletteration3
//
//  Created by David Nesbitt on 2013/12/06.
//  Copyright (c) 2013 David Nesbitt. All rights reserved.
//

#import "NezVertexArrayObjectEmitter.h"
#import "NezVertexTypes.h"
#import "NezInstanceAttributeTypes.h"

@class NezVertexBufferObjectLitVertex;
@class NezInstanceAttributeBufferObjectGeometryParticle;

@interface NezVertexArrayObjectGeometryEmitter : NezVertexArrayObjectEmitter

@property GLKVector3 center;
@property GLKVector3 acceleration;

@property (readonly, getter = getVertexBufferObject) NezVertexBufferObjectLitVertex *vertexBufferObject;
@property (readonly, getter = getInstanceAttributeBufferObject) NezInstanceAttributeBufferObjectGeometryParticle *instanceAttributeBufferObject;

@property (readonly, getter = getVertexList) NezLitVertex *vertexList;
@property (readonly, getter = getInstanceAttributeList) NezInstanceAttributeGeometryParticle *instanceAttributeList;

@end
