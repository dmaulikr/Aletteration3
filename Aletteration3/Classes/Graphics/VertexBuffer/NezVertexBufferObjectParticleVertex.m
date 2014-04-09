//
//  NezVertexBufferObjectParticleVertex.m
//  Aletteration3
//
//  Created by David Nesbitt on 2013/12/07.
//  Copyright (c) 2013 David Nesbitt. All rights reserved.
//

#import "NezVertexBufferObjectParticleVertex.h"
#import "NezGLSLProgram.h"

@implementation NezVertexBufferObjectParticleVertex

-(instancetype)initWithObjVertexArray:(NezModelVertexArray*)vertexArray {
	if ((self = [super initWithObjVertexArray:vertexArray])) {
		NSInteger vertexCount = vertexArray.vertexCount;
		NezParticleVertex *vDst = self.vertexList;
		NezModelVertex *vSrc = vertexArray.vertexList;
		for (NSInteger i=0; i<vertexCount; i++) {
			vDst[i].position = vSrc[i].position;
			vDst[i].velocity = GLKVector3Make(0.0f, 0.0f, 0.0f);
			vDst[i].growth = 0.0f;
			vDst[i].stable = 0.0f;
			vDst[i].decay = 0.0f;
		}
	}
	return self;
}

-(GLsizei)getSizeofVertex {
	return sizeof(NezParticleVertex);
}

-(NezParticleVertex*)getVertexList {
	return (NezParticleVertex*)_vertexData.bytes;
}

-(void)enableVertexAttributesForProgram:(NezGLSLProgram*)program {
	[self enableVertexAttributeArrayWithLocation:program.a_position size:3 stride:self.sizeofVertex offset:(void*)offsetof(NezParticleVertex, position)];
	[self enableVertexAttributeArrayWithLocation:program.a_velocity size:3 stride:self.sizeofVertex offset:(void*)offsetof(NezParticleVertex, velocity)];
	[self enableVertexAttributeArrayWithLocation:program.a_growth size:1 stride:self.sizeofVertex offset:(void*)offsetof(NezParticleVertex, growth)];
	[self enableVertexAttributeArrayWithLocation:program.a_stable size:1 stride:self.sizeofVertex offset:(void*)offsetof(NezParticleVertex, stable)];
	[self enableVertexAttributeArrayWithLocation:program.a_decay size:1 stride:self.sizeofVertex offset:(void*)offsetof(NezParticleVertex, decay)];
}

@end
