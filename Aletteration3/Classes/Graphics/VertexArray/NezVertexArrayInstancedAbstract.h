//
//  NezVertexArrayInstanced.h
//  Aletteration
//
//  Created by David Nesbitt on 2013-09-20.
//  Copyright 2011 David Nesbitt. All rights reserved.
//

#import <stddef.h>
#import <stdlib.h>
#import <GLKit/GLKit.h>

#import "NezMaterials.h"
#import "NezVertexTypes.h"
#import "NezInstanceAttributeTypes.h"
#import "NezSimpleObjLoader.h"

@class NezAletterationGraphics;
@class NezGLSLProgram;
@class NezGLCamera;

@interface NezVertexArrayInstancedAbstract : NSObject {
	NSMutableData *_indexData;
	NSMutableData *_vertexData;
	NSMutableData *_instanceData;
	
	NezMaterial *_material;
	
	NezGLSLProgram *_program;
	GLuint _buffers[4];
}

@property (readonly, getter = getVertexArrayObject) GLuint vertexArrayObject;
@property (readonly, getter = getVertexArrayObjectPtr) GLuint *vertexArrayObjectPtr;

@property (readonly, getter = getVertexArrayBuffer) GLuint vertexArrayBuffer;
@property (readonly, getter = getVertexArrayBufferPtr) GLuint *vertexArrayBufferPtr;

@property (readonly, getter = getVertexElementBuffer) GLuint vertexElementBuffer;
@property (readonly, getter = getVertexElementBufferPtr) GLuint *vertexElementBufferPtr;

@property (readonly, getter = getInstanceAttributeBuffer) GLuint instanceAttributeBuffer;
@property (readonly, getter = getInstanceAttributeBufferPtr) GLuint *instanceAttributeBufferPtr;

@property (readonly) NSInteger vertexCount;

@property (readonly) NSInteger indexCount;
@property (readonly, getter = getIndexList) unsigned short *indexList;

@property (readonly) NSInteger instanceCount;

@property BOOL depthTest;
@property NezMaterial *material;

@property (getter = getProgram, setter = setProgram:) NezGLSLProgram *program;

-(instancetype)initWithObjVertexArray:(NezModelVertexArray*)vertexArray andInstanceCount:(GLsizei)instanceCount;

-(void)enableVertexAttributes;
-(void)enableInstanceAttributes;
-(void)enableVertexAttributeArrayWithLocation:(GLuint)location size:(GLint)size stride:(GLsizei)stride andOffset:(const GLvoid*)offset;
-(void)enableInstancedAttributeArrayWithLocation:(GLuint)location size:(GLint)size stride:(GLsizei)stride andOffset:(const GLvoid*)offset;

-(void)fillInstanceData;

-(void)drawWithGraphics:(NezAletterationGraphics*)graphics;

@end
