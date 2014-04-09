//
//  NezVertexBufferObjectTextureVertex.m
//  Aletteration3
//
//  Created by David Nesbitt on 2013/12/07.
//  Copyright (c) 2013 David Nesbitt. All rights reserved.
//

#import "NezVertexBufferObjectTextureVertex.h"
#import "NezGLSLProgram.h"

@implementation NezVertexBufferObjectTextureVertex

-(instancetype)initWithObjVertexArray:(NezModelVertexArray*)vertexArray {
	if ((self = [super initWithObjVertexArray:vertexArray])) {
		NSInteger vertexCount = vertexArray.vertexCount;
		NezTextureVertex *vDst = self.vertexList;
		NezModelVertex *vSrc = vertexArray.vertexList;
		for (NSInteger i=0; i<vertexCount; i++) {
			vDst[i].position = vSrc[i].position;
			vDst[i].uv = vSrc[i].uv;
		}
	}
	return self;
}

-(GLsizei)getSizeofVertex {
	return sizeof(NezTextureVertex);
}

-(NezTextureVertex*)getVertexList {
	return (NezTextureVertex*)_vertexData.bytes;
}

-(void)enableVertexAttributesForProgram:(NezGLSLProgram*)program {
	[self enableVertexAttributeArrayWithLocation:program.a_position size:3 stride:self.sizeofVertex offset:(void*)offsetof(NezTextureVertex, position)];
	[self enableVertexAttributeArrayWithLocation:program.a_uv size:2 stride:self.sizeofVertex offset:(void*)offsetof(NezTextureVertex, uv)];
}

@end
