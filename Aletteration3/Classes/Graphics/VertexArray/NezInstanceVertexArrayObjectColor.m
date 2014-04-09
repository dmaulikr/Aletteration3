//
//  NezInstanceVertexArrayObjectColor.m
//  Aletteration3
//
//  Created by David Nesbitt on 2013/10/07.
//  Copyright (c) 2013 David Nesbitt. All rights reserved.
//

#import "NezInstanceVertexArrayObjectColor.h"
#import "NezVertexBufferObjectVertex.h"
#import "NezInstanceAttributeBufferObjectColor.h"
#import "NezGLCamera.h"
#import "NezGLSLProgram.h"
#import "NezMaterials.h"
#import "NezAletterationGraphics.h"

@implementation NezInstanceVertexArrayObjectColor

-(Class)getVertexBufferObjectClass {
	return [NezVertexBufferObjectVertex class];
}

-(Class)getInstanceAttributeBufferObjectClass {
	return [NezInstanceAttributeBufferObjectColor class];
}

-(NezVertexBufferObjectVertex*)getVertexBufferObject {
	return _vertexBufferObject;
}

-(NezInstanceAttributeBufferObjectColor*)getInstanceAttributeBufferObject {
	return _instanceAttributeBufferObject;
}

-(NezVertex*)getVertexList {
	return self.vertexBufferObject.vertexList;
}

-(NezInstanceAttributeColor*)getInstanceAttributeList {
	return self.instanceAttributeBufferObject.instanceAttributeList;
}

-(void)drawWithGraphics:(NezAletterationGraphics*)graphics {
	NezGLCamera *camera = graphics.drawingViewCamera;
	
	glUseProgram(_program.program);
	
	glUniformMatrix4fv(_program.u_modelViewProjectionMatrix, 1, 0, camera.modelViewProjectionMatrix.m);
	
	glBindVertexArrayOES(self.vertexArrayObject);
	glDrawElementsInstanced(GL_TRIANGLES, self.vertexBufferObject.indexCount, GL_UNSIGNED_SHORT, 0, self.instanceAttributeBufferObject.instanceCount);
}

@end
