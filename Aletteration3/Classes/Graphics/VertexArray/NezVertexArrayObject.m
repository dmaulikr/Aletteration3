//
//  NezVertexArrayObject.m
//  Aletteration3
//
//  Created by David Nesbitt on 2013/10/07.
//  Copyright (c) 2013 David Nesbitt. All rights reserved.
//

#import "NezVertexArrayObject.h"
#import "NezVertexBufferObject.h"
#import "NezGLSLProgram.h"

@interface NezVertexArrayObject() {
	GLuint _vertexArrayObject;
}

@end

@implementation NezVertexArrayObject

-(instancetype)initWithVertexBufferObject:(NezVertexBufferObject*)vertexBufferObject {
	if ((self = [super init])) {
		_vertexBufferObject = vertexBufferObject;
		[self createVertexArrayObject];
	}
	return self;
}

-(id)getVertexBufferObject {
	return _vertexBufferObject;
}

-(Class)getVertexBufferObjectClass {
	return [NezVertexBufferObject class];
}

-(void)encodeRestorableStateWithCoder:(NSCoder*)coder {
	[coder encodeObject:_vertexBufferObject forKey:@"_vertexBufferObject"];
}

-(void)decodeRestorableStateWithCoder:(NSCoder*)coder {
	_vertexBufferObject = [coder decodeObjectForKey:@"_vertexBufferObject"];
	[self createVertexArrayObject];
}

-(void)registerChildObjectsForStateRestoration {
	[super registerChildObjectsForStateRestoration];
	[self registerChildObject:self.vertexBufferObject withRestorationIdentifier:@"_vertexBufferObject"];
}

-(GLuint)getVertexArrayObject {
	return _vertexArrayObject;
}

-(GLuint*)getVertexArrayObjectPtr {
	return &_vertexArrayObject;
}

-(NezGLSLProgram*)getProgram {
	return _program;
}

-(void)setProgram:(NezGLSLProgram*)program {
	_program = program;
	
	if (_program) {
		glBindVertexArrayOES(self.vertexArrayObject);
		
		[_vertexBufferObject bindBufferData];
		[self enableVertexAttributes];
		
		glBindVertexArrayOES(0);
		glBindBuffer(GL_ARRAY_BUFFER, 0);
		glBindBuffer(GL_ELEMENT_ARRAY_BUFFER, 0);
	}
}

-(void)enableVertexAttributes {
	[_vertexBufferObject enableVertexAttributesForProgram:_program];
}

-(void)createVertexArrayObject {
	[self deleteVertexArrayObject];
	glGenVertexArraysOES(1, self.vertexArrayObjectPtr);
}

-(void)deleteVertexArrayObject {
	if (self.vertexArrayObject) {
		glDeleteVertexArraysOES(1, self.vertexArrayObjectPtr);
		_vertexArrayObject = 0;
	}
}

-(void)drawWithGraphics:(NezAletterationGraphics*)graphics {}

@end
