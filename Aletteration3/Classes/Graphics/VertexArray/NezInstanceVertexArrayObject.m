//
//  NezInstanceVertexArrayObject.m
//  Aletteration3
//
//  Created by David Nesbitt on 2013/10/07.
//  Copyright (c) 2013 David Nesbitt. All rights reserved.
//

#import "NezInstanceVertexArrayObject.h"
#import "NezVertexBufferObject.h"
#import "NezInstanceAttributeBufferObject.h"
#import "NezGLSLProgram.h"

@implementation NezInstanceVertexArrayObject

-(instancetype)initWithVertexBufferObject:(NezVertexBufferObject*)vertexBufferObject andInstanceAttributeBufferObject:(NezInstanceAttributeBufferObject*)instanceAttributeBufferObject {
	if ((self = [super initWithVertexBufferObject:vertexBufferObject])) {
		_instanceAttributeBufferObject = instanceAttributeBufferObject;
	}
	return self;
}

-(id)getInstanceAttributeBufferObject {
	return _instanceAttributeBufferObject;
}

-(Class)getInstanceAttributeBufferObjectClass {
	return [NezInstanceAttributeBufferObject class];
}

-(void)encodeRestorableStateWithCoder:(NSCoder*)coder {
	[super encodeRestorableStateWithCoder:coder];
	if (_instanceAttributeBufferObject) {
		[coder encodeObject:_instanceAttributeBufferObject forKey:@"_instanceAttributeBufferObject"];
	}
}

-(void)decodeRestorableStateWithCoder:(NSCoder*)coder {
	[super decodeRestorableStateWithCoder:coder];
	if ([coder containsValueForKey:@"_instanceAttributeBufferObject"]) {
		_instanceAttributeBufferObject = [coder decodeObjectForKey:@"_instanceAttributeBufferObject"];
	}
}

-(void)registerChildObjectsForStateRestoration {
	[super registerChildObjectsForStateRestoration];
	if (_instanceAttributeBufferObject) {
		[self registerChildObject:_instanceAttributeBufferObject withRestorationIdentifier:@"_instanceAttributeBufferObject"];
	}
}

-(void)setProgram:(NezGLSLProgram*)program {
	_program = program;
	
	if (_program) {
		glBindVertexArrayOES(self.vertexArrayObject);
		
		[_vertexBufferObject bindBufferData];
		[self enableVertexAttributes];

		if (_instanceAttributeBufferObject) {
			[_instanceAttributeBufferObject bindBufferData];
			[self enableInstanceAttributes];
		}
		glBindVertexArrayOES(0);
		glBindBuffer(GL_ARRAY_BUFFER, 0);
		glBindBuffer(GL_ELEMENT_ARRAY_BUFFER, 0);
	}
}

-(void)enableInstanceAttributes {
	[_instanceAttributeBufferObject enableInstanceVertexAttributesForProgram:_program];
}

@end
