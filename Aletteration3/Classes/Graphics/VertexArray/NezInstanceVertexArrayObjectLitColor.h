//
//  NezInstanceVertexArrayObjectLitColor.h
//  Aletteration3
//
//  Created by David Nesbitt on 2013/10/07.
//  Copyright (c) 2013 David Nesbitt. All rights reserved.
//

#import "NezInstanceVertexArrayObject.h"
#import "NezVertexTypes.h"
#import "NezInstanceAttributeTypes.h"

@class NezVertexBufferObjectLitVertex;
@class NezInstanceAttributeBufferObjectColor;

@interface NezInstanceVertexArrayObjectLitColor : NezInstanceVertexArrayObject {
}

@property (readonly, getter = getVertexBufferObject) NezVertexBufferObjectLitVertex *vertexBufferObject;
@property (readonly, getter = getInstanceAttributeBufferObject) NezInstanceAttributeBufferObjectColor *instanceAttributeBufferObject;

@property (readonly, getter = getVertexList) NezLitVertex *vertexList;
@property (readonly, getter = getInstanceAttributeList) NezInstanceAttributeColor *instanceAttributeList;

@end
