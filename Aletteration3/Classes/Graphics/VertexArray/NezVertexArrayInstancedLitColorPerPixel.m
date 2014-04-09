//
//  NezVertexArrayInstancedLitAmbientSpecularPerPixel.m
//  Aletteration3
//
//  Created by David Nesbitt on 2013-09-24.
//  Copyright (c) 2013 David Nesbitt. All rights reserved.
//

#import "NezVertexArrayInstancedLitColorPerPixel.h"
#import "NezAletterationGraphics.h"
#import "NezGLSLProgram.h"
#import "NezGLCamera.h"

@implementation NezVertexArrayInstancedLitColorPerPixel

-(instancetype)initWithObjVertexArray:(NezModelVertexArray*)vertexArray andInstanceCount:(GLsizei)instanceCount {
	if ((self = [super initWithObjVertexArray:vertexArray andInstanceCount:instanceCount])) {
		NSInteger vertexCount = vertexArray.vertexCount;
		_vertexData = [NSMutableData dataWithLength:vertexCount*sizeof(NezLitVertex)];
		NezLitVertex *vDst = self.vertexList;
		NezModelVertex *vSrc = vertexArray.vertexList;
		for (NSInteger i=0; i<vertexCount; i++) {
			vDst[i].position = vSrc[i].position;
			vDst[i].normal = vSrc[i].normal;
		}
		_instanceData = [NSMutableData dataWithLength:instanceCount*sizeof(NezInstanceAttributeColor)];
		NezInstanceAttributeColor *aDst = self.instanceAttributeList;
		for (NSInteger i=0; i<instanceCount; i++) {
			aDst[i].matrix = GLKMatrix4Identity;
			aDst[i].color = GLKVector4Make(0.0f, 0.0f, 0.0f, 0.0f);
		}
	}
	return self;
}

-(NezLitVertex*)getVertexList {
	return (NezLitVertex*)_vertexData.bytes;
}

-(NezInstanceAttributeColor*)getInstanceAttributeList {
	return (NezInstanceAttributeColor*)_instanceData.bytes;
}

-(void)enableVertexAttributes {
	[self enableVertexAttributeArrayWithLocation:_program.a_position size:3 stride:sizeof(NezLitVertex) andOffset:(void*)offsetof(NezLitVertex, position)];
	[self enableVertexAttributeArrayWithLocation:_program.a_normal   size:3 stride:sizeof(NezLitVertex) andOffset:(void*)offsetof(NezLitVertex, normal)];
}

-(void)enableInstanceAttributes {
	[self enableInstancedAttributeArrayWithLocation:_program.a_matrixColumn0 size:4 stride:sizeof(NezInstanceAttributeColor) andOffset:(void*)offsetof(NezInstanceAttributeColor, matrix.m00)];
	[self enableInstancedAttributeArrayWithLocation:_program.a_matrixColumn1 size:4 stride:sizeof(NezInstanceAttributeColor) andOffset:(void*)offsetof(NezInstanceAttributeColor, matrix.m10)];
	[self enableInstancedAttributeArrayWithLocation:_program.a_matrixColumn2 size:4 stride:sizeof(NezInstanceAttributeColor) andOffset:(void*)offsetof(NezInstanceAttributeColor, matrix.m20)];
	[self enableInstancedAttributeArrayWithLocation:_program.a_matrixColumn3 size:4 stride:sizeof(NezInstanceAttributeColor) andOffset:(void*)offsetof(NezInstanceAttributeColor, matrix.m30)];
	[self enableInstancedAttributeArrayWithLocation:_program.a_modelColor    size:4 stride:sizeof(NezInstanceAttributeColor) andOffset:(void*)offsetof(NezInstanceAttributeColor, color)];
}

-(void)drawWithGraphics:(NezAletterationGraphics*)graphics {
	NezGLCamera *camera = graphics.drawingViewCamera;
	
	glUseProgram(_program.program);
	
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
