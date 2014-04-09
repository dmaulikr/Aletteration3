//
//  NezAletterationBox.m
//  Aletteration3
//
//  Created by David Nesbitt on 2013/10/23.
//  Copyright (c) 2013 David Nesbitt. All rights reserved.
//

#import "NezAletterationBox.h"
#import "NezGLCamera.h"

@implementation NezAletterationBox

-(instancetype)initWithLid:(NezAletterationLid*)lid instanceAbo:(NezInstanceAttributeBufferObjectColor*)instanceAbo index:(NSInteger)instanceAttributeIndex andDimensions:(GLKVector3)dimensions {
	if ((self = [super initWithInstanceAbo:instanceAbo index:instanceAttributeIndex andDimensions:dimensions])) {
		_lid = lid;
		[self attachLid];
	}
	return self;
}

-(void)encodeRestorableStateWithCoder:(NSCoder*)coder {
	[super encodeRestorableStateWithCoder:coder];
	
	[coder encodeBool:_lidAttached forKey:@"_lidAttached"];
	[coder encodeObject:_lid forKey:@"_lid"];
}

-(void)decodeRestorableStateWithCoder:(NSCoder*)coder {
	[super decodeRestorableStateWithCoder:coder];
	
	_lidAttached = [coder decodeBoolForKey:@"_lidAttached"];
	_lid = [coder decodeObjectForKey:@"_lid"];
}

-(void)registerChildObjectsForStateRestoration {
	[super registerChildObjectsForStateRestoration];
	
	[self registerChildObject:_lid withRestorationIdentifier:@"_lid"];
}

-(void)attachLid {
	_lidAttached = YES;
	
}

-(void)detachLid {
	_lidAttached = NO;
}

-(void)setColor:(GLKVector4)color {
	[super setColor:color];
	_lid.color = color;
}

-(void)setModelMatrix:(GLKMatrix4)modelMatrix {
	[super setModelMatrix:modelMatrix];
	if (_lidAttached) {
		_lid.modelMatrix = [self lidMatrixForModelMatrix:modelMatrix];
	}
}

-(GLKMatrix4)lidMatrix {
	return GLKMatrix4Translate(_modelMatrix, 0.0f, 0.0f, (self.dimensions.z*0.5)-(_lid.dimensions.z*0.4));
}

-(GLKMatrix4)lidMatrixForModelMatrix:(GLKMatrix4)modelMatrix {
	return GLKMatrix4Translate(modelMatrix, 0.0f, 0.0f, (self.dimensions.z*0.5)-(_lid.dimensions.z*0.4));
}

-(GLKMatrix4)lidMatrixForOrientation:(GLKQuaternion)orientation andPosition:(GLKVector3)center {
	GLKMatrix4 matrix = GLKMatrix4MakeWithQuaternionAndPostion(orientation, center);
	return [self lidMatrixForModelMatrix:matrix];
}
@end
