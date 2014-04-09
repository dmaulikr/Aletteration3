//
//  NezInstanceVertexArrayObjectLitColor.m
//  Aletteration3
//
//  Created by David Nesbitt on 2013/10/07.
//  Copyright (c) 2013 David Nesbitt. All rights reserved.
//

#import "NezInstanceVertexArrayObjectLitColor.h"
#import "NezVertexBufferObjectLitVertex.h"
#import "NezInstanceAttributeBufferObjectColor.h"
#import "NezGLCamera.h"
#import "NezGLSLProgram.h"
#import "NezMaterials.h"
#import "NezAletterationGraphics.h"

@implementation NezInstanceVertexArrayObjectLitColor

-(Class)getVertexBufferObjectClass {
	return [NezVertexBufferObjectLitVertex class];
}

-(Class)getInstanceAttributeBufferObjectClass {
	return [NezInstanceAttributeBufferObjectColor class];
}

-(NezVertexBufferObjectLitVertex*)getVertexBufferObject {
	return _vertexBufferObject;
}

-(NezInstanceAttributeBufferObjectColor*)getInstanceAttributeBufferObject {
	return _instanceAttributeBufferObject;
}

-(NezLitVertex*)getVertexList {
	return self.vertexBufferObject.vertexList;
}

-(NezInstanceAttributeColor*)getInstanceAttributeList {
	return self.instanceAttributeBufferObject.instanceAttributeList;
}

-(void)drawWithGraphics:(NezAletterationGraphics*)graphics {
	NezGLCamera *camera = graphics.drawingViewCamera;
	
	glUseProgram(_program.program);
	
	glUniformMatrix4fv(_program.u_modelViewProjectionMatrix, 1, 0, camera.modelViewProjectionMatrix.m);
	glUniformMatrix4fv(_program.u_modelViewMatrix, 1, 0, camera.modelViewMatrix.m);
	glUniformMatrix3fv(_program.u_normalMatrix, 1, 0, camera.normalMatrix.m);
	
	glUniform4fv(_program.u_specular, 1, self.material.specular.v);
	glUniform1f(_program.u_shininess, self.material.shininess);
	
	GLKVector4 lightDirection = GLKVector4Normalize(GLKMatrix4MultiplyVector4(camera.modelViewMatrix, graphics.lightDirection));
	glUniform3fv(_program.u_lightDirection, 1, lightDirection.v);
	
	glBindVertexArrayOES(self.vertexArrayObject);
	glDrawElementsInstanced(GL_TRIANGLES, self.vertexBufferObject.indexCount, GL_UNSIGNED_SHORT, 0, self.instanceAttributeBufferObject.instanceCount);
}

@end
