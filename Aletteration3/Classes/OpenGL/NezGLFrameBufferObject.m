//
//  NezGLFrameBufferObject.m
//  Aletteration3
//
//  Created by David Nesbitt on 2013-10-04.
//  Copyright (c) 2013 David Nesbitt. All rights reserved.
//

#import "NezGLFrameBufferObject.h"

@implementation NezGLFrameBufferObject

-(instancetype)initWithWidth:(GLuint)width andHeight:(GLuint)height {
	if ((self = [super init])) {
		_width = width;
		_height = height;
		
		[self generateFrameBufferObject];
	}
	return self;
}

-(void)deleteAttachment:(GLenum)attachment {
    GLint param;
    GLuint objName;
	
    glGetFramebufferAttachmentParameteriv(GL_FRAMEBUFFER, attachment, GL_FRAMEBUFFER_ATTACHMENT_OBJECT_TYPE, &param);
	
    if(GL_RENDERBUFFER == param) {
        glGetFramebufferAttachmentParameteriv(GL_FRAMEBUFFER, attachment, GL_FRAMEBUFFER_ATTACHMENT_OBJECT_NAME, &param);
        objName = ((GLuint*)(&param))[0];
        glDeleteRenderbuffers(1, &objName);
    } else if(GL_TEXTURE == param) {
        glGetFramebufferAttachmentParameteriv(GL_FRAMEBUFFER, attachment, GL_FRAMEBUFFER_ATTACHMENT_OBJECT_NAME, &param);
        objName = ((GLuint*)(&param))[0];
        glDeleteTextures(1, &objName);
    }
}

-(void)deleteFrameBufferObject {
	if(!_frameBufferObject) {
		return;
	}
    glBindFramebuffer(GL_FRAMEBUFFER, _frameBufferObject);
	
	[self deleteAttachment:(GL_COLOR_ATTACHMENT0)];
    [self deleteAttachment:GL_DEPTH_ATTACHMENT];
	
    glDeleteFramebuffers(1, &_frameBufferObject);
	
	_frameBufferObject = 0;
	_colorRenderTexture = 0;
	_depthRenderBuffer = 0;
}

-(void)generateFrameBufferObject {
	[self deleteFrameBufferObject];
	glGenFramebuffers(1, &_frameBufferObject);
}

-(void)generateRenderTexture:(GLuint*)textureNamePtr textureFormat:(GLenum)textureFormat isMipMapped:(BOOL)isMipMapped {
	// Create a texture object to apply to model
	glGenTextures(1, textureNamePtr);
	glBindTexture(GL_TEXTURE_2D, *textureNamePtr);
	
	// Set up filter and wrap modes for this texture object
	glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_WRAP_S, GL_CLAMP_TO_EDGE);
	glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_WRAP_T, GL_CLAMP_TO_EDGE);
	glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_MAG_FILTER, GL_LINEAR);
	
	//Mip mapping does not work on non power of 2 textures (at least on iPod Touch 5G)
	if (isMipMapped && _width == _height && [self isPowerOf2:_width]) {
		glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_MIN_FILTER, GL_LINEAR_MIPMAP_LINEAR);
	} else {
		glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_MIN_FILTER, GL_LINEAR);
	}
}

-(void)generateColorRenderTexture:(GLenum)textureFormat {
	[self generateRenderTexture:&_colorRenderTexture textureFormat:textureFormat isMipMapped:YES];
	glTexImage2D(GL_TEXTURE_2D, 0, textureFormat, _width, _height, 0, textureFormat, GL_UNSIGNED_BYTE, NULL);
}

-(void)generateDepthRenderBuffer:(GLenum)depthComponent {
	glGenRenderbuffers(1, &_depthRenderBuffer);
	glBindRenderbuffer(GL_RENDERBUFFER, _depthRenderBuffer);
	glRenderbufferStorage(GL_RENDERBUFFER, depthComponent, _width, _height);
}

-(void)generateDepthRenderTexture {
	[self generateRenderTexture:&_depthRenderTexture textureFormat:GL_DEPTH_COMPONENT isMipMapped:NO];
	glTexImage2D(GL_TEXTURE_2D, 0, GL_DEPTH_COMPONENT, _width, _height, 0, GL_DEPTH_COMPONENT, GL_UNSIGNED_SHORT, NULL);
}

-(BOOL)attachBuffers {
	if (_frameBufferObject) {
		glBindFramebuffer(GL_FRAMEBUFFER, _frameBufferObject);
		if (_colorRenderTexture) {
			glFramebufferTexture2D(GL_FRAMEBUFFER, GL_COLOR_ATTACHMENT0, GL_TEXTURE_2D, _colorRenderTexture, 0);
		}
		if (_depthRenderBuffer) {
			glFramebufferRenderbuffer(GL_FRAMEBUFFER, GL_DEPTH_ATTACHMENT, GL_RENDERBUFFER, _depthRenderBuffer);
			if (_depthRenderTexture) {
				glFramebufferTexture2D(GL_FRAMEBUFFER, GL_DEPTH_ATTACHMENT, GL_TEXTURE_2D, _depthRenderTexture, 0);
			}
		}
		if(glCheckFramebufferStatus(GL_FRAMEBUFFER) != GL_FRAMEBUFFER_COMPLETE) {
			NSLog(@"failed to make complete framebuffer object %x", glCheckFramebufferStatus(GL_FRAMEBUFFER));
			return NO;
		}
	}
	return NO;
}

-(BOOL)isPowerOf2:(GLuint)x {
	return x && !(x & (x - 1));
}

-(void)dealloc {
	[self deleteFrameBufferObject];
}

@end
