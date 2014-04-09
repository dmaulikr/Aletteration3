//
//  NezGLSLProgram.m
//  Aletteration3
//
//  Created by David Nesbitt on 2013-12-19.
//  Copyright 2013 David Nesbitt. All rights reserved.
//

#import "NezGLSLProgram.h"
#import "NezGLSLCompiler.h"

@implementation NezGLSLProgram

-(instancetype)initWithShaderName:(NSString*)shaderName {
	return [self initWithVertexShaderName:shaderName andFragmentShaderName:shaderName];
}

-(instancetype)initWithVertexShaderName:(NSString*)vsh andFragmentShaderName:(NSString*)fsh {
	return [self initWithVertexShaderCompiler:[NezGLSLCompiler compilerWithVertexShader:vsh] andFragmentShaderCompiler:[NezGLSLCompiler compilerWithFragmentShader:fsh]];
}

-(instancetype)initWithVertexShaderCompiler:(NezGLSLCompiler*)vertexShaderCompiler andFragmentShaderCompiler:(NezGLSLCompiler*)fragmentShaderCompiler {
	if ((self = [super init])) {
		[self initializeValues];
		if (vertexShaderCompiler && fragmentShaderCompiler && vertexShaderCompiler.shader && fragmentShaderCompiler.shader) {
			if (![self loadProgramWithVertexShader:vertexShaderCompiler.shader andFragmentShader:fragmentShaderCompiler.shader]) {
				return nil;
			}
		} else {
			return nil;
		}
	}
	return self;
}

-(void)initializeValues {
	_a_position=NEZ_GLSL_ITEM_NOT_SET;
	_a_matrixColumn0=NEZ_GLSL_ITEM_NOT_SET;
	_a_matrixColumn1=NEZ_GLSL_ITEM_NOT_SET;
	_a_matrixColumn2=NEZ_GLSL_ITEM_NOT_SET;
	_a_matrixColumn3=NEZ_GLSL_ITEM_NOT_SET;
	_a_color=NEZ_GLSL_ITEM_NOT_SET;
	_a_uvIndex=NEZ_GLSL_ITEM_NOT_SET;
	_a_uv0=NEZ_GLSL_ITEM_NOT_SET;
	_a_uv1=NEZ_GLSL_ITEM_NOT_SET;
	_a_uv2=NEZ_GLSL_ITEM_NOT_SET;
	_a_uv3=NEZ_GLSL_ITEM_NOT_SET;
	_a_uv=NEZ_GLSL_ITEM_NOT_SET;
	_a_normal=NEZ_GLSL_ITEM_NOT_SET;
	_a_orientation=NEZ_GLSL_ITEM_NOT_SET;
	_a_angularVelocity=NEZ_GLSL_ITEM_NOT_SET;
	_a_color0=NEZ_GLSL_ITEM_NOT_SET;
	_a_color1=NEZ_GLSL_ITEM_NOT_SET;
	_a_velocity=NEZ_GLSL_ITEM_NOT_SET;
	_a_offset=NEZ_GLSL_ITEM_NOT_SET;
	_a_scale=NEZ_GLSL_ITEM_NOT_SET;
	_a_uvScale=NEZ_GLSL_ITEM_NOT_SET;
	_a_modelColor=NEZ_GLSL_ITEM_NOT_SET;
	_a_tint=NEZ_GLSL_ITEM_NOT_SET;
	_a_growth=NEZ_GLSL_ITEM_NOT_SET;
	_a_stable=NEZ_GLSL_ITEM_NOT_SET;
	_a_decay=NEZ_GLSL_ITEM_NOT_SET;
	_u_texture0=NEZ_GLSL_ITEM_NOT_SET;
	_u_texture1=NEZ_GLSL_ITEM_NOT_SET;
	_u_blurRadius=NEZ_GLSL_ITEM_NOT_SET;
	_u_modelViewProjectionMatrix=NEZ_GLSL_ITEM_NOT_SET;
	_u_normalMatrix=NEZ_GLSL_ITEM_NOT_SET;
	_u_acceleration=NEZ_GLSL_ITEM_NOT_SET;
	_u_center=NEZ_GLSL_ITEM_NOT_SET;
	_u_growth=NEZ_GLSL_ITEM_NOT_SET;
	_u_decay=NEZ_GLSL_ITEM_NOT_SET;
	_u_time=NEZ_GLSL_ITEM_NOT_SET;
	_u_lightDirection=NEZ_GLSL_ITEM_NOT_SET;
	_u_specular=NEZ_GLSL_ITEM_NOT_SET;
	_u_shininess=NEZ_GLSL_ITEM_NOT_SET;
	_u_modelViewMatrix=NEZ_GLSL_ITEM_NOT_SET;
	_u_texture=NEZ_GLSL_ITEM_NOT_SET;
	_u_projectionMatrix=NEZ_GLSL_ITEM_NOT_SET;
	_u_screenSize=NEZ_GLSL_ITEM_NOT_SET;
	_u_color0=NEZ_GLSL_ITEM_NOT_SET;
	_u_color1=NEZ_GLSL_ITEM_NOT_SET;
	_u_size=NEZ_GLSL_ITEM_NOT_SET;
}

-(BOOL)loadProgramWithVertexShader:(GLuint)vertexShader andFragmentShader:(GLuint)fragmentShader {
	_program = glCreateProgram();

	glAttachShader(_program, vertexShader);
	glAttachShader(_program, fragmentShader);

	GLint activeAttributeCount;
	glGetProgramiv(_program, GL_ACTIVE_ATTRIBUTES, &activeAttributeCount);

	GLchar itemName[MAX_NAME_LENGTH];
	GLsizei nameLength;
	GLint size;
	GLenum type;

	// Link program
	if (![self linkProgram:_program]) {
		NSLog(@"Failed to link program: %d", _program);
		if (_program) {
			glDeleteProgram(_program);
			_program = 0;
		}
		return FALSE;
	}

	glGetProgramiv(_program, GL_ACTIVE_ATTRIBUTES, &activeAttributeCount);
	for (GLint i=0; i<activeAttributeCount; i++) {
		glGetActiveAttrib(_program, i, MAX_NAME_LENGTH, &nameLength, &size, &type, itemName);
		if (strncmp("a_position", itemName, nameLength) == 0) { _a_position = glGetAttribLocation(_program, itemName); }
		if (strncmp("a_matrixColumn0", itemName, nameLength) == 0) { _a_matrixColumn0 = glGetAttribLocation(_program, itemName); }
		if (strncmp("a_matrixColumn1", itemName, nameLength) == 0) { _a_matrixColumn1 = glGetAttribLocation(_program, itemName); }
		if (strncmp("a_matrixColumn2", itemName, nameLength) == 0) { _a_matrixColumn2 = glGetAttribLocation(_program, itemName); }
		if (strncmp("a_matrixColumn3", itemName, nameLength) == 0) { _a_matrixColumn3 = glGetAttribLocation(_program, itemName); }
		if (strncmp("a_color", itemName, nameLength) == 0) { _a_color = glGetAttribLocation(_program, itemName); }
		if (strncmp("a_uvIndex", itemName, nameLength) == 0) { _a_uvIndex = glGetAttribLocation(_program, itemName); }
		if (strncmp("a_uv0", itemName, nameLength) == 0) { _a_uv0 = glGetAttribLocation(_program, itemName); }
		if (strncmp("a_uv1", itemName, nameLength) == 0) { _a_uv1 = glGetAttribLocation(_program, itemName); }
		if (strncmp("a_uv2", itemName, nameLength) == 0) { _a_uv2 = glGetAttribLocation(_program, itemName); }
		if (strncmp("a_uv3", itemName, nameLength) == 0) { _a_uv3 = glGetAttribLocation(_program, itemName); }
		if (strncmp("a_uv", itemName, nameLength) == 0) { _a_uv = glGetAttribLocation(_program, itemName); }
		if (strncmp("a_normal", itemName, nameLength) == 0) { _a_normal = glGetAttribLocation(_program, itemName); }
		if (strncmp("a_orientation", itemName, nameLength) == 0) { _a_orientation = glGetAttribLocation(_program, itemName); }
		if (strncmp("a_angularVelocity", itemName, nameLength) == 0) { _a_angularVelocity = glGetAttribLocation(_program, itemName); }
		if (strncmp("a_color0", itemName, nameLength) == 0) { _a_color0 = glGetAttribLocation(_program, itemName); }
		if (strncmp("a_color1", itemName, nameLength) == 0) { _a_color1 = glGetAttribLocation(_program, itemName); }
		if (strncmp("a_velocity", itemName, nameLength) == 0) { _a_velocity = glGetAttribLocation(_program, itemName); }
		if (strncmp("a_offset", itemName, nameLength) == 0) { _a_offset = glGetAttribLocation(_program, itemName); }
		if (strncmp("a_scale", itemName, nameLength) == 0) { _a_scale = glGetAttribLocation(_program, itemName); }
		if (strncmp("a_uvScale", itemName, nameLength) == 0) { _a_uvScale = glGetAttribLocation(_program, itemName); }
		if (strncmp("a_modelColor", itemName, nameLength) == 0) { _a_modelColor = glGetAttribLocation(_program, itemName); }
		if (strncmp("a_tint", itemName, nameLength) == 0) { _a_tint = glGetAttribLocation(_program, itemName); }
		if (strncmp("a_growth", itemName, nameLength) == 0) { _a_growth = glGetAttribLocation(_program, itemName); }
		if (strncmp("a_stable", itemName, nameLength) == 0) { _a_stable = glGetAttribLocation(_program, itemName); }
		if (strncmp("a_decay", itemName, nameLength) == 0) { _a_decay = glGetAttribLocation(_program, itemName); }
	}

	GLint activeUniformCount;
	glGetProgramiv(_program, GL_ACTIVE_UNIFORMS, &activeUniformCount);
	for (GLint i=0; i<activeUniformCount; i++) {
		glGetActiveUniform(_program, i, MAX_NAME_LENGTH, &nameLength, &size, &type, itemName);
		// Get uniform locations
		if (strncmp("u_texture0", itemName, nameLength) == 0) { _u_texture0 = glGetUniformLocation(_program, itemName); }
		if (strncmp("u_texture1", itemName, nameLength) == 0) { _u_texture1 = glGetUniformLocation(_program, itemName); }
		if (strncmp("u_blurRadius", itemName, nameLength) == 0) { _u_blurRadius = glGetUniformLocation(_program, itemName); }
		if (strncmp("u_modelViewProjectionMatrix", itemName, nameLength) == 0) { _u_modelViewProjectionMatrix = glGetUniformLocation(_program, itemName); }
		if (strncmp("u_normalMatrix", itemName, nameLength) == 0) { _u_normalMatrix = glGetUniformLocation(_program, itemName); }
		if (strncmp("u_acceleration", itemName, nameLength) == 0) { _u_acceleration = glGetUniformLocation(_program, itemName); }
		if (strncmp("u_center", itemName, nameLength) == 0) { _u_center = glGetUniformLocation(_program, itemName); }
		if (strncmp("u_growth", itemName, nameLength) == 0) { _u_growth = glGetUniformLocation(_program, itemName); }
		if (strncmp("u_decay", itemName, nameLength) == 0) { _u_decay = glGetUniformLocation(_program, itemName); }
		if (strncmp("u_time", itemName, nameLength) == 0) { _u_time = glGetUniformLocation(_program, itemName); }
		if (strncmp("u_lightDirection", itemName, nameLength) == 0) { _u_lightDirection = glGetUniformLocation(_program, itemName); }
		if (strncmp("u_specular", itemName, nameLength) == 0) { _u_specular = glGetUniformLocation(_program, itemName); }
		if (strncmp("u_shininess", itemName, nameLength) == 0) { _u_shininess = glGetUniformLocation(_program, itemName); }
		if (strncmp("u_modelViewMatrix", itemName, nameLength) == 0) { _u_modelViewMatrix = glGetUniformLocation(_program, itemName); }
		if (strncmp("u_texture", itemName, nameLength) == 0) { _u_texture = glGetUniformLocation(_program, itemName); }
		if (strncmp("u_projectionMatrix", itemName, nameLength) == 0) { _u_projectionMatrix = glGetUniformLocation(_program, itemName); }
		if (strncmp("u_screenSize", itemName, nameLength) == 0) { _u_screenSize = glGetUniformLocation(_program, itemName); }
		if (strncmp("u_color0", itemName, nameLength) == 0) { _u_color0 = glGetUniformLocation(_program, itemName); }
		if (strncmp("u_color1", itemName, nameLength) == 0) { _u_color1 = glGetUniformLocation(_program, itemName); }
		if (strncmp("u_size", itemName, nameLength) == 0) { _u_size = glGetUniformLocation(_program, itemName); }
	}
	return TRUE;
}

-(BOOL)linkProgram:(GLuint)prog {
	GLint status;

	glLinkProgram(prog);
#if defined(DEBUG)
	GLint logLength;
	glGetProgramiv(prog, GL_INFO_LOG_LENGTH, &logLength);
	if (logLength > 0) {
		GLchar *log = (GLchar *)malloc(logLength);
		glGetProgramInfoLog(prog, logLength, &logLength, log);
		NSLog(@"Program link log:\n%s", log);
		free(log);
	}
#endif
	glGetProgramiv(prog, GL_LINK_STATUS, &status);
	if (status == 0) {
		return FALSE;
	}
	return TRUE;
}

-(BOOL)validateProgram:(GLuint)prog {
	GLint logLength, status;

	glValidateProgram(prog);
	glGetProgramiv(prog, GL_INFO_LOG_LENGTH, &logLength);
	if (logLength > 0) {
		GLchar *log = (GLchar *)malloc(logLength);
		glGetProgramInfoLog(prog, logLength, &logLength, log);
		NSLog(@"Program validate log:\n%s", log);
		free(log);
	}

	glGetProgramiv(prog, GL_VALIDATE_STATUS, &status);
	if (status == 0) {
		return FALSE;
	}
	return TRUE;
}

-(void)dealloc {
	if (_program) {
		glDeleteProgram(_program);
	}
}

@end

