//
//  NezInstanceVertexArrayObjectColor.h
//  Aletteration3
//
//  Created by David Nesbitt on 2013/10/07.
//  Copyright (c) 2013 David Nesbitt. All rights reserved.
//

#import "NezInstanceVertexArrayObject.h"
#import "NezVertexTypes.h"
#import "NezInstanceAttributeTypes.h"

@class NezVertexBufferObjectVertex;
@class NezInstanceAttributeBufferObjectColor;

@interface NezInstanceVertexArrayObjectColor : NezInstanceVertexArrayObject {
}

@property (readonly, getter = getVertexBufferObject) NezVertexBufferObjectVertex *vertexBufferObject;
@property (readonly, getter = getInstanceAttributeBufferObject) NezInstanceAttributeBufferObjectColor *instanceAttributeBufferObject;

@property (readonly, getter = getVertexList) NezVertex *vertexList;
@property (readonly, getter = getInstanceAttributeList) NezInstanceAttributeColor *instanceAttributeList;

@end
