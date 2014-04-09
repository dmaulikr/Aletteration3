//
//  NezVertexArrayObjectParticleEmitter.m
//  Aletteration3
//
//  Created by David Nesbitt on 2013/11/27.
//  Copyright (c) 2013 David Nesbitt. All rights reserved.
//

#import "NezVertexArrayObjectAcceleratingParticleEmitter.h"
#import "NezVertexBufferObjectParticleVertex.h"
#import "NezGLCamera.h"
#import "NezGLSLProgram.h"
#import "NezMaterials.h"
#import "NezAletterationGraphics.h"

@implementation NezVertexArrayObjectAcceleratingParticleEmitter

-(void)drawWithGraphics:(NezAletterationGraphics*)graphics {
	NezGLCamera *camera = graphics.drawingViewCamera;
	
	glUseProgram(_program.program);
	
	if (_textureInfo) {
		glActiveTexture(GL_TEXTURE0);
		glBindTexture(_textureInfo.target, _textureInfo.name);
		glUniform1i(_program.u_texture0, 0);
	}
	glUniform2f(_program.u_screenSize, camera.viewportWidth, camera.viewportHeight);
	
	glUniformMatrix4fv(_program.u_modelViewMatrix, 1, 0, camera.modelViewMatrix.m);
	glUniformMatrix4fv(_program.u_projectionMatrix, 1, 0, camera.projectionMatrix.m);
	
	glUniform4fv(_program.u_color0, 1, _color0.v);
	glUniform4fv(_program.u_color1, 1, _color1.v);
	glUniform1f(_program.u_size, _size);
	glUniform1f(_program.u_time, _time);
	glUniform3fv(_program.u_acceleration, 1, _acceleration.v);
	glUniform3fv(_program.u_center, 1, _center.v);
	glUniform1f(_program.u_growth, _growth);
	glUniform1f(_program.u_decay, _decay);
	
	glBindVertexArrayOES(self.vertexArrayObject);
	glDrawElements(GL_POINTS, self.vertexBufferObject.indexCount, GL_UNSIGNED_SHORT, 0);
}

@end
