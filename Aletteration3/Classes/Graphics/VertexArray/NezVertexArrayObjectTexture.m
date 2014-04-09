//
//  NezInstanceVertexArrayObjectTextureColor.m
//  Aletteration3
//
//  Created by David Nesbitt on 2013/10/21.
//  Copyright (c) 2013 David Nesbitt. All rights reserved.
//

#import "NezVertexArrayObjectTexture.h"
#import "NezVertexBufferObjectTextureVertex.h"
#import "NezInstanceAttributeBufferObjectColor.h"
#import "NezGLCamera.h"
#import "NezGLSLProgram.h"
#import "NezMaterials.h"
#import "NezAletterationGraphics.h"

@implementation NezVertexArrayObjectTexture

-(instancetype)initWithVertexBufferObject:(NezVertexBufferObjectTextureVertex*)vertexBufferObject {
	if ((self = [super initWithVertexBufferObject:vertexBufferObject])) {
	}
	return self;
}

-(Class)getVertexBufferObjectClass {
	return [NezVertexBufferObjectTextureVertex class];
}

-(NezVertexBufferObjectTextureVertex*)getVertexBufferObject {
	return _vertexBufferObject;
}

-(NezTextureVertex*)getVertexList {
	return self.vertexBufferObject.vertexList;
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
	glUniformMatrix4fv(_program.u_modelViewProjectionMatrix, 1, 0, camera.modelViewProjectionMatrix.m);
	
	glBindVertexArrayOES(self.vertexArrayObject);
	glDrawElements(GL_TRIANGLES, self.vertexBufferObject.indexCount, GL_UNSIGNED_SHORT, 0);
}

@end
