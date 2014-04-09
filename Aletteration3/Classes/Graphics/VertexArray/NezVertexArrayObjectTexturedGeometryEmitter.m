//
//  NezVertexArrayObjectCircularRaysEmitter.m
//  Aletteration3
//
//  Created by David Nesbitt on 2013/12/18.
//  Copyright (c) 2013 David Nesbitt. All rights reserved.
//

#import "NezVertexArrayObjectTexturedGeometryEmitter.h"
#import "NezVertexBufferObjectLitTextureVertex.h"
#import "NezInstanceAttributeBufferObjectGeometryParticle.h"
#import "NezGLCamera.h"
#import "NezGLSLProgram.h"
#import "NezMaterials.h"
#import "NezAletterationGraphics.h"

@implementation NezVertexArrayObjectTexturedGeometryEmitter

-(instancetype)initWithVertexBufferObject:(NezVertexBufferObjectLitTextureVertex*)vertexBufferObject andInstanceAttributeBufferObject:(NezInstanceAttributeBufferObjectGeometryParticle*)instanceAttributeBufferObject {
	if ((self = [super initWithVertexBufferObject:vertexBufferObject andInstanceAttributeBufferObject:instanceAttributeBufferObject])) {
	}
	return self;
}

-(Class)getVertexBufferObjectClass {
	return [NezVertexBufferObjectLitTextureVertex class];
}

-(Class)getInstanceAttributeBufferObjectClass {
	return [NezInstanceAttributeBufferObjectGeometryParticle class];
}

-(NezVertexBufferObjectLitTextureVertex*)getVertexBufferObject {
	return _vertexBufferObject;
}

-(NezInstanceAttributeBufferObjectGeometryParticle*)getInstanceAttributeBufferObject {
	return _instanceAttributeBufferObject;
}

-(NezLitTextureVertex*)getVertexList {
	return self.vertexBufferObject.vertexList;
}

-(NezInstanceAttributeGeometryParticle*)getInstanceAttributeList {
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
	glUniformMatrix3fv(_program.u_normalMatrix, 1, 0, camera.normalMatrix.m);
	
	glUniform1f(_program.u_time, _time);
	glUniform1f(_program.u_growth, _growth);
	glUniform1f(_program.u_decay, _decay);
	glUniform3fv(_program.u_center, 1, _center.v);
	
	glBindVertexArrayOES(self.vertexArrayObject);
	glDrawElementsInstanced(GL_TRIANGLES, self.vertexBufferObject.indexCount, GL_UNSIGNED_SHORT, 0, self.instanceAttributeBufferObject.instanceCount);
}

@end
