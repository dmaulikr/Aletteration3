//
//  NezVertexBufferObjectLitInstanceTextureVertex.m
//  Aletteration3
//
//  Created by David Nesbitt on 2013/12/07.
//  Copyright (c) 2013 David Nesbitt. All rights reserved.
//

#import "NezVertexBufferObjectLitInstanceTextureVertex.h"
#import "NezGLSLProgram.h"

@implementation NezVertexBufferObjectLitInstanceTextureVertex

-(instancetype)initWithObjVertexArray:(NezModelVertexArray*)vertexArray {
	if ((self = [super initWithObjVertexArray:vertexArray])) {
		NSInteger vertexCount = vertexArray.vertexCount;
		NezLitInstanceTextureVertex *vDst = self.vertexList;
		NezModelVertex *vSrc = vertexArray.vertexList;
		for (NSInteger i=0; i<vertexCount; i++) {
			vDst[i].position = vSrc[i].position;
			vDst[i].normal = vSrc[i].normal;
			vDst[i].uvIndex = i;
		}
	}
	return self;
}

-(GLsizei)getSizeofVertex {
	return sizeof(NezLitInstanceTextureVertex);
}

-(NezLitInstanceTextureVertex*)getVertexList {
	return (NezLitInstanceTextureVertex*)_vertexData.bytes;
}

-(void)enableVertexAttributesForProgram:(NezGLSLProgram*)program {
	[self enableVertexAttributeArrayWithLocation:program.a_position size:3 stride:self.sizeofVertex offset:(void*)offsetof(NezLitInstanceTextureVertex, position)];
	[self enableVertexAttributeArrayWithLocation:program.a_normal size:3 stride:self.sizeofVertex offset:(void*)offsetof(NezLitInstanceTextureVertex, normal)];
	[self enableVertexAttributeArrayWithLocation:program.a_uvIndex size:1 stride:self.sizeofVertex offset:(void*)offsetof(NezLitInstanceTextureVertex, uvIndex)];
}

@end
