//
//  NezInstanceAttributeBufferObjectColorTintTexture.m
//  Aletteration3
//
//  Created by David Nesbitt on 2013/12/19.
//  Copyright (c) 2013 David Nesbitt. All rights reserved.
//

#import "NezInstanceAttributeBufferObjectColorTintTexture.h"
#import "NezGLSLProgram.h"

@implementation NezInstanceAttributeBufferObjectColorTintTexture

-(instancetype)initWithInstanceCount:(GLsizei)instanceCount {
	if ((self = [super initWithInstanceCount:instanceCount])) {
		NezInstanceAttributeColorTintTexture *aDst = self.instanceAttributeList;
		for (NSInteger i=0; i<instanceCount; i++) {
			aDst[i].matrix = GLKMatrix4Identity;
			aDst[i].color = GLKVector4Make(0.0f, 0.0f, 0.0f, 0.0f);
			aDst[i].tint = GLKVector4Make(0.0f, 0.0f, 0.0f, 0.0f);
			aDst[i].uv0 = GLKVector2Make(0.0f, 0.0f);
			aDst[i].uv1 = GLKVector2Make(0.0f, 0.0f);
			aDst[i].uv2 = GLKVector2Make(0.0f, 0.0f);
			aDst[i].uv3 = GLKVector2Make(0.0f, 0.0f);
		}
	}
	return self;
}

-(GLsizei)getSizeofInstanceAttribute {
	return sizeof(NezInstanceAttributeColorTintTexture);
}

-(NezInstanceAttributeColorTintTexture*)getInstanceAttributeList {
	return (NezInstanceAttributeColorTintTexture*)_instanceData.bytes;
}

-(void)enableInstanceVertexAttributesForProgram:(NezGLSLProgram*)program {
	[self enableInstanceVertexAttributeWithLocation:program.a_matrixColumn0 size:4 stride:self.sizeofInstanceAttribute offset:(void*)offsetof(NezInstanceAttributeColorTintTexture, matrix.m00)];
	[self enableInstanceVertexAttributeWithLocation:program.a_matrixColumn1 size:4 stride:self.sizeofInstanceAttribute offset:(void*)offsetof(NezInstanceAttributeColorTintTexture, matrix.m10)];
	[self enableInstanceVertexAttributeWithLocation:program.a_matrixColumn2 size:4 stride:self.sizeofInstanceAttribute offset:(void*)offsetof(NezInstanceAttributeColorTintTexture, matrix.m20)];
	[self enableInstanceVertexAttributeWithLocation:program.a_matrixColumn3 size:4 stride:self.sizeofInstanceAttribute offset:(void*)offsetof(NezInstanceAttributeColorTintTexture, matrix.m30)];
	[self enableInstanceVertexAttributeWithLocation:program.a_color size:4 stride:self.sizeofInstanceAttribute offset:(void*)offsetof(NezInstanceAttributeColorTintTexture, color)];
	[self enableInstanceVertexAttributeWithLocation:program.a_tint size:4 stride:self.sizeofInstanceAttribute offset:(void*)offsetof(NezInstanceAttributeColorTintTexture, tint)];
	[self enableInstanceVertexAttributeWithLocation:program.a_uv0 size:2 stride:self.sizeofInstanceAttribute offset:(void*)offsetof(NezInstanceAttributeColorTintTexture, uv0)];
	[self enableInstanceVertexAttributeWithLocation:program.a_uv1 size:2 stride:self.sizeofInstanceAttribute offset:(void*)offsetof(NezInstanceAttributeColorTintTexture, uv1)];
	[self enableInstanceVertexAttributeWithLocation:program.a_uv2 size:2 stride:self.sizeofInstanceAttribute offset:(void*)offsetof(NezInstanceAttributeColorTintTexture, uv2)];
	[self enableInstanceVertexAttributeWithLocation:program.a_uv3 size:2 stride:self.sizeofInstanceAttribute offset:(void*)offsetof(NezInstanceAttributeColorTintTexture, uv3)];
}

@end
