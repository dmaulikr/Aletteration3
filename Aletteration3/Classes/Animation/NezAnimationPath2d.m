//
//  NezPath2dAnimation.m
//  Aletteration3
//
//  Created by David Nesbitt on 2013/11/09.
//  Copyright (c) 2013 David Nesbitt. All rights reserved.
//

#import "NezAnimationPath2d.h"
#import "NezPath2d.h"

@implementation NezAnimationPath2d

-(instancetype)initWithPath:(NezPath2d*)path Duration:(CFTimeInterval)d EasingFunction:(EasingFunctionPtr)func UpdateBlock:(NezAnimationPath2dBlock)updateBlock DidStopBlock:(NezAnimationBlock)didStopBlock {
	if ((self=[super initFloatWithFromData:0.0 ToData:1.0 Duration:d EasingFunction:func UpdateBlock:^(NezAnimation *ani) {
		NezAnimationPath2d *pathAni = (NezAnimationPath2d*)ani;
		GLKVector2 newPosition = [pathAni.path positionAt:ani.newData[0]];
		updateBlock(pathAni, newPosition);
	} DidStopBlock:didStopBlock])) {
		self.path = path;
	}
	return self;
}

-(void)dealloc {
	self.path = nil;
}

@end