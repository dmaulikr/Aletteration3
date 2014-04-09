//
//  NezInstanceAttributeBufferObjectTexture.m
//  Aletteration3
//
//  Created by David Nesbitt on 2013/12/19.
//  Copyright (c) 2013 David Nesbitt. All rights reserved.
//

#import "NezInstanceAttributeBufferObjectTexture.h"
#import "NezGLSLProgram.h"

@implementation NezInstanceAttributeBufferObjectTexture

-(instancetype)initWithInstanceCount:(GLsizei)instanceCount {
	if ((self = [super initWithInstanceCount:instanceCount])) {
		NezInstanceAttributeTexture *aDst = self.instanceAttributeList;
		for (NSInteger i=0; i<instanceCount; i++) {
			aDst[i].matrix = GLKMatrix4Identity;
			aDst[i].uv0 = GLKVector2Make(0.0f, 0.0f);
			aDst[i].uv1 = GLKVector2Make(0.0f, 0.0f);
			aDst[i].uv2 = GLKVector2Make(0.0f, 0.0f);
			aDst[i].uv3 = GLKVector2Make(0.0f, 0.0f);
		}
	}
	return self;
}

-(GLsizei)getSizeofInstanceAttribute {
	return sizeof(NezInstanceAttributeTexture);
}

-(NezInstanceAttributeTexture*)getInstanceAttributeList {
	return (NezInstanceAttributeTexture*)_instanceData.bytes;
}

-(void)enableInstanceVertexAttributesForProgram:(NezGLSLProgram*)program {
	[self enableInstanceVertexAttributeWithLocation:program.a_matrixColumn0 size:4 stride:self.sizeofInstanceAttribute offset:(void*)offsetof(NezInstanceAttributeTexture, matrix.m00)];
	[self enableInstanceVertexAttributeWithLocation:program.a_matrixColumn1 size:4 stride:self.sizeofInstanceAttribute offset:(void*)offsetof(NezInstanceAttributeTexture, matrix.m10)];
	[self enableInstanceVertexAttributeWithLocation:program.a_matrixColumn2 size:4 stride:self.sizeofInstanceAttribute offset:(void*)offsetof(NezInstanceAttributeTexture, matrix.m20)];
	[self enableInstanceVertexAttributeWithLocation:program.a_matrixColumn3 size:4 stride:self.sizeofInstanceAttribute offset:(void*)offsetof(NezInstanceAttributeTexture, matrix.m30)];
	[self enableInstanceVertexAttributeWithLocation:program.a_uv0 size:2 stride:self.sizeofInstanceAttribute offset:(void*)offsetof(NezInstanceAttributeTexture, uv0)];
	[self enableInstanceVertexAttributeWithLocation:program.a_uv1 size:2 stride:self.sizeofInstanceAttribute offset:(void*)offsetof(NezInstanceAttributeTexture, uv1)];
	[self enableInstanceVertexAttributeWithLocation:program.a_uv2 size:2 stride:self.sizeofInstanceAttribute offset:(void*)offsetof(NezInstanceAttributeTexture, uv2)];
	[self enableInstanceVertexAttributeWithLocation:program.a_uv3 size:2 stride:self.sizeofInstanceAttribute offset:(void*)offsetof(NezInstanceAttributeTexture, uv3)];
}

@end
