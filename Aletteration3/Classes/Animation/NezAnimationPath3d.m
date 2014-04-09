//
//  NezPathAnimation.m
//  Aletteration3
//
//  Created by David Nesbitt on 2013/10/25.
//  Copyright (c) 2013 David Nesbitt. All rights reserved.
//

#import "NezAnimationPath3d.h"
#import "NezPath3d.h"

@implementation NezAnimationPath3d

-(instancetype)initWithPath:(NezPath3d*)path Duration:(CFTimeInterval)d EasingFunction:(EasingFunctionPtr)func UpdateBlock:(NezAnimationPath3dBlock)updateBlock DidStopBlock:(NezAnimationBlock)didStopBlock {
	NezAnimationBlock pathUpdateBlock = ^(NezAnimation *ani) {
		NezAnimationPath3d *pathAni = (NezAnimationPath3d*)ani;
		GLKVector3 newPosition = [pathAni.path positionAt:ani.newData[0]];
		updateBlock(pathAni, newPosition);
	};
	if ((self=[super initFloatWithFromData:0.0 ToData:1.0 Duration:d EasingFunction:func UpdateBlock:pathUpdateBlock DidStopBlock:didStopBlock])) {
		self.path = path;
	}
	return self;
}

-(void)dealloc {
	self.path = nil;
}

@end
