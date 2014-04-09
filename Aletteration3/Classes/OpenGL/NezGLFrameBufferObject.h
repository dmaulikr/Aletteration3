//
//  NezGLFrameBufferObject.h
//  Aletteration3
//
//  Created by David Nesbitt on 2013-10-04.
//  Copyright (c) 2013 David Nesbitt. All rights reserved.
//

#import <GLKit/GLKit.h>
#import <OpenGLES/ES3/gl.h>
#import <OpenGLES/ES3/glext.h>

@interface NezGLFrameBufferObject : NSObject {
	
}

@property (readonly) GLuint frameBufferObject;
@property (readonly) GLuint colorRenderTexture;
@property (readonly) GLuint depthRenderBuffer;
@property (readonly) GLuint depthRenderTexture;

@property GLuint width;
@property GLuint height;

-(instancetype)initWithWidth:(GLuint)width andHeight:(GLuint)height;

-(void)deleteFrameBufferObject;
-(void)generateFrameBufferObject;
-(void)generateColorRenderTexture:(GLenum)textureFormat;
-(void)generateDepthRenderBuffer:(GLenum)depthComponent;
-(void)generateDepthRenderTexture;
-(BOOL)attachBuffers;

@end
