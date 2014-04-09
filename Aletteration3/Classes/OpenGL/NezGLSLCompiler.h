//
//  NezGLSLCompiler.h
//  Aletteration3
//
//  Created by David Nesbitt on 2013-12-19.
//  Copyright 2013 David Nesbitt. All rights reserved.
//

#import <OpenGLES/ES3/gl.h>
#import <OpenGLES/ES3/glext.h>

@interface NezGLSLCompiler : NSObject {
}

@property (readonly) GLuint shader;

+(instancetype)compilerWithVertexShader:(NSString*)vsh;
+(instancetype)compilerWithFragmentShader:(NSString*)fsh;

-(instancetype)initWithVertexShader:(NSString*)vsh;
-(instancetype)initWithFragmentShader:(NSString*)fsh;

@end
