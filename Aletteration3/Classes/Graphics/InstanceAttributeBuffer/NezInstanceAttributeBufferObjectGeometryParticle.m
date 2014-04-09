//
//  NezInstanceAttributeBufferObjectGeometryParticle.m
//  Aletteration3
//
//  Created by David Nesbitt on 2013/12/19.
//  Copyright (c) 2013 David Nesbitt. All rights reserved.
//

#import "NezInstanceAttributeBufferObjectGeometryParticle.h"
#import "NezGLSLProgram.h"

@implementation NezInstanceAttributeBufferObjectGeometryParticle

-(instancetype)initWithInstanceCount:(GLsizei)instanceCount {
	if ((self = [super initWithInstanceCount:instanceCount])) {
		NezInstanceAttributeGeometryParticle *aDst = self.instanceAttributeList;
		for (NSInteger i=0; i<instanceCount; i++) {
			aDst[i].orientation = GLKQuaternionIdentity;
			aDst[i].angularVelocity = GLKQuaternionIdentity;
			aDst[i].color0 = GLKVector4Make(0.0f, 0.0f, 0.0f, 0.0f);
			aDst[i].color1 = GLKVector4Make(0.0f, 0.0f, 0.0f, 0.0f);
			aDst[i].offset = GLKVector3Make(0.0f, 0.0f, 0.0f);
			aDst[i].velocity = GLKVector3Make(0.0f, 0.0f, 0.0f);
			aDst[i].scale = GLKVector3Make(0.0f, 0.0f, 0.0f);
			aDst[i].uvScale = GLKVector2Make(0.0f, 0.0f);
		}
	}
	return self;
}

-(GLsizei)getSizeofInstanceAttribute {
	return sizeof(NezInstanceAttributeGeometryParticle);
}

-(NezInstanceAttributeGeometryParticle*)getInstanceAttributeList {
	return (NezInstanceAttributeGeometryParticle*)_instanceData.bytes;
}

-(void)enableInstanceVertexAttributesForProgram:(NezGLSLProgram*)program {
	[self enableInstanceVertexAttributeWithLocation:program.a_orientation size:4 stride:self.sizeofInstanceAttribute offset:(void*)offsetof(NezInstanceAttributeGeometryParticle, orientation)];
	[self enableInstanceVertexAttributeWithLocation:program.a_angularVelocity size:4 stride:self.sizeofInstanceAttribute offset:(void*)offsetof(NezInstanceAttributeGeometryParticle, angularVelocity)];
	[self enableInstanceVertexAttributeWithLocation:program.a_color0 size:4 stride:self.sizeofInstanceAttribute offset:(void*)offsetof(NezInstanceAttributeGeometryParticle, color0)];
	[self enableInstanceVertexAttributeWithLocation:program.a_color1 size:4 stride:self.sizeofInstanceAttribute offset:(void*)offsetof(NezInstanceAttributeGeometryParticle, color1)];
	[self enableInstanceVertexAttributeWithLocation:program.a_offset size:3 stride:self.sizeofInstanceAttribute offset:(void*)offsetof(NezInstanceAttributeGeometryParticle, offset)];
	[self enableInstanceVertexAttributeWithLocation:program.a_velocity size:3 stride:self.sizeofInstanceAttribute offset:(void*)offsetof(NezInstanceAttributeGeometryParticle, velocity)];
	[self enableInstanceVertexAttributeWithLocation:program.a_scale size:3 stride:self.sizeofInstanceAttribute offset:(void*)offsetof(NezInstanceAttributeGeometryParticle, scale)];
	[self enableInstanceVertexAttributeWithLocation:program.a_uvScale size:2 stride:self.sizeofInstanceAttribute offset:(void*)offsetof(NezInstanceAttributeGeometryParticle, uvScale)];
}

@end
