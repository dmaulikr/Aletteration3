//
//  NezRay.m
//  Aletteration2
//
//  Created by David Nesbitt on 2012-11-11.
//  Copyright (c) 2012 David Nesbitt. All rights reserved.
//

/*
 Taken from http://www.cs.utah.edu/~awilliam/box/box.pdf
 
 An Efficient and Robust Ray–Box Intersection Algorithm
 Amy Williams Steve Barrus R. Keith Morley Peter Shirley University of Utah
 */

#import "NezRay.h"
#import "NezGeometry.h"

@implementation NezRay

-(instancetype)initWithOrigin:(GLKVector3)origin andDirection:(GLKVector3)direction {
	if ((self = [super init])) {
		_origin = origin;
		_direction = direction;
		_inverseDirection = GLKVector3Make(1.0f/direction.x, 1.0f/direction.y, 1.0f/direction.z);
		_signX = (_inverseDirection.x < 0);
		_signY = (_inverseDirection.y < 0);
		_signZ = (_inverseDirection.z < 0);
	}
	return self;
}

-(instancetype)initWithRay:(NezRay*)ray {
	if ((self = [super init])) {
		_origin = ray.origin;
		_direction = ray.direction;
		_inverseDirection = ray.inverseDirection;
		_signX = ray.signX;
		_signY = ray.signY;
		_signZ = ray.signZ;
	}
	return self;
}

-(BOOL)intersectWithAABB:(GLKVector3*)aabb IntervalStart:(float)t0 IntervalEnd:(float)t1 {
	float tmin, tmax, tymin, tymax, tzmin, tzmax;
	
	tmin = (aabb[_signX].x - _origin.x) * _inverseDirection.x;
	tmax = (aabb[1-_signX].x - _origin.x) * _inverseDirection.x;
	tymin = (aabb[_signY].y - _origin.y) * _inverseDirection.y;
	tymax = (aabb[1-_signY].y - _origin.y) * _inverseDirection.y;
	if ( (tmin > tymax) || (tymin > tmax) ) {
		return false;
	}
	if (tymin > tmin) {
		tmin = tymin;
	}
	if (tymax < tmax) {
		tmax = tymax;
	}
	tzmin = (aabb[_signZ].z - _origin.z) * _inverseDirection.z;
	tzmax = (aabb[1-_signZ].z - _origin.z) * _inverseDirection.z;
	if ( (tmin > tzmax) || (tzmin > tmax) ) {
		return false;
	}
	if (tzmin > tmin) {
		tmin = tzmin;
	}
	if (tzmax < tmax) {
		tmax = tzmax;
	}
	return ((tmin < t1) && (tmax > t0));
}

/*
	Möller–Trumbore intersection algorithm
	http://en.wikipedia.org/wiki/Möller–Trumbore_intersection_algorithm
*/
-(BOOL)intersectsTriangleV0:(GLKVector3)V0 V1:(GLKVector3)V1 V2:(GLKVector3)V2 {
	GLKVector3 e1, e2;  //Edge1, Edge2
	GLKVector3 P, Q, T;
	float det, inv_det, u, v;
	float t;
	
	//Find vectors for two edges sharing V0
	e1 = GLKVector3Subtract(V1, V0);
	e2 = GLKVector3Subtract(V2, V0);
	//Begin calculating determinant - also used to calculate u parameter
	P = GLKVector3CrossProduct(_direction, e2);
	//if determinant is near zero, ray lies in plane of triangle
	det = GLKVector3DotProduct(e1, P);
	//NOT CULLING
	if(det > -NEZ_FLOATING_POINT_EPSILON && det < NEZ_FLOATING_POINT_EPSILON) return NO;
	inv_det = 1.f / det;
	
	//calculate distance from V0 to ray origin
	T = GLKVector3Subtract(_origin, V0);
	
	//Calculate u parameter and test bound
	u = GLKVector3DotProduct(T, P) * inv_det;
	//The intersection lies outside of the triangle
	if(u < 0.f || u > 1.f) return NO;
	
	//Prepare to test v parameter
	Q = GLKVector3CrossProduct(T, e1);
	
	//Calculate V parameter and test bound
	v = GLKVector3DotProduct(_direction, Q) * inv_det;
	//The intersection lies outside of the triangle
	if(v < 0.f || u + v  > 1.f) return NO;
	
	t = GLKVector3DotProduct(e2, Q) * inv_det;
	
	if(t > NEZ_FLOATING_POINT_EPSILON) { //ray intersection
		return YES;
	}
	
	// No hit, no win
	return NO;
}

@end
