//
//  NezQuaternionCamera.h
//  Aletteration3
//
//  Created by David Nesbitt on 2013/10/22.
//  Copyright (c) 2013 David Nesbitt. All rights reserved.
//

#import <GLKit/GLKit.h>
#import "NezRay.h"
#import "NezRestorableObject.h"

typedef enum {
	NezGLCameraZoomToWidth,
	NezGLCameraZoomToHeight,
	NezGLCameraZoomToFarthest,
	NezGLCameraZoomToClosest,
} NezGLCameraZoomOptions;

//Make quaternion from Euler angles in radians
static inline GLKQuaternion GLKQuaternionMakeWithHeadingPitchAndRoll(float heading, float pitch, float roll) {
	double c1 = cos(heading/2);
	double s1 = sin(heading/2);
	double c2 = cos(pitch/2);
	double s2 = sin(pitch/2);
	double c3 = cos(roll/2);
	double s3 = sin(roll/2);
	double c1c2 = c1*c2;
	double s1s2 = s1*s2;
  	double x =c1c2*s3 + s1s2*c3;
	double y =s1*c2*c3 + c1*s2*s3;
	double z =c1*s2*c3 - s1*c2*s3;
	double w =c1c2*c3 - s1s2*s3;
	
	return GLKQuaternionMake(x, y, z, w);
}

@class NezGeometry;

@interface NezGLCamera : NezRestorableObject<NSCoding> {
	float _fovy;
	float _zNear;
	float _zFar;
	float _aspectRatio;
	GLKVector3 _eye;
	int _viewport[4];
}

@property (nonatomic, setter = setOrientation:) GLKQuaternion orientation;
@property (getter = getEye, setter = setEye:) GLKVector3 eye;

@property (readonly) GLKVector3 xAxis;
@property (readonly) GLKVector3 yAxis;
@property (readonly) GLKVector3 zAxis;
@property (readonly) GLKVector3 direction;
@property (readonly) GLKMatrix4 modelViewMatrix;
@property (readonly) GLKMatrix3 normalMatrix;
@property (readonly) GLKMatrix4 projectionMatrix;
@property (readonly) GLKMatrix4 modelViewProjectionMatrix;
@property (readonly, getter = getViewportWidth) float viewportWidth;
@property (readonly, getter = getViewportHeight) float viewportHeight;
@property (readonly, getter = getViewport) CGRect viewport;
@property (nonatomic, setter = setEffectiveViewport:) CGRect effectiveViewport;

-(NezGLCamera*)initWithEye:(GLKVector3)eye Target:(GLKVector3)target UpVector:(GLKVector3)upVector;

+(float)DEFAULT_FOVY;
+(float)DEFAULT_ZNEAR;
+(float)DEFAULT_ZFAR;

-(void)lookAtTarget:(GLKVector3)target;
-(void)lookAtEye:(GLKVector3)eye target:(GLKVector3)target upVector:(GLKVector3)up;
-(void)setEye:(GLKVector3)eye andOrientation:(GLKQuaternion)orientation;
-(void)setDefaultPerspectiveProjectionWithViewport:(CGRect)viewport;
-(void)setPerspectiveProjectionWithFOVY:(float)fovy viewport:(CGRect)viewport zNear:(float)zNear zFar:(float)zFar;

-(GLKVector2)getScreenCoordinates:(GLKVector3)pos;
-(GLKVector3)getWorldCoordinates:(GLKVector2)screenPos atWorldZ:(float)z;
-(NezRay*)getWorldRay:(GLKVector2)screenPos;

-(void)lookAtGeometry:(NezGeometry*)geometry withZoomOptions:(NezGLCameraZoomOptions)options;
-(void)stopLookingAtGeometry;

@end
