//
//  NezVertexBufferObject.h
//  Aletteration3
//
//  Created by David Nesbitt on 10/7/2013.
//  Copyright (c) 2013 David Nesbitt. All rights reserved.
//

#import <GLKit/GLKit.h>
#import <stddef.h>

#import "NezVertexTypes.h"
#import "NezModelVertexArray.h"
#import "NezRestorableObject.h"

@class NezGLSLProgram;

@interface NezVertexBufferObject : NezRestorableObject {
	NSMutableData *_indexData;
	NSMutableData *_vertexData;
}

@property (readonly, getter = getVertexBufferObject) GLuint vertexBufferObject;
@property (readonly, getter = getVertexBufferObjectPtr) GLuint *vertexBufferObjectPtr;

@property (readonly, getter = getVertexElementBuffer) GLuint vertexElementBuffer;
@property (readonly, getter = getVertexElementBufferPtr) GLuint *vertexElementBufferPtr;

@property (readonly, getter = getSizeofVertex) GLsizei sizeofVertex;

@property (readonly) GLsizei vertexCount;

@property (readonly) GLsizei indexCount;
@property (readonly, getter = getIndexList) unsigned short *indexList;

@property GLKVector3 dimensions;

-(instancetype)initWithObjVertexArray:(NezModelVertexArray*)vertexArray;

-(void)createBuffers;
-(void)bindBufferData;
-(void)fillVertexData;
-(void)deleteBuffers;

-(void)enableVertexAttributeArrayWithLocation:(GLuint)location size:(GLint)size stride:(GLsizei)stride offset:(const GLvoid*)offset;

-(void)enableVertexAttributesForProgram:(NezGLSLProgram*)program;

@end
