//
//  NezVertexBufferObjectLitVertex.m
//  Aletteration3
//
//  Created by David Nesbitt on 2013/12/07.
//  Copyright (c) 2013 David Nesbitt. All rights reserved.
//

#import "NezVertexBufferObjectLitVertex.h"
#import "NezGLSLProgram.h"

@implementation NezVertexBufferObjectLitVertex

-(instancetype)initWithObjVertexArray:(NezModelVertexArray*)vertexArray {
	if ((self = [super initWithObjVertexArray:vertexArray])) {
		NSInteger vertexCount = vertexArray.vertexCount;
		NezLitVertex *vDst = self.vertexList;
		NezModelVertex *vSrc = vertexArray.vertexList;
		for (NSInteger i=0; i<vertexCount; i++) {
			vDst[i].position = vSrc[i].position;
			vDst[i].normal = vSrc[i].normal;
		}
	}
	return self;
}

-(GLsizei)getSizeofVertex {
	return sizeof(NezLitVertex);
}

-(NezLitVertex*)getVertexList {
	return (NezLitVertex*)_vertexData.bytes;
}

-(void)enableVertexAttributesForProgram:(NezGLSLProgram*)program {
	[self enableVertexAttributeArrayWithLocation:program.a_position size:3 stride:self.sizeofVertex offset:(void*)offsetof(NezLitVertex, position)];
	[self enableVertexAttributeArrayWithLocation:program.a_normal size:3 stride:self.sizeofVertex offset:(void*)offsetof(NezLitVertex, normal)];
}

@end
