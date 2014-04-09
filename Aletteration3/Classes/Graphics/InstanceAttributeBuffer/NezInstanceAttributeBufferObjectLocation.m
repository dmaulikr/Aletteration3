//
//  NezInstanceAttributeBufferObjectLocation.m
//  Aletteration3
//
//  Created by David Nesbitt on 2013/12/19.
//  Copyright (c) 2013 David Nesbitt. All rights reserved.
//

#import "NezInstanceAttributeBufferObjectLocation.h"
#import "NezGLSLProgram.h"

@implementation NezInstanceAttributeBufferObjectLocation

-(instancetype)initWithInstanceCount:(GLsizei)instanceCount {
	if ((self = [super initWithInstanceCount:instanceCount])) {
		NezInstanceAttributeLocation *aDst = self.instanceAttributeList;
		for (NSInteger i=0; i<instanceCount; i++) {
			aDst[i].matrix = GLKMatrix4Identity;
		}
	}
	return self;
}

-(GLsizei)getSizeofInstanceAttribute {
	return sizeof(NezInstanceAttributeLocation);
}

-(NezInstanceAttributeLocation*)getInstanceAttributeList {
	return (NezInstanceAttributeLocation*)_instanceData.bytes;
}

-(void)enableInstanceVertexAttributesForProgram:(NezGLSLProgram*)program {
	[self enableInstanceVertexAttributeWithLocation:program.a_matrixColumn0 size:4 stride:self.sizeofInstanceAttribute offset:(void*)offsetof(NezInstanceAttributeLocation, matrix.m00)];
	[self enableInstanceVertexAttributeWithLocation:program.a_matrixColumn1 size:4 stride:self.sizeofInstanceAttribute offset:(void*)offsetof(NezInstanceAttributeLocation, matrix.m10)];
	[self enableInstanceVertexAttributeWithLocation:program.a_matrixColumn2 size:4 stride:self.sizeofInstanceAttribute offset:(void*)offsetof(NezInstanceAttributeLocation, matrix.m20)];
	[self enableInstanceVertexAttributeWithLocation:program.a_matrixColumn3 size:4 stride:self.sizeofInstanceAttribute offset:(void*)offsetof(NezInstanceAttributeLocation, matrix.m30)];
}

@end
