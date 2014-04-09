//
//  NezRay.h
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

#import <GLKit/GLKit.h>

@interface NezRay : NSObject

@property(nonatomic) GLKVector3 origin;
@property(nonatomic) GLKVector3 direction;
@property(nonatomic) GLKVector3 inverseDirection;
@property(nonatomic) int signX;
@property(nonatomic) int signY;
@property(nonatomic) int signZ;

-(instancetype)initWithOrigin:(GLKVector3)origin andDirection:(GLKVector3)direction;
-(instancetype)initWithRay:(NezRay*)ray;

-(BOOL)intersectWithAABB:(GLKVector3*)aabb IntervalStart:(float)t0 IntervalEnd:(float)t1;
-(BOOL)intersectsTriangleV0:(GLKVector3)V0 V1:(GLKVector3)V1 V2:(GLKVector3)V2;

@end
