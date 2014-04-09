//
//  NezVertexArrayInstancedLitAmbientSpecularPerPixelTexture.m
//  Aletteration3
//
//  Created by David Nesbitt on 2013-09-24.
//  Copyright (c) 2013 David Nesbitt. All rights reserved.
//

#import "NezVertexArrayInstancedAbstract.h"
#import "NezVertexArrayInstancedLitColorTexturePerPixel.h"
#import "NezAletterationGraphics.h"
#import "NezGLSLProgram.h"
#import "NezGLCamera.h"

@implementation NezVertexArrayInstancedLitColorTexturePerPixel

-(instancetype)initWithObjVertexArray:(NezModelVertexArray*)vertexArray andInstanceCount:(GLsizei)instanceCount {
	if ((self = [super initWithObjVertexArray:vertexArray andInstanceCount:instanceCount])) {
		NSInteger vertexCount = vertexArray.vertexCount;
		_vertexData = [NSMutableData dataWithLength:vertexCount*sizeof(NezLitInstanceTextureVertex)];
		NezLitInstanceTextureVertex *vDst = self.vertexList;
		NezModelVertex *vSrc = vertexArray.vertexList;
		for (NSInteger i=0; i<vertexCount; i++) {
			vDst[i].position = vSrc[i].position;
			vDst[i].normal = vSrc[i].normal;
			vDst[i].uvIndex = i;
		}
		_instanceData = [NSMutableData dataWithLength:instanceCount*sizeof(NezInstanceAttributeColorTexture)];
		NezInstanceAttributeColorTexture *aDst = self.instanceAttributeList;
		for (NSInteger i=0; i<instanceCount; i++) {
			aDst[i].matrix = GLKMatrix4Identity;
			aDst[i].uv0 = GLKVector2Make(0.0f, 0.0f);
			aDst[i].uv1 = GLKVector2Make(0.0f, 0.0f);
			aDst[i].uv2 = GLKVector2Make(0.0f, 0.0f);
			aDst[i].uv3 = GLKVector2Make(0.0f, 0.0f);
			aDst[i].color = GLKVector4Make(0.0f, 0.0f, 0.0f, 0.0f);
		}
	}
	return self;
}

-(NezLitInstanceTextureVertex*)getVertexList {
	return (NezLitInstanceTextureVertex*)_vertexData.bytes;
}

-(NezInstanceAttributeColorTexture*)getInstanceAttributeList {
	return (NezInstanceAttributeColorTexture*)_instanceData.bytes;
}

-(void)enableVertexAttributes {
	[self enableVertexAttributeArrayWithLocation:_program.a_position size:3 stride:sizeof(NezLitInstanceTextureVertex) andOffset:(void*)offsetof(NezLitInstanceTextureVertex, position)];
	[self enableVertexAttributeArrayWithLocation:_program.a_normal size:3 stride:sizeof(NezLitInstanceTextureVertex) andOffset:(void*)offsetof(NezLitInstanceTextureVertex, normal)];
	[self enableVertexAttributeArrayWithLocation:_program.a_uvIndex size:1 stride:sizeof(NezLitInstanceTextureVertex) andOffset:(void*)offsetof(NezLitInstanceTextureVertex, uvIndex)];
}

-(void)enableInstanceAttributes {
	[self enableInstancedAttributeArrayWithLocation:_program.a_matrixColumn0 size:4 stride:sizeof(NezInstanceAttributeColorTexture) andOffset:(void*)offsetof(NezInstanceAttributeColorTexture, matrix.m00)];
	[self enableInstancedAttributeArrayWithLocation:_program.a_matrixColumn1 size:4 stride:sizeof(NezInstanceAttributeColorTexture) andOffset:(void*)offsetof(NezInstanceAttributeColorTexture, matrix.m10)];
	[self enableInstancedAttributeArrayWithLocation:_program.a_matrixColumn2 size:4 stride:sizeof(NezInstanceAttributeColorTexture) andOffset:(void*)offsetof(NezInstanceAttributeColorTexture, matrix.m20)];
	[self enableInstancedAttributeArrayWithLocation:_program.a_matrixColumn3 size:4 stride:sizeof(NezInstanceAttributeColorTexture) andOffset:(void*)offsetof(NezInstanceAttributeColorTexture, matrix.m30)];
	[self enableInstancedAttributeArrayWithLocation:_program.a_uv0           size:2 stride:sizeof(NezInstanceAttributeColorTexture) andOffset:(void*)offsetof(NezInstanceAttributeColorTexture, uv0)];
	[self enableInstancedAttributeArrayWithLocation:_program.a_uv1           size:2 stride:sizeof(NezInstanceAttributeColorTexture) andOffset:(void*)offsetof(NezInstanceAttributeColorTexture, uv1)];
	[self enableInstancedAttributeArrayWithLocation:_program.a_uv2           size:2 stride:sizeof(NezInstanceAttributeColorTexture) andOffset:(void*)offsetof(NezInstanceAttributeColorTexture, uv2)];
	[self enableInstancedAttributeArrayWithLocation:_program.a_uv3           size:2 stride:sizeof(NezInstanceAttributeColorTexture) andOffset:(void*)offsetof(NezInstanceAttributeColorTexture, uv3)];
	[self enableInstancedAttributeArrayWithLocation:_program.a_modelColor    size:4 stride:sizeof(NezInstanceAttributeColorTexture) andOffset:(void*)offsetof(NezInstanceAttributeColorTexture, color)];
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
	glUniformMatrix4fv(_program.u_modelViewMatrix, 1, 0, camera.viewMatrix.m);
	glUniformMatrix3fv(_program.u_normalMatrix, 1, 0, camera.normalMatrix.m);
	
	glUniform4fv(_program.u_specular, 1, _material.specular.v);
	glUniform1f(_program.u_shininess, _material.shininess);
	
	GLKVector4 lightDirection = GLKVector4Normalize(GLKMatrix4MultiplyVector4(camera.viewMatrix, graphics.lightDirection));
	glUniform3fv(_program.u_lightDirection, 1, lightDirection.v);
	
	glBindVertexArrayOES(self.vertexArrayObject);
	glDrawElementsInstanced(GL_TRIANGLES, (GLsizei)self.indexCount, GL_UNSIGNED_SHORT, 0, (GLsizei)self.instanceCount);
}

@end
