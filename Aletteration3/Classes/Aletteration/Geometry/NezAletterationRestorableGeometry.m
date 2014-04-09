//
//  NezAletterationRestorableGeometry.m
//  Aletteration3
//
//  Created by David Nesbitt on 2013/11/03.
//  Copyright (c) 2013 David Nesbitt. All rights reserved.
//

#import "NezAletterationRestorableGeometry.h"
#import "NezAletterationAppDelegate.h"
#import "NezAletterationGraphics.h"

typedef struct {
	GLKMatrix4 modelMatrix;
	GLKVector3 dimensions;
	NezBoundingBox aabb;
	BOOL boundsNeedUpdate;
} NezAletterationRestorableGeometryStruct;

@implementation NezAletterationRestorableGeometry

+(NSObject<UIStateRestoring>*)objectWithRestorationIdentifierPath:(NSArray*)identifierComponents coder:(NSCoder*)coder {
	return [[[self class] alloc] init];
}

-(instancetype)initWithDimensions:(GLKVector3)dimensions {
	if (([super initWithDimensions:dimensions])) {
		self.objectRestorationClass = [self class];
	}
	return self;
}

-(instancetype)init {
	if (([super init])) {
		self.objectRestorationClass = [self class];
	}
	return self;
}

-(void)encodeRestorableStateWithCoder:(NSCoder*)coder {
//	NSLog(@"%@ encodeRestorableStateWithCoder", NSStringFromClass([self class]));

	NezAletterationRestorableGeometryStruct geometry;
	geometry.modelMatrix = _modelMatrix;
	geometry.dimensions = _dimensions;
	geometry.aabb = _aabb;
	geometry.boundsNeedUpdate = _boundsNeedUpdate;

	NSData *geometryData = [NSData dataWithBytes:&geometry length:sizeof(NezAletterationRestorableGeometryStruct)];
	[coder encodeObject:geometryData forKey:@"geometryData"];
}

-(void)decodeRestorableStateWithCoder:(NSCoder*)coder {
//	NSLog(@"%@ decodeRestorableStateWithCoder", NSStringFromClass([self class]));

	NSData *geometryData = [coder decodeObjectForKey:@"geometryData"];
	NezAletterationRestorableGeometryStruct *geometryPtr = (NezAletterationRestorableGeometryStruct*)geometryData.bytes;
	_modelMatrix = geometryPtr->modelMatrix;
	_dimensions = geometryPtr->dimensions;
	_aabb = geometryPtr->aabb;
	_boundsNeedUpdate = geometryPtr->boundsNeedUpdate;
}

-(void)registerChildObject:(id<NezRestorable>)restorableObject withRestorationIdentifier:(NSString*)restorationIdentifier {
	restorableObject.restorationParent = self;
	restorableObject.objectRestorationClass = self.objectRestorationClass;
	[UIApplication registerObjectForStateRestoration:restorableObject restorationIdentifier:restorationIdentifier];
	[restorableObject registerChildObjectsForStateRestoration];
}

-(void)registerChildObjectsForStateRestoration {
}

@end
