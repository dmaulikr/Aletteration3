//
//  NezAletterationAnimationBeginGame.m
//  Aletteration3
//
//  Created by David Nesbitt on 2013/10/27.
//  Copyright (c) 2013 David Nesbitt. All rights reserved.
//

#import "NezAletterationAnimationBeginGame.h"
#import "NezAletterationAppDelegate.h"
#import "NezAletterationGraphics.h"
#import "NezAletterationBox.h"
#import "NezAletterationLetterBox.h"
#import "NezAletterationLid.h"
#import "NezAletterationGameState.h"
#import "NezAletterationGameTable.h"
#import "NezAletterationGameBoard.h"
#import "NezAletterationPlayer.h"
#import "NezGLCamera.h"
#import "NezCubicBezier3d.h"
#import "NezAnimator.h"
#import "NezAnimation.h"
#import "NezAnimationPath3d.h"
#import "NezAletterationLetterGroup.h"
#import "NezAletterationLetterStack.h"
#import "NezRandom.h"

@implementation NezAletterationAnimationBeginGame

+(void)animateWithPlayerList:(NSArray*)playerList localPlayer:(NezAletterationPlayer*)localPlayer andDidStopHandler:(NezVoidBlock)didStopHandler {
	__weak NezAletterationGraphics *graphics = [NezAletterationAppDelegate sharedAppDelegate].graphics;
	__weak NezGLCamera *camera = graphics.camera;
	__weak NezAletterationBox *bigBox = graphics.gameTable.box;
	__weak NezAletterationLid *bigLid = bigBox.lid;
	__weak NezAletterationGameBoard *localGameBoard = localPlayer.gameBoard;
	
	[camera stopLookingAtGeometry];
	[bigBox detachLid];
	
	GLKVector3 lidStartCenter = bigLid.center;
	GLKVector3 lidEndCenter = GLKVector3Make(lidStartCenter.x, lidStartCenter.y, lidStartCenter.z+50.0);
	
	GLKVector3 startEye = camera.eye;
	GLKQuaternion startOrientation = camera.orientation;

	GLKVector3 endEye = [localPlayer.gameBoard modelCoordinateForPoint:GLKVector3Make(-5.0, -11.0, startEye.z+5.0)];
	GLKVector3 endTarget = [localGameBoard modelCoordinateForPoint:GLKVector3Make(0.0, 10.0, 0.0)];
	GLKVector3 endUpVector = GLKVector3Make(0,0,1);
	
	NezGLCamera *cam = [[NezGLCamera alloc] init];
	[cam setDefaultPerspectiveProjectionWithViewport:graphics.viewport];
	
	[cam lookAtEye:endEye target:endTarget upVector:endUpVector];
	GLKQuaternion endOrientation = cam.orientation;

	NezCubicBezier3d *camPath = [NezCubicBezier3d bezierWithControlPointsP0:startEye P1Z:camera.eye.z+10.0 P2Z:cam.eye.z+10.0 P3:cam.eye];
	NezAnimationPath3d *camAni = [[NezAnimationPath3d alloc] initWithPath:camPath Duration:3.0 EasingFunction:EASE_IN_OUT_QUAD UpdateBlock:^(NezAnimationPath3d *ani, GLKVector3 eye) {
		float t = ani.newData[0];
		GLKQuaternion orientation = GLKQuaternionSlerp(startOrientation, endOrientation, t);
		[camera setEye:eye andOrientation:orientation];
	} DidStopBlock:^(NezAnimation *ani) {
		GLKVector3 startEye = camera.eye;
		GLKQuaternion startOrientation = camera.orientation;
		
		[cam lookAtGeometry:localGameBoard.mainBoardGeometry withZoomOptions:NezGLCameraZoomToFarthest];
		cam.effectiveViewport = camera.effectiveViewport;
		GLKVector3 endEye = cam.eye;
		GLKQuaternion endOrientation = cam.orientation;
		
		[NezAnimator animateFloatWithFromData:0.0 ToData:1.0 Duration:3.0 EasingFunction:EASE_IN_OUT_QUAD UpdateBlock:^(NezAnimation *ani) {
			float t = ani.newData[0];
			GLKVector3 eye = GLKVector3Lerp(startEye, endEye, t);
			GLKQuaternion orientation = GLKQuaternionSlerp(startOrientation, endOrientation, t);
			[camera setEye:eye andOrientation:orientation];
		} DidStopBlock:^(NezAnimation *ani) {
			[camera lookAtGeometry:localGameBoard.mainBoardGeometry withZoomOptions:NezGLCameraZoomToFarthest];
			if (didStopHandler) {
				didStopHandler();
			}
		}].delay = 2.5;
	}];
	[NezAnimator addAnimation:camAni];

	[NezAnimator animateFloatWithFromData:0.0 ToData:1.0 Duration:3.0 EasingFunction:EASE_IN_OUT_QUAD UpdateBlock:^(NezAnimation *ani) {
		float t = ani.newData[0];
		
		GLKVector3 lidCenter = GLKVector3Lerp(lidStartCenter, lidEndCenter, t);
		bigLid.center = lidCenter;
	} DidStopBlock:^(NezAnimation *ani) {
	}].delay = 0.5;

	[playerList enumerateObjectsUsingBlock:^(NezAletterationPlayer *player, NSUInteger idx, BOOL *stop) {
		__weak NezAletterationGameBoard *gameBoard = player.gameBoard;
		__weak NezAletterationLetterBox *box = gameBoard.letterBox;
		__weak NezAletterationLid *lid = box.lid;
		
		GLKVector4 lineStartColor = gameBoard.color;
		lineStartColor.a = 0.0;
		[gameBoard setLineColor:lineStartColor];
		[gameBoard setStackLabelColor:GLKVector4Make(0.0, 0.0, 0.0, 0.0)];
		
		float initialBoxDelay = 1.25+randomFloatInRange(0.25, 0.75);
		
		float finalLidAngle = randomFloatInRange(-0.25, 0.5);
		GLKQuaternion lidFinalOrientation = GLKQuaternionMultiply(gameBoard.orientation, GLKQuaternionMultiply(GLKQuaternionMakeWithAngleAndAxis(M_PI, 1, 1, 0), GLKQuaternionMakeWithAngleAndAxis(finalLidAngle, 0, 0, 1)));
		NezCubicBezier3d *lidPath = [NezCubicBezier3d bezier];
		NezAnimationPath3d *lidAni = [lid animationForPath:lidPath FinalOrientation:lidFinalOrientation Duration:3.0 EasingFunction:EASE_OUT_CUBIC andDidStopBlock:^(NezAnimation *ani) {}];
		lidAni.didStartBlock = ^(NezAnimation *ani) {
			[box detachLid];
			GLKVector3 p3 = [gameBoard modelCoordinateForPoint:GLKVector3Make(-7.0, 8.0, lid.dimensions.z*0.5)];
			[lidPath setControlPointsP0:lid.center P1Z:15.0 P2Z:12.0 P3:p3];
		};
		lidAni.delay = initialBoxDelay+1.5;
		[NezAnimator addAnimation:lidAni];
		
		GLKQuaternion endOrientation = GLKQuaternionMultiply(gameBoard.orientation, GLKQuaternionMakeWithAngleAndAxis(1.25, 0.25, -0.35, 0.4));
		NezCubicBezier3d *boxPath = [NezCubicBezier3d bezierWithControlPointsP0:box.center P1Z:randomFloatInRange(10.0, 3.0) P1T:0.05 P2Z:randomFloatInRange(10.0, 3.0) P2T:0.75 P3:GLKVector3Make(gameBoard.center.x, gameBoard.center.y, gameBoard.center.z+5.0)];

		NezAnimationPath3d *boxAni = [box animationForPath:boxPath FinalOrientation:endOrientation Duration:2.5 EasingFunction:EASE_IN_OUT_CUBIC andDidStopBlock:^(NezAnimation *ani) {
			[box detachBlocks];
			[NezAletterationAnimationBeginGame animateLetterGroupList:box.row1GroupList toGameBoard:gameBoard andDidStopBlock:^(NezAnimation *ani) {}];
			[NezAletterationAnimationBeginGame animateLetterGroupList:box.row2GroupList toGameBoard:gameBoard andDidStopBlock:^(NezAnimation *ani) {}];
			
			GLKVector3 p3 = lidPath.p3;
			p3.z = box.dimensions.z*0.5;
			GLKQuaternion boxFinalOrientation = GLKQuaternionMultiply(gameBoard.orientation, GLKQuaternionMakeWithAngleAndAxis(M_PI_2-finalLidAngle, 0, 0, 1));
			NezCubicBezier3d *boxPath = [NezCubicBezier3d bezierWithControlPointsP0:box.center P1Z:15.0 P2Z:12.0 P3:p3];
			
			NezAnimationPath3d *boxAni = [box animationForPath:boxPath FinalOrientation:boxFinalOrientation Duration:3.0 EasingFunction:EASE_IN_OUT_CUBIC andDidStopBlock:^(NezAnimation *ani) {}];
			boxAni.delay = 1.0;
			[NezAnimator addAnimation:boxAni];
		}];
		boxAni.delay = initialBoxDelay;
		[NezAnimator addAnimation:boxAni];
		
		[NezAnimator animateFloatWithFromData:0.0 ToData:0.5 Duration:2.5 EasingFunction:EASE_IN_OUT_CUBIC UpdateBlock:^(NezAnimation *ani) {
			[gameBoard setLineColor:GLKVector4Make(lineStartColor.r, lineStartColor.g, lineStartColor.b, ani.newData[0])];
		} DidStopBlock:^(NezAnimation *ani) {
		}].delay = 1.0;
	}];
}

+(void)animateLetterGroupList:(NSMutableArray*)letterGroupList toGameBoard:(NezAletterationGameBoard*)gameBoard andDidStopBlock:(NezAnimationBlock)didStopBlock {
	[letterGroupList enumerateObjectsUsingBlock:^(NezAletterationLetterGroup *letterGroup, NSUInteger idx, BOOL *stop) {
		GLKVector3 p0 = letterGroup.center;
		GLKVector3 p3 = [gameBoard stackForLetter:letterGroup.letter].center;
		GLKVector3 p1 = GLKVector3Lerp(p0, p3, 0.05);
		p1.z = randomFloatInRange(11.0, 2.0);
		GLKVector3 p2 = GLKVector3Lerp(p0, p3, 0.95);
		p2.z = randomFloatInRange(12.0, 2.0);
		
		NezCubicBezier3d *groupPath = [[NezCubicBezier3d alloc] initWithControlPointsP0:p0 P1:p1 P2:p2 P3:p3];
		NezAnimationPath3d *groupAni = [letterGroup animationForPath:groupPath FinalOrientation:gameBoard.orientation Duration:2.5+randomFloatInRange(0.0, 0.5) EasingFunction:EASE_IN_CUBIC andDidStopBlock:didStopBlock];
		[NezAnimator addAnimation:groupAni];
	}];
}



@end
