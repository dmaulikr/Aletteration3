//
//  NezVertexArrayInstancedTransparentColor.m
//  Aletteration3
//
//  Created by David Nesbitt on 2013-09-23.
//  Copyright (c) 2013 David Nesbitt. All rights reserved.
//

#import "NezVertexArrayInstancedTransparentColor.h"
#import "NezAletterationGraphics.h"
#import "NezGLSLProgram.h"
#import "NezGLCamera.h"

@implementation NezVertexArrayInstancedTransparentColor

-(instancetype)initWithObjVertexArray:(NezModelVertexArray*)vertexArray andInstanceCount:(GLsizei)instanceCount {
	if ((self = [super initWithObjVertexArray:vertexArray andInstanceCount:instanceCount])) {
		NSInteger vertexCount = vertexArray.vertexCount;
		_vertexData = [NSMutableData dataWithLength:vertexCount*sizeof(NezVertex)];
		NezVertex *vDst = self.vertexList;
		NezModelVertex *vSrc = vertexArray.vertexList;
		for (NSInteger i=0; i<vertexCount; i++) {
			vDst[i].position = vSrc[i].position;
		}
		_instanceData = [NSMutableData dataWithLength:instanceCount*sizeof(NezInstanceAttributeColor)];
		NezInstanceAttributeColor *aDst = self.instanceAttributeList;
		for (NSInteger i=0; i<instanceCount; i++) {
			aDst[i].matrix = GLKMatrix4Identity;
			aDst[i].color = GLKVector4Make(0.0f, 0.0f, 1.0f, 1.0f);
		}
	}
	return self;
}

-(NezVertex*)getVertexList {
	return (NezVertex*)_vertexData.bytes;
}

-(NezInstanceAttributeColor*)getInstanceAttributeList {
	return (NezInstanceAttributeColor*)_instanceData.bytes;
}

-(void)enableVertexAttributes {
	[self enableVertexAttributeArrayWithLocation:_program.a_position size:3 stride:sizeof(NezVertex) andOffset:(void*)offsetof(NezVertex, position)];
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
	
	glBindVertexArrayOES(self.vertexArrayObject);
	glDrawElementsInstanced(GL_TRIANGLES, (GLsizei)self.indexCount, GL_UNSIGNED_SHORT, 0, (GLsizei)self.instanceCount);
}

@end
