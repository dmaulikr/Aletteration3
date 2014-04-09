//
//  NezGLSLProgram.h
//  Aletteration3
//
//  Created by David Nesbitt on 2013-12-19.
//  Copyright 2013 David Nesbitt. All rights reserved.
//

#import <OpenGLES/ES3/gl.h>
#import <OpenGLES/ES3/glext.h>

#define MAX_NAME_LENGTH 128

#define NEZ_GLSL_ITEM_NOT_SET -1

@class NezGLSLCompiler;

@interface NezGLSLProgram : NSObject {
}

@property (readonly) GLuint program;

@property (readonly) GLint a_position;
@property (readonly) GLint a_matrixColumn0;
@property (readonly) GLint a_matrixColumn1;
@property (readonly) GLint a_matrixColumn2;
@property (readonly) GLint a_matrixColumn3;
@property (readonly) GLint a_color;
@property (readonly) GLint a_uvIndex;
@property (readonly) GLint a_uv0;
@property (readonly) GLint a_uv1;
@property (readonly) GLint a_uv2;
@property (readonly) GLint a_uv3;
@property (readonly) GLint a_uv;
@property (readonly) GLint a_normal;
@property (readonly) GLint a_orientation;
@property (readonly) GLint a_angularVelocity;
@property (readonly) GLint a_color0;
@property (readonly) GLint a_color1;
@property (readonly) GLint a_velocity;
@property (readonly) GLint a_offset;
@property (readonly) GLint a_scale;
@property (readonly) GLint a_uvScale;
@property (readonly) GLint a_modelColor;
@property (readonly) GLint a_tint;
@property (readonly) GLint a_growth;
@property (readonly) GLint a_stable;
@property (readonly) GLint a_decay;

@property (readonly) GLint u_texture0;
@property (readonly) GLint u_texture1;
@property (readonly) GLint u_blurRadius;
@property (readonly) GLint u_modelViewProjectionMatrix;
@property (readonly) GLint u_normalMatrix;
@property (readonly) GLint u_acceleration;
@property (readonly) GLint u_center;
@property (readonly) GLint u_growth;
@property (readonly) GLint u_decay;
@property (readonly) GLint u_time;
@property (readonly) GLint u_lightDirection;
@property (readonly) GLint u_specular;
@property (readonly) GLint u_shininess;
@property (readonly) GLint u_modelViewMatrix;
@property (readonly) GLint u_texture;
@property (readonly) GLint u_projectionMatrix;
@property (readonly) GLint u_screenSize;
@property (readonly) GLint u_color0;
@property (readonly) GLint u_color1;
@property (readonly) GLint u_size;

-(instancetype)initWithShaderName:(NSString*)shaderName;
-(instancetype)initWithVertexShaderName:(NSString*)vsh andFragmentShaderName:(NSString*)fsh;
-(instancetype)initWithVertexShaderCompiler:(NezGLSLCompiler*)vertexShaderCompiler andFragmentShaderCompiler:(NezGLSLCompiler*)fragmentShaderCompiler;

@end
