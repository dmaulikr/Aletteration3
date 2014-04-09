//
//  NezAletterationAnimationViewNextGameBoard.m
//  Aletteration3
//
//  Created by David Nesbitt on 2013-09-24.
//  Copyright (c) 2013 David Nesbitt. All rights reserved.
//

#import "NezAletterationAnimationNextGameBoard.h"
#import "NezAletterationGameBoard.h"
#import "NezAnimationPath3d.h"
#import "NezCubicBezier3d.h"
#import "NezAnimation.h"
#import "NezAnimator.h"
#import "NezGLCamera.h"
#import "NezAletterationAppDelegate.h"
#import "NezAletterationGraphics.h"

@interface NezAletterationAnimationNextGameBoard() {
	NezAletterationGameBoard *_board;
	NezAletterationGameBoard *_nextBoard;
	NezCubicBezier3d *_pathToNextGameBoard;
	NezGLCamera *_cam;
}

@end

@implementation NezAletterationAnimationNextGameBoard

-(instancetype)initWithBoard:(NezAletterationGameBoard*)board nextBoard:(NezAletterationGameBoard*)nextBoard {
	if ((self = [super init])) {
		_board = board;
		_nextBoard = nextBoard;
		
		_startOrientation = _board.orientation;
		_endOrientation = _nextBoard.orientation;

		_cam = [[NezGLCamera alloc] init];
		[_cam setDefaultPerspectiveProjectionWithViewport:[NezAletterationAppDelegate sharedAppDelegate].graphics.viewport];
	}
	return self;
}

-(void)lookAtPathLocation:(float)t withCamera:(NezGLCamera*)camera {
	if (t == 0.0) {
		[camera lookAtGeometry:_board.mainBoardGeometry withZoomOptions:NezGLCameraZoomToFarthest];
	} else if (t == 1.0) {
		[camera lookAtGeometry:_nextBoard.mainBoardGeometry withZoomOptions:NezGLCameraZoomToFarthest];
	} else {
		_cam.effectiveViewport = camera.effectiveViewport;
		
		[_cam lookAtGeometry:_board.mainBoardGeometry withZoomOptions:NezGLCameraZoomToFarthest];
		GLKVector3 startEye = _cam.eye;
		
		[_cam lookAtGeometry:_nextBoard.mainBoardGeometry withZoomOptions:NezGLCameraZoomToFarthest];
		GLKVector3 endEye = _cam.eye;
		
		_pathToNextGameBoard = [NezCubicBezier3d bezierWithControlPointsP0:startEye P1Z:startEye.z+15.0 P2Z:endEye.z+15.0 P3:endEye];

		GLKVector3 eye = [_pathToNextGameBoard positionAt:t];
		GLKQuaternion orientation = GLKQuaternionSlerp(_startOrientation, _endOrientation, t);
		[camera setEye:eye andOrientation:orientation];
	}
}

@end
