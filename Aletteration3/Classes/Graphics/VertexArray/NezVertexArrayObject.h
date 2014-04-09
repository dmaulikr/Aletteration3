//
//  NezVertexArrayObject.h
//  Aletteration3
//
//  Created by David Nesbitt on 2013/10/07.
//  Copyright (c) 2013 David Nesbitt. All rights reserved.
//

#import <stddef.h>
#import <stdlib.h>
#import <GLKit/GLKit.h>
#import "NezRestorableObject.h"

#define NEZ_GLSL_DARKNESS_MULTIPLIER 0.5

@class NezVertexBufferObject;
@class NezGLSLProgram;
@class NezAletterationGraphics;
@class NezMaterial;

@interface NezVertexArrayObject : NezRestorableObject {
	NezGLSLProgram *_program;
	id _vertexBufferObject;
}

@property (readonly, getter = getVertexArrayObject) GLuint vertexArrayObject;
@property (readonly, getter = getVertexArrayObjectPtr) GLuint *vertexArrayObjectPtr;

@property (readonly, getter = getVertexBufferObject) id vertexBufferObject;
@property (readonly, getter = getVertexBufferObjectClass) Class vertexBufferObjectClass;

@property (getter = getProgram, setter = setProgram:) NezGLSLProgram *program;

@property BOOL depthTest;
@property NezMaterial *material;

-(instancetype)initWithVertexBufferObject:(NezVertexBufferObject*)vertexBufferObject;

-(void)encodeRestorableStateWithCoder:(NSCoder*)coder;
-(void)decodeRestorableStateWithCoder:(NSCoder*)coder;

-(void)setProgram:(NezGLSLProgram*)program;

-(void)enableVertexAttributes;

-(void)drawWithGraphics:(NezAletterationGraphics*)graphics;

@end
