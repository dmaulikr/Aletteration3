//
//  NezInstanceAttributeBufferObjectColor.m
//  Aletteration3
//
//  Created by David Nesbitt on 2013/12/19.
//  Copyright (c) 2013 David Nesbitt. All rights reserved.
//

#import "NezInstanceAttributeBufferObjectColor.h"
#import "NezGLSLProgram.h"

@implementation NezInstanceAttributeBufferObjectColor

-(instancetype)initWithInstanceCount:(GLsizei)instanceCount {
	if ((self = [super initWithInstanceCount:instanceCount])) {
		NezInstanceAttributeColor *aDst = self.instanceAttributeList;
		for (NSInteger i=0; i<instanceCount; i++) {
			aDst[i].matrix = GLKMatrix4Identity;
			aDst[i].color = GLKVector4Make(0.0f, 0.0f, 0.0f, 0.0f);
		}
	}
	return self;
}

-(GLsizei)getSizeofInstanceAttribute {
	return sizeof(NezInstanceAttributeColor);
}

-(NezInstanceAttributeColor*)getInstanceAttributeList {
	return (NezInstanceAttributeColor*)_instanceData.bytes;
}

-(void)enableInstanceVertexAttributesForProgram:(NezGLSLProgram*)program {
	[self enableInstanceVertexAttributeWithLocation:program.a_matrixColumn0 size:4 stride:self.sizeofInstanceAttribute offset:(void*)offsetof(NezInstanceAttributeColor, matrix.m00)];
	[self enableInstanceVertexAttributeWithLocation:program.a_matrixColumn1 size:4 stride:self.sizeofInstanceAttribute offset:(void*)offsetof(NezInstanceAttributeColor, matrix.m10)];
	[self enableInstanceVertexAttributeWithLocation:program.a_matrixColumn2 size:4 stride:self.sizeofInstanceAttribute offset:(void*)offsetof(NezInstanceAttributeColor, matrix.m20)];
	[self enableInstanceVertexAttributeWithLocation:program.a_matrixColumn3 size:4 stride:self.sizeofInstanceAttribute offset:(void*)offsetof(NezInstanceAttributeColor, matrix.m30)];
	[self enableInstanceVertexAttributeWithLocation:program.a_color size:4 stride:self.sizeofInstanceAttribute offset:(void*)offsetof(NezInstanceAttributeColor, color)];
}

@end
