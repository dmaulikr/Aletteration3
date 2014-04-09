//
//  NezInstanceVertexArrayObjectTexture.m
//  Aletteration3
//
//  Created by David Nesbitt on 2013/10/07.
//  Copyright (c) 2013 David Nesbitt. All rights reserved.
//

#import "NezInstanceVertexArrayObjectTexture.h"
#import "NezVertexBufferObjectInstanceTextureVertex.h"
#import "NezInstanceAttributeBufferObjectTexture.h"
#import "NezGLCamera.h"
#import "NezGLSLProgram.h"
#import "NezMaterials.h"
#import "NezAletterationGraphics.h"

@implementation NezInstanceVertexArrayObjectTexture

-(Class)getVertexBufferObjectClass {
	return [NezVertexBufferObjectInstanceTextureVertex class];
}

-(Class)getInstanceAttributeBufferObjectClass {
	return [NezInstanceAttributeBufferObjectTexture class];
}

-(NezVertexBufferObjectInstanceTextureVertex*)getVertexBufferObject {
	return _vertexBufferObject;
}

-(NezInstanceAttributeBufferObjectTexture*)getInstanceAttributeBufferObject {
	return _instanceAttributeBufferObject;
}

-(NezInstanceTextureVertex*)getVertexList {
	return self.vertexBufferObject.vertexList;
}

-(NezInstanceAttributeTexture*)getInstanceAttributeList {
	return self.instanceAttributeBufferObject.instanceAttributeList;
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
	glDrawElementsInstanced(GL_TRIANGLES, self.vertexBufferObject.indexCount, GL_UNSIGNED_SHORT, 0, self.instanceAttributeBufferObject.instanceCount);
}

@end
