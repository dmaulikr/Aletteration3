//
//  NezInstanceAttributeBufferObject.m
//  Aletteration3
//
//  Created by David Nesbitt on 10/7/2013.
//  Copyright (c) 2013 David Nesbitt. All rights reserved.
//

#import "NezInstanceAttributeBufferObject.h"
#import "NezGLSLProgram.h"

@interface NezInstanceAttributeBufferObject() {
	GLuint _instanceAttributeBuffer;
}

@end

@implementation NezInstanceAttributeBufferObject

-(instancetype)initWithInstanceCount:(GLsizei)instanceCount {
	if ((self = [super init])) {
		_instanceCount = instanceCount;
		_instanceData = [NSMutableData dataWithLength:instanceCount*self.sizeofInstanceAttribute];
		_divisor = 1;
		[self createBuffers];
	}
	return self;
}

-(void)encodeRestorableStateWithCoder:(NSCoder*)coder {
	[coder encodeInt32:_instanceCount forKey:@"_instanceCount"];
	[coder encodeObject:_instanceData forKey:@"_instanceData"];
}

-(void)decodeRestorableStateWithCoder:(NSCoder*)coder {
	_instanceCount = [coder decodeInt32ForKey:@"_instanceCount"];
	_instanceData = [coder decodeObjectForKey:@"_instanceData"];
	[self createBuffers];
}

-(GLsizei)getSizeofInstanceAttribute {
	return 0;
}

-(GLuint)getInstanceAttributeBuffer {
	return _instanceAttributeBuffer;
}

-(GLuint*)getInstanceAttributeBufferPtr {
	return &_instanceAttributeBuffer;
}

-(const void*)getInstanceAttributeList {
	return _instanceData.bytes;
}

-(void)fillInstanceData {
	glBindBuffer(GL_ARRAY_BUFFER, self.instanceAttributeBuffer);
	glBufferSubData(GL_ARRAY_BUFFER, 0, _instanceData.length, _instanceData.bytes);
	glBindBuffer(GL_ARRAY_BUFFER, 0);
}

-(void)createBuffers {
	glGenBuffers(1, self.instanceAttributeBufferPtr);
}

-(void)bindBufferData {
	glBindBuffer(GL_ARRAY_BUFFER, self.instanceAttributeBuffer);
	glBufferData(GL_ARRAY_BUFFER, _instanceData.length, _instanceData.bytes, GL_DYNAMIC_DRAW);
}

-(void)deleteBuffers {
	if (_instanceAttributeBuffer) {
		glDeleteBuffers(1, self.instanceAttributeBufferPtr);
		_instanceAttributeBuffer = 0;
	}
}

-(void)enableInstanceVertexAttributeWithLocation:(GLuint)location size:(GLint)size stride:(GLsizei)stride offset:(const GLvoid*)offset {
	if (location != NEZ_GLSL_ITEM_NOT_SET) {
		glEnableVertexAttribArray(location);
		glVertexAttribPointer(location, size, GL_FLOAT, GL_FALSE, stride, offset);
		glVertexAttribDivisor(location, _divisor);
	}
}

-(void)enableInstanceVertexAttributesForProgram:(NezGLSLProgram*)program {}

-(void)dealloc {
	[self deleteBuffers];
}

@end
