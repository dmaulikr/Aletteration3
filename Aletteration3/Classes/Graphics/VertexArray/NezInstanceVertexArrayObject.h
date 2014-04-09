//
//  NezInstanceVertexArrayObject.h
//  Aletteration3
//
//  Created by David Nesbitt on 2013/10/07.
//  Copyright (c) 2013 David Nesbitt. All rights reserved.
//

#import "NezVertexArrayObject.h"

@class NezInstanceAttributeBufferObject;

@interface NezInstanceVertexArrayObject : NezVertexArrayObject {
	id _instanceAttributeBufferObject;
}

@property (readonly, getter = getInstanceAttributeBufferObject) id instanceAttributeBufferObject;
@property (readonly, getter = getInstanceAttributeBufferObjectClass) Class instanceAttributeBufferObjectClass;

-(instancetype)initWithVertexBufferObject:(NezVertexBufferObject*)vertexBufferObject andInstanceAttributeBufferObject:(NezInstanceAttributeBufferObject*)instanceAttributeBufferObject;

-(void)enableInstanceAttributes;

@end
