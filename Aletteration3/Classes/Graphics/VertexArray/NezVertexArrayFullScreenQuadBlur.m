//
//  NezVertexArrayFullScreenQuadBlur.m
//  Aletteration3
//
//  Created by David Nesbitt on 2013-10-03.
//  Copyright (c) 2013 David Nesbitt. All rights reserved.
//

#import "NezVertexArrayFullScreenQuadBlur.h"
#import "NezAletterationGraphics.h"
#import "NezGLSLProgram.h"
#import "NezGLCamera.h"

@implementation NezVertexArrayFullScreenQuadBlur

-(instancetype)initWithObjVertexArray:(NezModelVertexArray*)vertexArray {
	if ((self = [super initWithObjVertexArray:vertexArray andInstanceCount:0])) {
		NSInteger vertexCount = vertexArray.vertexCount;
		_vertexData = [NSMutableData dataWithLength:vertexCount*sizeof(NezTextureVertex)];
		NezTextureVertex *vDst = self.vertexList;
		NezModelVertex *vSrc = vertexArray.vertexList;
		for (NSInteger i=0; i<vertexCount; i++) {
			vDst[i].position = vSrc[i].position;
			vDst[i].uv = vSrc[i].uv;
		}
	}
	return self;
}

-(NezTextureVertex*)getVertexList {
	return (NezTextureVertex*)_vertexData.bytes;
}

-(void)fillInstanceData {}

-(void)enableVertexAttributes {
	[self enableVertexAttributeArrayWithLocation:_program.a_position size:3 stride:sizeof(NezTextureVertex) andOffset:(void*)offsetof(NezTextureVertex, position)];
	[self enableVertexAttributeArrayWithLocation:_program.a_uv       size:2 stride:sizeof(NezTextureVertex) andOffset:(void*)offsetof(NezTextureVertex, uv)];
}

-(void)drawWithGraphics:(NezAletterationGraphics*)graphics {
	glUseProgram(_program.program);
	
	if (_texture0) {
		glActiveTexture(GL_TEXTURE0);
		glBindTexture(GL_TEXTURE_2D, _texture0);
		glUniform1i(_program.u_texture0, 0);
	}
	glUniform1f(_program.u_blurRadius, _blurRadius);
	
	glBindVertexArrayOES(self.vertexArrayObject);
	glDrawElements(GL_TRIANGLES, (GLsizei)self.indexCount, GL_UNSIGNED_SHORT, 0);
}

@end
