//
//  NezGeometry.h
//  Aletteration3
//
//  Created by David Nesbitt on 2013-09-23.
//  Copyright (c) 2013 David Nesbitt. All rights reserved.
//

#import <GLKit/GLKit.h>
#import "NezAnimationPath3d.h"

static const float NEZ_FLOATING_POINT_EPSILON = 1e-6f;

static inline BOOL isCloseEnough(double a, double b) {
	return fabsf((a - b) / ((b == 0.0f) ? 1.0f : b)) < NEZ_FLOATING_POINT_EPSILON;
}

static inline GLKMatrix4 GLKMatrix4MakeWithQuaternionAndPostion(GLKQuaternion orientation, GLKVector3 center) {
	GLKMatrix4 matrix = GLKMatrix4MakeWithQuaternion(orientation);
	matrix.m30 = center.x;
	matrix.m31 = center.y;
	matrix.m32 = center.z;
	return matrix;
}

typedef union {
	struct {
		GLKVector3 min;
		GLKVector3 max;
	};
	GLKVector3 bounds[2];
} NezBoundingBox;

@class NezRay;
@class NezPath3d;
@class NezGLCamera;

@interface NezGeometry : NSObject {
	GLKMatrix4 _modelMatrix;
	GLKVector3 _dimensions;
	NezBoundingBox _aabb;
	BOOL _boundsNeedUpdate;
}

@property (getter = getCenter, setter = setCenter:) GLKVector3 center;
@property (getter = getModelMatrix, setter = setModelMatrix:) GLKMatrix4 modelMatrix;
@property GLKVector3 dimensions;
@property (readonly, getter = getOrientation) GLKQuaternion orientation;
@property (readonly, getter = getAABB) NezBoundingBox aabb;

-(instancetype)initWithDimensions:(GLKVector3)dimensions;

-(void)setModelMatrixForOrientation:(GLKQuaternion)orientation andCenter:(GLKVector3)center;

-(BOOL)intersect:(NezRay*)ray;
-(BOOL)intersect:(NezRay*)ray withExtraSize:(float)size;

-(GLKVector3)modelCoordinateForPoint:(GLKVector3)point;

-(NezAnimationPath3d*)animationForPath:(NezPath3d*)path FinalOrientation:(GLKQuaternion)finalOrientation Duration:(CFTimeInterval)d EasingFunction:(EasingFunctionPtr)func andDidStopBlock:(NezAnimationBlock)didStopBlock;

@end
