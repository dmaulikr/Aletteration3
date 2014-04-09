//
//  NezInstanceAttributeTypes.h
//  Aletteration3
//
//  Created by David Nesbitt on 10/7/2013.
//  Copyright (c) 2013 David Nesbitt. All rights reserved.
//

#ifndef Aletteration3_NezInstanceAttributeTypes_h
#define Aletteration3_NezInstanceAttributeTypes_h

typedef struct {
	GLKMatrix4 matrix;
} NezInstanceAttributeLocation;

typedef struct {
	GLKMatrix4 matrix;
	GLKVector4 color;
} NezInstanceAttributeColor;

typedef struct {
	GLKMatrix4 matrix;
	GLKVector4 color;
	GLKVector2 uv0;
	GLKVector2 uv1;
	GLKVector2 uv2;
	GLKVector2 uv3;
} NezInstanceAttributeColorTexture;

typedef struct {
	GLKMatrix4 matrix;
	GLKVector4 color;
	GLKVector4 tint;
	GLKVector2 uv0;
	GLKVector2 uv1;
	GLKVector2 uv2;
	GLKVector2 uv3;
} NezInstanceAttributeColorTintTexture;

typedef struct {
	GLKMatrix4 matrix;
	GLKVector2 uv0;
	GLKVector2 uv1;
	GLKVector2 uv2;
	GLKVector2 uv3;
} NezInstanceAttributeTexture;

typedef struct {
	GLKQuaternion orientation;
	GLKQuaternion angularVelocity;
	GLKVector4 color0;
	GLKVector4 color1;
	GLKVector3 offset;
	GLKVector3 velocity;
	GLKVector3 scale;
	GLKVector2 uvScale;
} NezInstanceAttributeGeometryParticle;

#endif
