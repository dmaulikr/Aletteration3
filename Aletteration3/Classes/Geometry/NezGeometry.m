//
//  NezGeometry.m
//  Aletteration3
//
//  Created by David Nesbitt on 2013-09-23.
//  Copyright (c) 2013 David Nesbitt. All rights reserved.
//

#import "NezGeometry.h"
#import "NezRay.h"
#import "NezPath3d.h"
#import "NezAnimationPath3d.h"
#import "NezAnimator.h"
#import "NezGLCamera.h"

@implementation NezGeometry

-(instancetype)initWithDimensions:(GLKVector3)dimensions {
	if ((self = [super init])) {
		_dimensions = dimensions;
		_boundsNeedUpdate = YES;
	}
	return self;
}

-(GLKMatrix4)getModelMatrix {
	return _modelMatrix;
}

-(GLKVector3)getCenter {
	return GLKVector3Make(_modelMatrix.m30, _modelMatrix.m31, _modelMatrix.m32);
}

-(void)setCenter:(GLKVector3)center {
	_modelMatrix.m30 = center.x;
	_modelMatrix.m31 = center.y;
	_modelMatrix.m32 = center.z;
	_boundsNeedUpdate = YES;
}

-(void)setModelMatrix:(GLKMatrix4)modelMatrix {
	_modelMatrix = modelMatrix;
	_boundsNeedUpdate = YES;
}

-(void)setModelMatrixForOrientation:(GLKQuaternion)orientation andCenter:(GLKVector3)center {
	GLKMatrix4 matrix = GLKMatrix4MakeWithQuaternionAndPostion(orientation, center);
	self.modelMatrix = matrix;
}

-(GLKQuaternion)getOrientation {
	return GLKQuaternionMakeWithMatrix4(_modelMatrix);
}

-(NezBoundingBox)getAABB {
	if (_boundsNeedUpdate) {
		[self calculateAxisAlignedBoundingBox];
	}
	return _aabb;
}

-(void)calculateAxisAlignedBoundingBox {
	_boundsNeedUpdate = NO;
	
	float halfW = _dimensions.x*0.5f;
	float halfH = _dimensions.y*0.5f;
	float halfD = _dimensions.z*0.5f;

	GLKVector3 center = self.center;
	GLKQuaternion orientation = self.orientation;
	
	GLKVector3 v0 = GLKQuaternionRotateVector3(orientation, GLKVector3Make(-halfW, -halfH, -halfD));
	GLKVector3 v1 = GLKQuaternionRotateVector3(orientation, GLKVector3Make(-halfW, -halfH,  halfD));
	GLKVector3 v2 = GLKQuaternionRotateVector3(orientation, GLKVector3Make(-halfW,  halfH, -halfD));
	GLKVector3 v3 = GLKQuaternionRotateVector3(orientation, GLKVector3Make(-halfW,  halfH,  halfD));

	_aabb.min = v0;
	
	if (_aabb.min.x > v1.x) { _aabb.min.x = v1.x; }
	if (_aabb.min.x > v2.x) { _aabb.min.x = v2.x; }
	if (_aabb.min.x > v3.x) { _aabb.min.x = v3.x; }
	if (_aabb.min.x > -v0.x) { _aabb.min.x = -v0.x; }
	if (_aabb.min.x > -v1.x) { _aabb.min.x = -v1.x; }
	if (_aabb.min.x > -v2.x) { _aabb.min.x = -v2.x; }
	if (_aabb.min.x > -v3.x) { _aabb.min.x = -v3.x; }
	
	if (_aabb.min.y > v1.y) { _aabb.min.y = v1.y; }
	if (_aabb.min.y > v2.y) { _aabb.min.y = v2.y; }
	if (_aabb.min.y > v3.y) { _aabb.min.y = v3.y; }
	if (_aabb.min.y > -v0.y) { _aabb.min.y = -v0.y; }
	if (_aabb.min.y > -v1.y) { _aabb.min.y = -v1.y; }
	if (_aabb.min.y > -v2.y) { _aabb.min.y = -v2.y; }
	if (_aabb.min.y > -v3.y) { _aabb.min.y = -v3.y; }
	
	if (_aabb.min.z > v1.z) { _aabb.min.z = v1.z; }
	if (_aabb.min.z > v2.z) { _aabb.min.z = v2.z; }
	if (_aabb.min.z > v3.z) { _aabb.min.z = v3.z; }
	if (_aabb.min.z > -v0.z) { _aabb.min.z = -v0.z; }
	if (_aabb.min.z > -v1.z) { _aabb.min.z = -v1.z; }
	if (_aabb.min.z > -v2.z) { _aabb.min.z = -v2.z; }
	if (_aabb.min.z > -v3.z) { _aabb.min.z = -v3.z; }
	
	_aabb.max = GLKVector3Negate(_aabb.min);
	
	_aabb.min = GLKVector3Add(_aabb.min, center);
	_aabb.max = GLKVector3Add(_aabb.max, center);
}

-(BOOL)intersect:(NezRay*)ray {
	return [ray intersectWithAABB:self.aabb.bounds IntervalStart:0.0 IntervalEnd:1.0];
}

-(BOOL)intersect:(NezRay*)ray withExtraSize:(float)size {
	float w = _dimensions.x*size;
	float h = _dimensions.y*size;
	float d = _dimensions.z*size;
	
	NezBoundingBox aabb = self.aabb;
	aabb.min = GLKVector3Make(aabb.min.x-w, aabb.min.y-h, aabb.min.z-d);
	aabb.max = GLKVector3Make(aabb.max.x+w, aabb.max.y+h, aabb.max.z+d);
	return [ray intersectWithAABB:aabb.bounds IntervalStart:0.0 IntervalEnd:1.0];
}

-(GLKVector3)modelCoordinateForPoint:(GLKVector3)point {
	GLKVector4 pos = GLKVector4MakeWithVector3(point, 1.0);
	pos = GLKMatrix4MultiplyVector4(self.modelMatrix, pos);
	return GLKVector3Make(pos.x, pos.y, pos.z);
}

-(NezAnimationPath3d*)animationForPath:(NezPath3d*)path FinalOrientation:(GLKQuaternion)finalOrientation Duration:(CFTimeInterval)d EasingFunction:(EasingFunctionPtr)func andDidStopBlock:(NezAnimationBlock)didStopBlock {
	GLKQuaternion startOrientation = GLKQuaternionMakeWithMatrix4(self.modelMatrix);
	__weak NezGeometry *myself = self;
	NezAnimationPath3d *ani = [[NezAnimationPath3d alloc] initWithPath:path Duration:d EasingFunction:func UpdateBlock:^(NezAnimationPath3d *ani, GLKVector3 center) {
		GLKQuaternion orientation = GLKQuaternionSlerp(startOrientation, finalOrientation, ani.newData[0]);
		[myself setModelMatrixForOrientation:orientation andCenter:center];
	} DidStopBlock:didStopBlock];
	return ani;
}

@end
