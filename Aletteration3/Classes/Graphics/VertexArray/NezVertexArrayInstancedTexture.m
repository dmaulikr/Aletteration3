//
//  NezVertexArrayTexture.m
//  Aletteration3
//
//  Created by David Nesbitt on 2013-09-23.
//  Copyright (c) 2013 David Nesbitt. All rights reserved.
//

#import "NezVertexArrayInstancedTexture.h"
#import "NezAletterationGraphics.h"
#import "NezGLSLProgram.h"
#import "NezGLCamera.h"

@implementation NezVertexArrayInstancedTexture

-(instancetype)initWithObjVertexArray:(NezModelVertexArray*)vertexArray andInstanceCount:(GLsizei)instanceCount {
	if ((self = [super initWithObjVertexArray:vertexArray andInstanceCount:instanceCount])) {
		NSInteger vertexCount = vertexArray.vertexCount;
		_vertexData = [NSMutableData dataWithLength:vertexCount*sizeof(NezInstanceTextureVertex)];
		NezInstanceTextureVertex *vDst = self.vertexList;
		NezModelVertex *vSrc = vertexArray.vertexList;
		for (NSInteger i=0; i<vertexCount; i++) {
			vDst[i].position = vSrc[i].position;
			vDst[i].uvIndex = i;
		}
		_instanceData = [NSMutableData dataWithLength:instanceCount*sizeof(NezInstanceAttributeTexture)];
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

-(NezInstanceTextureVertex*)getVertexList {
	return (NezInstanceTextureVertex*)_vertexData.bytes;
}

-(NezInstanceAttributeTexture*)getInstanceAttributeList {
	return (NezInstanceAttributeTexture*)_instanceData.bytes;
}

-(void)enableVertexAttributes {
	[self enableVertexAttributeArrayWithLocation:_program.a_position size:3 stride:sizeof(NezInstanceTextureVertex) andOffset:(void*)offsetof(NezInstanceTextureVertex, position)];
	[self enableVertexAttributeArrayWithLocation:_program.a_uvIndex size:1 stride:sizeof(NezInstanceTextureVertex) andOffset:(void*)offsetof(NezInstanceTextureVertex, uvIndex)];
}

-(void)enableInstanceAttributes {
	[self enableInstancedAttributeArrayWithLocation:_program.a_matrixColumn0 size:4 stride:sizeof(NezInstanceAttributeTexture) andOffset:(void*)offsetof(NezInstanceAttributeTexture, matrix.m00)];
	[self enableInstancedAttributeArrayWithLocation:_program.a_matrixColumn1 size:4 stride:sizeof(NezInstanceAttributeTexture) andOffset:(void*)offsetof(NezInstanceAttributeTexture, matrix.m10)];
	[self enableInstancedAttributeArrayWithLocation:_program.a_matrixColumn2 size:4 stride:sizeof(NezInstanceAttributeTexture) andOffset:(void*)offsetof(NezInstanceAttributeTexture, matrix.m20)];
	[self enableInstancedAttributeArrayWithLocation:_program.a_matrixColumn3 size:4 stride:sizeof(NezInstanceAttributeTexture) andOffset:(void*)offsetof(NezInstanceAttributeTexture, matrix.m30)];
	[self enableInstancedAttributeArrayWithLocation:_program.a_uv0           size:2 stride:sizeof(NezInstanceAttributeTexture) andOffset:(void*)offsetof(NezInstanceAttributeTexture, uv0)];
	[self enableInstancedAttributeArrayWithLocation:_program.a_uv1           size:2 stride:sizeof(NezInstanceAttributeTexture) andOffset:(void*)offsetof(NezInstanceAttributeTexture, uv1)];
	[self enableInstancedAttributeArrayWithLocation:_program.a_uv2           size:2 stride:sizeof(NezInstanceAttributeTexture) andOffset:(void*)offsetof(NezInstanceAttributeTexture, uv2)];
	[self enableInstancedAttributeArrayWithLocation:_program.a_uv3           size:2 stride:sizeof(NezInstanceAttributeTexture) andOffset:(void*)offsetof(NezInstanceAttributeTexture, uv3)];
}

-(void)drawWithGraphics:(NezAletterationGraphics*)graphics {
	NezGLCamera *camera = graphics.drawingViewCamera;

	glUseProgram(_program.program);
	
	if (_textureInfo) {
		glActiveTexture(GL_TEXTURE0);
		glBindTexture(_textureInfo.target, _textureInfo.name);
		glUniform1i(_program.u_texture0, 0);
	}

	glUniformMatrix4fv(_program.u_modelViewProjectionMatrix, 1, 0, camera.modelViewProjectionMatrix.m);
	
	glBindVertexArrayOES(self.vertexArrayObject);
	glDrawElementsInstanced(GL_TRIANGLES, (GLsizei)self.indexCount, GL_UNSIGNED_SHORT, 0, (GLsizei)self.instanceCount);
}

@end
