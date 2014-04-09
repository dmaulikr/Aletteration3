//
//  NezAletterationAnimationSlide.m
//  Aletteration3
//
//  Created by David Nesbitt on 2013/11/08.
//  Copyright (c) 2013 David Nesbitt. All rights reserved.
//

#import "NezAletterationAnimationSlide.h"
#import "NezAletterationAppDelegate.h"
#import "NezGeometry.h"
#import "NezGLCamera.h"
#import "NezAletterationGraphics.h"

@implementation NezAletterationAnimationSlide

-(instancetype)initWithFromGeometry:(NezGeometry*)fromGeometry toGeometry:(NezGeometry*)toGeometry {
	if ((self = [super init])) {
		_fromGeometry = fromGeometry;
		_toGeometry = toGeometry;

		_cam = [[NezGLCamera alloc] init];
		[_cam setDefaultPerspectiveProjectionWithViewport:[NezAletterationAppDelegate sharedAppDelegate].graphics.viewport];
}
	return self;
}

-(void)scrollToPositionWithTime:(float)t andCamera:(NezGLCamera*)camera {
	if (t == 0.0) {
		[camera lookAtGeometry:_fromGeometry withZoomOptions:NezGLCameraZoomToFarthest];
	} else if (t == 1.0) {
		[camera lookAtGeometry:_toGeometry withZoomOptions:NezGLCameraZoomToFarthest];
	} else {
		_cam.effectiveViewport = camera.effectiveViewport;
		
		[_cam lookAtGeometry:_fromGeometry withZoomOptions:NezGLCameraZoomToFarthest];
		GLKVector3 startEye = _cam.eye;
		
		[_cam lookAtGeometry:_toGeometry withZoomOptions:NezGLCameraZoomToFarthest];
		GLKVector3 endEye = _cam.eye;
		
		GLKVector3 eye = GLKVector3Lerp(startEye, endEye, t);
		camera.eye = eye;
	}
}

@end
