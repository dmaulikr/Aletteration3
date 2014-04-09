//
//  NezAletterationAnimationExitGame.m
//  Aletteration3
//
//  Created by David Nesbitt on 2013/10/28.
//  Copyright (c) 2013 David Nesbitt. All rights reserved.
//

#import "NezAletterationAnimationExitGame.h"
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

@implementation NezAletterationAnimationExitGame

+(void)animateWithPlayerList:(NSArray*)playerList localPlayer:(NezAletterationPlayer*)localPlayer andDidStopHandler:(NezVoidBlock)didStopHandler {
	__weak NezAletterationGraphics *graphics = [NezAletterationAppDelegate sharedAppDelegate].graphics;
	__weak NezGLCamera *camera = graphics.camera;
	__weak NezAletterationGameTable *gameTable = graphics.gameTable;
	__weak NezAletterationBox *bigBox = gameTable.box;
	__weak NezAletterationLid *bigLid = bigBox.lid;
	__weak NezAletterationGameBoard *localGameBoard = localPlayer.gameBoard;

	GLKVector3 startEye = camera.eye;
	GLKQuaternion startOrientation = camera.orientation;
	
	GLKVector3 endEye = [localGameBoard modelCoordinateForPoint:GLKVector3Make(-4.0, -8.0, startEye.z+3.0)];
	GLKVector3 endTarget = [localGameBoard modelCoordinateForPoint:GLKVector3Make(0.0, 10.0, 0.0)];
	GLKVector3 endUpVector = GLKVector3Make(0,0,1);

	NezGLCamera *cam = [[NezGLCamera alloc] init];
	[cam setDefaultPerspectiveProjectionWithViewport:graphics.viewport];
	
	[cam lookAtEye:endEye target:endTarget upVector:endUpVector];
	GLKQuaternion endOrientation = cam.orientation;
	
	[camera stopLookingAtGeometry];

	[NezAnimator animateFloatWithFromData:0.0 ToData:1.0 Duration:2.0 EasingFunction:EASE_IN_OUT_QUAD UpdateBlock:^(NezAnimation *ani) {
		float t = ani.newData[0];
		
		GLKVector3 eye = GLKVector3Lerp(startEye, endEye, t);
		GLKQuaternion orientation = GLKQuaternionSlerp(startOrientation, endOrientation, t);
		[camera setEye:eye andOrientation:orientation];
	} DidStopBlock:^(NezAnimation *ani) {
		__weak NezGeometry *bigLidProxyObject = gameTable.lidProxyGeometry;
		[cam lookAtGeometry:bigLidProxyObject withZoomOptions:NezGLCameraZoomToWidth];

		NezCubicBezier3d *camPath = [NezCubicBezier3d bezierWithControlPointsP0:camera.eye P1Z:camera.eye.z+10.0 P2Z:cam.eye.z+10.0 P3:cam.eye];
		NezAnimationPath3d *camAni = [[NezAnimationPath3d alloc] initWithPath:camPath Duration:3.0 EasingFunction:EASE_IN_OUT_QUAD UpdateBlock:^(NezAnimationPath3d *ani, GLKVector3 eye) {
			float t = ani.newData[0];
			GLKQuaternion orientation = GLKQuaternionSlerp(endOrientation, cam.orientation, t);
			[camera setEye:eye andOrientation:orientation];
		} DidStopBlock:^(NezAnimation *ani) {
			camera.effectiveViewport = graphics.viewport;
			[camera lookAtGeometry:bigLidProxyObject withZoomOptions:NezGLCameraZoomToWidth];
			if (didStopHandler) {
				didStopHandler();
			}
		}];
		camAni.delay = 1.5;
		[NezAnimator addAnimation:camAni];
	}];
	
	[playerList enumerateObjectsUsingBlock:^(NezAletterationPlayer *player, NSUInteger idx, BOOL *stop) {
		__weak NezAletterationGameBoard *gameBoard = player.gameBoard;
		__weak NezAletterationLetterBox *box = gameBoard.letterBox;
		__weak NezAletterationLid *lid = box.lid;
		
		float initialBoxDelay = randomFloatInRange(0.25, 0.75);

		GLKQuaternion endOrientation = GLKQuaternionMultiply(gameBoard.orientation, GLKQuaternionMakeWithAngleAndAxis(1.25, 0.25, -0.35, 0.4));
		GLKVector3 boxCenter = GLKVector3Make(gameBoard.center.x, gameBoard.center.y, gameBoard.center.z+5.0);
		GLKMatrix4 boxMatrix = GLKMatrix4MakeWithQuaternionAndPostion(endOrientation, boxCenter);
		
		NezCubicBezier3d *boxPath = [NezCubicBezier3d bezierWithControlPointsP0:box.center P1Z:randomFloatInRange(10.0, 3.0) P1T:0.05 P2Z:randomFloatInRange(10.0, 3.0) P2T:0.75 P3:boxCenter];

		NezAnimationPath3d *boxAni = [box animationForPath:boxPath FinalOrientation:endOrientation Duration:2.5 EasingFunction:EASE_IN_OUT_CUBIC andDidStopBlock:^(NezAnimation *ani) {}];
		boxAni.delay = initialBoxDelay;
		[NezAnimator addAnimation:boxAni];

		GLKMatrix4 lidMatrix = [box lidMatrixForOrientation:endOrientation andPosition:boxCenter];
		GLKVector3 lidCenter = GLKVector3Make(lidMatrix.m30, lidMatrix.m31, lidMatrix.m32);
		NezCubicBezier3d *lidPath = [NezCubicBezier3d bezierWithControlPointsP0:lid.center P1Z:randomFloatInRange(12.0, 3.0) P1T:0.05 P2Z:randomFloatInRange(11.0, 3.0) P2T:1.0 P3:lidCenter];

		NezAnimationPath3d *lidAni = [lid animationForPath:lidPath FinalOrientation:endOrientation Duration:1.5 EasingFunction:EASE_IN_CUBIC andDidStopBlock:^(NezAnimation *ani) {
			[box attachBlocks];
			[box attachLid];
			
			GLKMatrix4 boxMatrix = [gameTable matrixForLetterBox:box andIndex:idx];
			GLKVector3 boxCenter = GLKVector3Make(boxMatrix.m30, boxMatrix.m31, boxMatrix.m32);
			GLKQuaternion boxOrientation = GLKQuaternionMakeWithMatrix4(boxMatrix);
			
			NezCubicBezier3d *boxPath = [NezCubicBezier3d bezierWithControlPointsP0:box.center P1Z:randomFloatInRange(11.0, 3.0) P1T:0.25 P2Z:randomFloatInRange(12.0, 3.0) P2T:0.95 P3:boxCenter];
			NezAnimationPath3d *boxAni = [box animationForPath:boxPath FinalOrientation:boxOrientation Duration:1.5 EasingFunction:EASE_IN_OUT_CUBIC andDidStopBlock:^(NezAnimation *ani) {}];
			[NezAnimator addAnimation:boxAni];
			
			GLKMatrix4 bigLidMatrix = [bigBox lidMatrix];
			GLKVector3 bigLidCenter = GLKVector3Make(bigLidMatrix.m30, bigLidMatrix.m31, bigLidMatrix.m32);
			[NezAnimator animateVec3WithFromData:bigLid.center ToData:bigLidCenter Duration:2.5 EasingFunction:EASE_OUT_CUBIC UpdateBlock:^(NezAnimation *ani) {
				GLKVector3 *center = (GLKVector3*)ani.newData;
				bigLid.center = *center;
			} DidStopBlock:^(NezAnimation *ani) {}];
		}];
		lidAni.delay = initialBoxDelay+1.5;
		[NezAnimator addAnimation:lidAni];
		
		[gameBoard moveBlocksFromStacksToLetterBox];
		[NezAletterationAnimationExitGame animateLetterGroupList:box.row1GroupList toLetterBox:box letterBoxMatrix:boxMatrix delay:initialBoxDelay+0.75 andDidStopBlock:^(NezAnimation *ani) {}];
		[NezAletterationAnimationExitGame animateLetterGroupList:box.row2GroupList toLetterBox:box letterBoxMatrix:boxMatrix delay:initialBoxDelay+0.75 andDidStopBlock:^(NezAnimation *ani) {}];

		
		GLKVector4 lineStartColor = gameBoard.color;
		[NezAnimator animateFloatWithFromData:0.5 ToData:0.0 Duration:2.5 EasingFunction:EASE_IN_OUT_CUBIC UpdateBlock:^(NezAnimation *ani) {
			[gameBoard setLineColor:GLKVector4Make(lineStartColor.r, lineStartColor.g, lineStartColor.b, ani.newData[0])];
		} DidStopBlock:^(NezAnimation *ani) {
		}].delay = 1.0;
	}];
}

+(void)animateLetterGroupList:(NSMutableArray*)letterGroupList toLetterBox:(NezAletterationLetterBox*)letterBox letterBoxMatrix:(GLKMatrix4)letterBoxMatrix delay:(float)delay andDidStopBlock:(NezAnimationBlock)didStopBlock {
	[letterGroupList enumerateObjectsUsingBlock:^(NezAletterationLetterGroup *letterGroup, NSUInteger idx, BOOL *stop) {
		GLKMatrix4 groupMatrix = [letterBox matrixForLetterGroup:letterGroup withMatrix:letterBoxMatrix];
		GLKQuaternion orientation = GLKQuaternionMakeWithMatrix4(groupMatrix);
		
		GLKVector3 p0 = letterGroup.center;
		GLKVector3 p3 = GLKVector3Make(groupMatrix.m30, groupMatrix.m31, groupMatrix.m32);
		GLKVector3 p1 = GLKVector3Lerp(p0, p3, 0.05);
		p1.z = randomFloatInRange(11.0, 2.0);
		GLKVector3 p2 = GLKVector3Lerp(p0, p3, 0.95);
		p2.z = randomFloatInRange(12.0, 2.0);
		
		NezCubicBezier3d *groupPath = [[NezCubicBezier3d alloc] initWithControlPointsP0:p0 P1:p1 P2:p2 P3:p3];
		NezAnimationPath3d *groupAni = [letterGroup animationForPath:groupPath FinalOrientation:orientation Duration:1.5+randomFloatInRange(0.0, 0.5) EasingFunction:EASE_IN_CUBIC andDidStopBlock:didStopBlock];
		groupAni.delay = delay;
		[NezAnimator addAnimation:groupAni];
	}];
}

@end
