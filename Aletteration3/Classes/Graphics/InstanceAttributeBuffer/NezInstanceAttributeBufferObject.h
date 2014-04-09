//
//  NezInstanceAttributeBufferObject.h
//  Aletteration3
//
//  Created by David Nesbitt on 10/7/2013.
//  Copyright (c) 2013 David Nesbitt. All rights reserved.
//

#import <GLKit/GLKit.h>
#import "NezRestorableObject.h"

@class NezGLSLProgram;

#import "NezInstanceAttributeTypes.h"

@interface NezInstanceAttributeBufferObject : NezRestorableObject {
	NSMutableData *_instanceData;
}

@property (readonly, getter = getInstanceAttributeBuffer) GLuint instanceAttributeBuffer;
@property (readonly, getter = getInstanceAttributeBufferPtr) GLuint *instanceAttributeBufferPtr;
@property (readonly, getter = getSizeofInstanceAttribute) GLsizei sizeofInstanceAttribute;

@property GLuint divisor;
@property (readonly) GLsizei instanceCount;

-(instancetype)initWithInstanceCount:(GLsizei)instanceCount;

-(void)createBuffers;
-(void)bindBufferData;
-(void)deleteBuffers;

-(void)enableInstanceVertexAttributeWithLocation:(GLuint)location size:(GLint)size stride:(GLsizei)stride offset:(const GLvoid*)offset;

-(void)enableInstanceVertexAttributesForProgram:(NezGLSLProgram*)program;

-(void)fillInstanceData;

@end
