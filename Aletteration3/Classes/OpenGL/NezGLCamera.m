//
//  NezQuaternionCamera.m
//  Aletteration3
//
//  Created by David Nesbitt on 2013/10/22.
//  Copyright (c) 2013 David Nesbitt. All rights reserved.
//

#import "NezGLCamera.h"
#import "NezAletterationGraphics.h"
#import "NezGeometry.h"

const float DEFAULT_Z_DISTANCE = 8.0f;

const float DEFAULT_FOVY = 65.0f;
const float DEFAULT_ZNEAR = 0.1f;
const float DEFAULT_ZFAR = 1000.0f;
const GLKVector3 WORLD_XAXIS = {1.0f, 0.0f, 0.0f};
const GLKVector3 WORLD_YAXIS = {0.0f, 1.0f, 0.0f};
const GLKVector3 WORLD_ZAXIS = {0.0f, 0.0f, 1.0f};

typedef struct {
	float fovy;
	float zNear;
	float zFar;
	float aspectRatio;
	GLKVector3 eye;
	int viewport[4];
	float unitsPerPointAtDefaultDistance;
	
	GLKQuaternion orientation;
	GLKVector3 xAxis;
	GLKVector3 yAxis;
	GLKVector3 zAxis;
	GLKVector3 direction;
	GLKMatrix4 modelViewMatrix;
	GLKMatrix3 normalMatrix;
	GLKMatrix4 projectionMatrix;
	GLKMatrix4 modelViewProjectionMatrix;
} NezGLCameraStruct;

@interface NezGLCamera() {
	__weak NezGeometry *_currentGeometryTarget;
	NezGLCameraZoomOptions _currentZoomOptions;
}

@property float unitsPerPointAtDefaultDistance;

@end;

@implementation NezGLCamera

+(float)DEFAULT_FOVY {
	return DEFAULT_FOVY;
}

+(float)DEFAULT_ZNEAR {
	return DEFAULT_ZNEAR;
}

+(float)DEFAULT_ZFAR {
	return DEFAULT_ZFAR;
}

-(instancetype)initWithEye:(GLKVector3)eye Target:(GLKVector3)target UpVector:(GLKVector3)upVector {
	if ((self = [self init])) {
		[self lookAtEye:eye target:target upVector:upVector];
	}
	return self;
}

-(instancetype)init {
	if ((self = [super init])) {
		_fovy = DEFAULT_FOVY;
		_zNear = DEFAULT_ZNEAR;
		_zFar = DEFAULT_ZFAR;
		_aspectRatio = 0.0f;
		
		_eye = GLKVector3Make(0.0f, 0.0f, 0.0f);
		_xAxis = GLKVector3Make(1.0f, 0.0f, 0.0f);
		_yAxis = GLKVector3Make(0.0f, 1.0f, 0.0f);
		_zAxis = GLKVector3Make(0.0f, 0.0f, 1.0f);
		_direction = GLKVector3Make(0.0f, 0.0f, -1.0f);
		
		_orientation = GLKQuaternionIdentity;
		
		_modelViewMatrix = GLKMatrix4Identity;
		_projectionMatrix = GLKMatrix4Identity;
	}
	return self;
}

-(void)encodeWithCoder:(NSCoder*)coder {
	[self encodeRestorableStateWithCoder:coder];
}

-(id)initWithCoder:(NSCoder*)coder {
	if ((self = [super init])) {
		[self decodeRestorableStateWithCoder:coder];
	}
	return self;
}

-(void)encodeRestorableStateWithCoder:(NSCoder*)coder {

	NezGLCameraStruct cameraStruct;
	
	cameraStruct.fovy = _fovy;
	cameraStruct.zNear = _zNear;
	cameraStruct.zFar = _zFar;
	cameraStruct.aspectRatio = _aspectRatio;
	cameraStruct.eye = _eye;
	cameraStruct.viewport[0] = _viewport[0];
	cameraStruct.viewport[1] = _viewport[1];
	cameraStruct.viewport[2] = _viewport[2];
	cameraStruct.viewport[3] = _viewport[3];
	cameraStruct.unitsPerPointAtDefaultDistance = _unitsPerPointAtDefaultDistance;
	cameraStruct.orientation = _orientation;
	cameraStruct.xAxis = _xAxis;
	cameraStruct.yAxis = _yAxis;
	cameraStruct.zAxis = _zAxis;
	cameraStruct.direction = _direction;
	cameraStruct.modelViewMatrix = _modelViewMatrix;
	cameraStruct.normalMatrix = _normalMatrix;
	cameraStruct.projectionMatrix = _projectionMatrix;
	cameraStruct.modelViewProjectionMatrix = _modelViewProjectionMatrix;
	
	NSData *cameraData = [NSData dataWithBytes:&cameraStruct length:sizeof(NezGLCameraStruct)];
	[coder encodeObject:cameraData forKey:@"cameraData"];
}

-(void)decodeRestorableStateWithCoder:(NSCoder*)coder {
	NezGLCameraStruct cameraStruct;
	NSData *cameraData = [coder decodeObjectForKey:@"cameraData"];
	cameraStruct = *((NezGLCameraStruct*)cameraData.bytes);
	
	_fovy = cameraStruct.fovy;
	_zNear = cameraStruct.zNear;
	_zFar = cameraStruct.zFar;
	_aspectRatio = cameraStruct.aspectRatio;
	_eye = cameraStruct.eye;
	_viewport[0] = cameraStruct.viewport[0];
	_viewport[1] = cameraStruct.viewport[1];
	_viewport[2] = cameraStruct.viewport[2];
	_viewport[3] = cameraStruct.viewport[3];
	_orientation = cameraStruct.orientation;
	_unitsPerPointAtDefaultDistance = cameraStruct.unitsPerPointAtDefaultDistance;
	_xAxis = cameraStruct.xAxis;
	_yAxis = cameraStruct.yAxis;
	_zAxis = cameraStruct.zAxis;
	_direction = cameraStruct.direction;
	_modelViewMatrix = cameraStruct.modelViewMatrix;
	_normalMatrix = cameraStruct.normalMatrix;
	_projectionMatrix = cameraStruct.projectionMatrix;
	_modelViewProjectionMatrix = cameraStruct.modelViewProjectionMatrix;
}

-(void)updatemodelViewMatrix {
	_modelViewMatrix = GLKMatrix4MakeWithQuaternion(_orientation);
	
	_xAxis = GLKVector3Make(_modelViewMatrix.m00, _modelViewMatrix.m10, _modelViewMatrix.m20);
	_yAxis = GLKVector3Make(_modelViewMatrix.m01, _modelViewMatrix.m11, _modelViewMatrix.m21);
	_zAxis = GLKVector3Make(_modelViewMatrix.m02, _modelViewMatrix.m12, _modelViewMatrix.m22);
	_direction = GLKVector3Negate(_zAxis);
	
	_modelViewMatrix.m30 = -GLKVector3DotProduct(_xAxis, _eye);
	_modelViewMatrix.m31 = -GLKVector3DotProduct(_yAxis, _eye);
	_modelViewMatrix.m32 = -GLKVector3DotProduct(_zAxis, _eye);

	_normalMatrix = GLKMatrix3InvertAndTranspose(GLKMatrix4GetMatrix3(_modelViewMatrix), NULL);
	_modelViewProjectionMatrix = GLKMatrix4Multiply(_projectionMatrix, _modelViewMatrix);
}

-(GLKVector3)getEye {
	return _eye;
}

-(void)setEye:(GLKVector3)eye {
	_eye = eye;
	[self updatemodelViewMatrix];
}

-(void)setEye:(GLKVector3)eye andOrientation:(GLKQuaternion)orientation {
	_eye = eye;
	self.orientation = orientation;
}

-(void)setOrientation:(GLKQuaternion)orientation {
	_orientation = GLKQuaternionNormalize(orientation);
	[self updatemodelViewMatrix];
}

-(void)lookAtTarget:(GLKVector3)target {
	[self lookAtEye:_eye target:target upVector:_yAxis];
}

-(void)lookAtEye:(GLKVector3)eye target:(GLKVector3)target upVector:(GLKVector3)up {
	_eye = eye;
	
	_modelViewMatrix = GLKMatrix4MakeLookAt(eye.x, eye.y, eye.z, target.x, target.y, target.z, up.x, up.y, up.z);

	_xAxis = GLKVector3Make(_modelViewMatrix.m00, _modelViewMatrix.m10, _modelViewMatrix.m20);
	_yAxis = GLKVector3Make(_modelViewMatrix.m01, _modelViewMatrix.m11, _modelViewMatrix.m21);
	_zAxis = GLKVector3Make(_modelViewMatrix.m02, _modelViewMatrix.m12, _modelViewMatrix.m22);
	_direction = GLKVector3Negate(_zAxis);

	_orientation = GLKQuaternionNormalize(GLKQuaternionMakeWithMatrix4(_modelViewMatrix));

	_normalMatrix = GLKMatrix3InvertAndTranspose(GLKMatrix4GetMatrix3(_modelViewMatrix), NULL);
	_modelViewProjectionMatrix = GLKMatrix4Multiply(_projectionMatrix, _modelViewMatrix);
}

-(CGRect)getViewport {
	return CGRectMake(_viewport[0], _viewport[1], _viewport[2], _viewport[3]);
}

-(float)getViewportWidth {
	return _viewport[2];
}

-(float)getViewportHeight {
	return _viewport[3];
}

-(void)setDefaultPerspectiveProjectionWithViewport:(CGRect)viewport {
	[self setPerspectiveProjectionWithFOVY:DEFAULT_FOVY viewport:viewport zNear:DEFAULT_ZNEAR zFar:DEFAULT_ZFAR calulateUnitsPerPointFlag:YES];
}

-(void)setPerspectiveProjectionWithFOVY:(float)fovy viewport:(CGRect)viewport zNear:(float)zNear zFar:(float)zFar {
	[self setPerspectiveProjectionWithFOVY:fovy viewport:viewport zNear:zNear zFar:zFar calulateUnitsPerPointFlag:YES];
}

-(void)setPerspectiveProjectionWithFOVY:(float)fovy viewport:(CGRect)viewport zNear:(float)zNear zFar:(float)zFar calulateUnitsPerPointFlag:(BOOL)flag {
	_viewport[0] = viewport.origin.x;
	_viewport[1] = viewport.origin.y;
	_viewport[2] = viewport.size.width;
	_viewport[3] = viewport.size.height;
	
	_effectiveViewport = viewport;
	
	float aspectRatio = fabsf(viewport.size.width / viewport.size.height);
	_projectionMatrix = GLKMatrix4MakePerspective(GLKMathDegreesToRadians(fovy), aspectRatio, zNear, zFar);
	
	_fovy = fovy;
	_aspectRatio = aspectRatio;
	_zNear = zNear;
	_zFar = zFar;

	if (flag) {
		_unitsPerPointAtDefaultDistance = [self getUnitsPerPointWithViewport:viewport andDistanceFromTarget:DEFAULT_Z_DISTANCE];
	}
}

-(float)getUnitsPerPointWithViewport:(CGRect)viewport andDistanceFromTarget:(float)distanceFromTarget {
	NezGLCamera *cam = [[NezGLCamera alloc] init];
	[cam setPerspectiveProjectionWithFOVY:_fovy viewport:viewport zNear:_zNear zFar:_zFar calulateUnitsPerPointFlag:NO];
	[cam lookAtEye:GLKVector3Make(0.0, 0.0, distanceFromTarget) target:GLKVector3Make(0.0, 0.0, 0.0) upVector:GLKVector3Make(0.0, 1.0, 0.0)];
	
	GLKVector3 pZero = [cam getWorldCoordinates:GLKVector2Make(0, 0) atWorldZ:0.0];
	GLKVector3 pOne = [cam getWorldCoordinates:GLKVector2Make(1, 0) atWorldZ:0.0];
	return GLKVector3Distance(pOne, pZero);
}

-(GLKVector2)getScreenCoordinates:(GLKVector3)pos {
	GLKVector4 pos4 = GLKMatrix4MultiplyVector4(_modelViewProjectionMatrix, GLKVector4Make(pos.x, pos.y, pos.z, 1.0));
	GLKVector2 pos2 = GLKVector2Make(pos4.x/pos4.w, pos4.y/pos4.w);
	return GLKVector2Make(_viewport[0] + _viewport[2] * (pos2.x+1.0)/2.0, _viewport[1] + _viewport[3] * (pos2.y+1.0)/2.0);
}

-(GLKVector3)getWorldCoordinates:(GLKVector2)screenPos atWorldZ:(float)z {
	screenPos.x += _viewport[0];
	screenPos.y = _viewport[1]+_viewport[3]-screenPos.y;
	
	GLKVector3 posNear = GLKMathUnproject(GLKVector3Make(screenPos.x, screenPos.y, 0.0), _modelViewMatrix, _projectionMatrix, _viewport, NULL);
	GLKVector3 posFar  = GLKMathUnproject(GLKVector3Make(screenPos.x, screenPos.y, 1.0), _modelViewMatrix, _projectionMatrix, _viewport, NULL);
	
	float d1 = posNear.z-posFar.z;
	float d2 = posNear.z-z;
	float ratio = d2/d1;
	
	float x = posNear.x-((posNear.x-posFar.x)*ratio);
	float y = posNear.y-((posNear.y-posFar.y)*ratio);
	
	return GLKVector3Make(x, y, z);
}

-(NezRay*)getWorldRay:(GLKVector2)screenPos {
	screenPos.x += _viewport[0];
	screenPos.y = _viewport[1]+_viewport[3]-screenPos.y;
	GLKVector3 posNear = GLKMathUnproject(GLKVector3Make(screenPos.x, screenPos.y, 0.0), _modelViewMatrix, _projectionMatrix, _viewport, NULL);
	GLKVector3 posFar  = GLKMathUnproject(GLKVector3Make(screenPos.x, screenPos.y, 1.0), _modelViewMatrix, _projectionMatrix, _viewport, NULL);
	return [[NezRay alloc] initWithOrigin:posNear andDirection:GLKVector3Subtract(posFar, posNear)];
}

-(void)stopLookingAtGeometry {
	_currentGeometryTarget = nil;
}

-(void)lookAtGeometry:(NezGeometry*)geometry withZoomOptions:(NezGLCameraZoomOptions)options {
	float vpcx = _viewport[0]+_viewport[2]*0.5;
	float vpcy = _viewport[1]+_viewport[3]*0.5;
	float ecx = _effectiveViewport.origin.x+_effectiveViewport.size.width*0.5;
	float ecy = _effectiveViewport.origin.y+_effectiveViewport.size.height*0.5;
	
	float ratio;
	if (options == NezGLCameraZoomToWidth) {
		ratio = [self getZoomToWidthRatioForGeometry:geometry];
	} else if (options == NezGLCameraZoomToHeight) {
		ratio = [self getZoomToHeightRatioForGeometry:geometry];
	} else {
		float ratioW = [self getZoomToWidthRatioForGeometry:geometry];
		float ratioH = [self getZoomToHeightRatioForGeometry:geometry];
		if (options == NezGLCameraZoomToClosest) {
			ratio = (ratioW < ratioH)?ratioW:ratioH;
		} else {
			ratio = (ratioW > ratioH)?ratioW:ratioH;
		}
	}
	
	float dx = (ecx-vpcx)*_unitsPerPointAtDefaultDistance*ratio;
	float dy = (ecy-vpcy)*_unitsPerPointAtDefaultDistance*ratio;

	float distance = geometry.dimensions.z*0.5+(ratio*DEFAULT_Z_DISTANCE);
	GLKQuaternion orientation = geometry.orientation;
	GLKVector3 target = GLKVector3Add(geometry.center, GLKQuaternionRotateVector3(orientation, GLKVector3Make(dx, dy, 0.0)));
	GLKVector3 eye = GLKVector3Add(target, GLKQuaternionRotateVector3(orientation, GLKVector3Make(0.0, 0.0, distance)));
	GLKVector3 upVector = GLKQuaternionRotateVector3(orientation, GLKVector3Make(0,1,0));
	[self lookAtEye:eye target:target upVector:upVector];
	
	_currentGeometryTarget = geometry;
	_currentZoomOptions = options;
}

-(float)getZoomToWidthRatioForGeometry:(NezGeometry*)geometry {
	GLKVector3 dimensions = geometry.dimensions;
	float w = _effectiveViewport.size.width;
	float sw = w*_unitsPerPointAtDefaultDistance*0.5;
	float bw = dimensions.x*0.5;
	return bw/sw;
}

-(float)getZoomToHeightRatioForGeometry:(NezGeometry*)geometry {
	GLKVector3 dimensions = geometry.dimensions;
	float h = _effectiveViewport.size.height;
	float sh = h*_unitsPerPointAtDefaultDistance*0.5;
	float bh = dimensions.y*0.5;
	return bh/sh;
}

-(void)setEffectiveViewport:(CGRect)ev {
	_effectiveViewport = ev;
	if (_currentGeometryTarget) {
		[self lookAtGeometry:_currentGeometryTarget withZoomOptions:_currentZoomOptions];
	}
}

@end
