//
//  NezVertexBufferObject.m
//  Aletteration3
//
//  Created by David Nesbitt on 10/7/2013.
//  Copyright (c) 2013 David Nesbitt. All rights reserved.
//

#import "NezVertexBufferObject.h"
#import "NezGLSLProgram.h"

@interface NezVertexBufferObject() {
	GLuint _vertexBufferObject;
	GLuint _vertexElementBuffer;
}

@end

@implementation NezVertexBufferObject

-(instancetype)initWithObjVertexArray:(NezModelVertexArray*)vertexArray {
	if ((self = [super init])) {
		_vertexCount = vertexArray.vertexCount;
		_vertexData = [NSMutableData dataWithLength:_vertexCount*self.sizeofVertex];
		
		_indexCount = vertexArray.indexCount;
		_indexData = [NSMutableData dataWithData:vertexArray.indexData];
		
		[self createBuffers];
	}
	return self;
}

-(void)encodeRestorableStateWithCoder:(NSCoder*)coder {
	[coder encodeInt32:_vertexCount forKey:@"_vertexCount"];
	[coder encodeObject:_vertexData forKey:@"_vertexData"];
	[coder encodeInt32:_indexCount forKey:@"_indexCount"];
	[coder encodeObject:_indexData forKey:@"_indexData"];
	[coder encodeFloat:_dimensions.x forKey:@"_dimensions.x"];
	[coder encodeFloat:_dimensions.y forKey:@"_dimensions.y"];
	[coder encodeFloat:_dimensions.z forKey:@"_dimensions.z"];
}

-(void)decodeRestorableStateWithCoder:(NSCoder*)coder {
	_vertexCount = [coder decodeInt32ForKey:@"_vertexCount"];
	_vertexData = [coder decodeObjectForKey:@"_vertexData"];
	_indexCount = [coder decodeInt32ForKey:@"_indexCount"];
	_indexData = [coder decodeObjectForKey:@"_indexData"];
	_dimensions.x = [coder decodeFloatForKey:@"_dimensions.x"];
	_dimensions.y = [coder decodeFloatForKey:@"_dimensions.y"];
	_dimensions.z = [coder decodeFloatForKey:@"_dimensions.z"];
	[self createBuffers];
}

-(GLsizei)getSizeofVertex {
	return 0;
}

-(GLuint)getVertexBufferObject {
	return _vertexBufferObject;
}

-(GLuint*)getVertexBufferObjectPtr {
	return &_vertexBufferObject;
}

-(GLuint)getVertexElementBuffer {
	return _vertexElementBuffer;
}

-(GLuint*)getVertexElementBufferPtr {
	return &_vertexElementBuffer;
}

-(const void*)getVertexList {
	return _vertexData.bytes;
}

-(unsigned short*)getIndexList {
	return (unsigned short*)_indexData.bytes;
}

-(void)createBuffers {
	[self deleteBuffers];
	glGenBuffers(1, self.vertexBufferObjectPtr);
	glGenBuffers(1, self.vertexElementBufferPtr);
}

-(void)bindBufferData {
	glBindBuffer(GL_ARRAY_BUFFER, self.vertexBufferObject);
	glBufferData(GL_ARRAY_BUFFER, _vertexData.length, _vertexData.bytes, GL_STATIC_DRAW);

	glBindBuffer(GL_ELEMENT_ARRAY_BUFFER, self.vertexElementBuffer);
	glBufferData(GL_ELEMENT_ARRAY_BUFFER, _indexData.length, _indexData.bytes, GL_STATIC_DRAW);
}

-(void)fillVertexData {
	glBindBuffer(GL_ARRAY_BUFFER, self.vertexBufferObject);
	glBufferSubData(GL_ARRAY_BUFFER, 0, _vertexData.length, _vertexData.bytes);
	glBindBuffer(GL_ARRAY_BUFFER, 0);
}

-(void)deleteBuffers {
	if (_vertexBufferObject) {
		glDeleteBuffers(1, self.vertexBufferObjectPtr);
		_vertexBufferObject = 0;
	}
	if (_vertexElementBuffer) {
		glDeleteBuffers(1, self.vertexElementBufferPtr);
		_vertexElementBuffer = 0;
	}
}

-(void)enableVertexAttributesForProgram:(NezGLSLProgram *)program {}

-(void)enableVertexAttributeArrayWithLocation:(GLuint)location size:(GLint)size stride:(GLsizei)stride offset:(const GLvoid*)offset {
	if (location != NEZ_GLSL_ITEM_NOT_SET) {
		glEnableVertexAttribArray(location);
		glVertexAttribPointer(location, size, GL_FLOAT, GL_FALSE, stride, offset);
	}
}

-(void)dealloc {
	[self deleteBuffers];
}

@end
