//
//  NezVertexArray.m
//  Aletteration
//
//  Created by David Nesbitt on 2013-09-20.
//  Copyright 2011 David Nesbitt. All rights reserved.
//

#import "NezVertexArrayInstancedAbstract.h"
#import "NezGLSLProgram.h"
#import "NezGLCamera.h"

@implementation NezVertexArrayInstancedAbstract

-(instancetype)initWithObjVertexArray:(NezModelVertexArray*)vertexArray andInstanceCount:(GLsizei)instanceCount {
	if ((self = [super init])) {
		_vertexCount = vertexArray.vertexCount;
		_vertexData = nil;
		
		_indexCount = vertexArray.indexCount;
		_indexData = [NSMutableData dataWithLength:_indexCount*sizeof(unsigned short)];
		unsigned short *iDst = self.indexList;
		unsigned short *iSrc = vertexArray.indexList;
		for (NSInteger i=0; i<_indexCount; i++) {
			iDst[i] = iSrc[i];
		}
		
		_instanceCount = instanceCount;
		_instanceData = nil;
		
		_depthTest = YES;
	}
	return self;
}

-(GLuint)getVertexArrayObject {
	return _buffers[0];
}

-(GLuint*)getVertexArrayObjectPtr {
	return _buffers;
}

-(GLuint)getVertexArrayBuffer {
	return _buffers[1];
}

-(GLuint*)getVertexArrayBufferPtr {
	return _buffers+1;
}

-(GLuint)getVertexElementBuffer {
	return _buffers[2];
}

-(GLuint*)getVertexElementBufferPtr {
	return _buffers+2;
}

-(GLuint)getInstanceAttributeBuffer {
	return _buffers[3];
}

-(GLuint*)getInstanceAttributeBufferPtr {
	return _buffers+3;
}

-(const void*)getVertexList {
	return _vertexData.bytes;
}

-(unsigned short*)getIndexList {
	return (unsigned short*)_indexData.bytes;
}

-(const void*)getInstanceAttributeList {
	return _instanceData.bytes;
}

-(void)fillInstanceData {
	glBindBuffer(GL_ARRAY_BUFFER, self.instanceAttributeBuffer);
	glBufferSubData(GL_ARRAY_BUFFER, 0, _instanceData.length, _instanceData.bytes);
	glBindBuffer(GL_ARRAY_BUFFER, 0);
}

-(NezGLSLProgram*)getProgram {
	return _program;
}

-(void)setProgram:(NezGLSLProgram *)program {
	if (_program) {
		[self removeProgram];
	}
	_program = program;
	
	if (_program) {
		glGenVertexArraysOES(1, self.vertexArrayObjectPtr);
		glBindVertexArrayOES(self.vertexArrayObject);
		
		glGenBuffers(1, self.vertexArrayBufferPtr);
		glBindBuffer(GL_ARRAY_BUFFER, self.vertexArrayBuffer);
		glBufferData(GL_ARRAY_BUFFER, _vertexData.length, _vertexData.bytes, GL_STATIC_DRAW);
		
		glGenBuffers(1, self.vertexElementBufferPtr);
		glBindBuffer(GL_ELEMENT_ARRAY_BUFFER, self.vertexElementBuffer);
		glBufferData(GL_ELEMENT_ARRAY_BUFFER, _indexData.length, _indexData.bytes, GL_STATIC_DRAW);
		
		[self enableVertexAttributes];
		
		if (_instanceData) {
			glGenBuffers(1, self.instanceAttributeBufferPtr);
			glBindBuffer(GL_ARRAY_BUFFER, self.instanceAttributeBuffer);
			glBufferData(GL_ARRAY_BUFFER, _instanceData.length, _instanceData.bytes, GL_DYNAMIC_DRAW);
			
			[self enableInstanceAttributes];
		}
		
		glBindVertexArrayOES(0);
		glBindBuffer(GL_ARRAY_BUFFER, 0);
		glBindBuffer(GL_ELEMENT_ARRAY_BUFFER, 0);
		glUseProgram(0);
	}
}

-(void)removeProgram {
	[self deleteBuffers];
}

-(void)enableVertexAttributes {}
-(void)enableInstanceAttributes {}

-(void)enableVertexAttributeArrayWithLocation:(GLuint)location size:(GLint)size stride:(GLsizei)stride andOffset:(const GLvoid*)offset {
	if (location != NEZ_GLSL_ITEM_NOT_SET) {
		glEnableVertexAttribArray(location);
		glVertexAttribPointer(location, size, GL_FLOAT, GL_FALSE, stride, offset);
	}
}

-(void)enableInstancedAttributeArrayWithLocation:(GLuint)location size:(GLint)size stride:(GLsizei)stride andOffset:(const GLvoid*)offset {
	if (location != NEZ_GLSL_ITEM_NOT_SET) {
		glEnableVertexAttribArray(location);
		glVertexAttribPointer(location, size, GL_FLOAT, GL_FALSE, stride, offset);
		glVertexAttribDivisor(location, 1);
	}
}

-(void)deleteBuffers {
	if (self.vertexArrayObject) {
		glDeleteVertexArraysOES(1, self.vertexArrayObjectPtr);
	}
	if (self.vertexArrayBuffer) {
		glDeleteBuffers(1, self.vertexArrayBufferPtr);
	}
	if (self.vertexElementBuffer) {
		glDeleteBuffers(1, self.vertexElementBufferPtr);
	}
	if (self.instanceAttributeBuffer) {
		glDeleteBuffers(1, self.instanceAttributeBufferPtr);
	}
	_buffers[0] = 0;
	_buffers[1] = 0;
	_buffers[2] = 0;
	_buffers[3] = 0;
}

-(void)dealloc {
	self.program = nil;
}

-(void)drawWithGraphics:(NezAletterationGraphics*)graphics {}

@end
