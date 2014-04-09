//
//  NezAletterationAnimationRetireWord.m
//  Aletteration3
//
//  Created by David Nesbitt on 2013/10/29.
//  Copyright (c) 2013 David Nesbitt. All rights reserved.
//

#import "NezAletterationAppDelegate.h"
#import "NezAletterationGraphics.h"
#import "NezAletterationAnimationRetireWord.h"
#import "NezAletterationRetiredWord.h"
#import "NezAletterationLetterBlock.h"
#import "NezAletterationGameBoard.h"
#import "NezAletterationRetiredWordBoard.h"
#import "NezCubicBezier3d.h"
#import "NezAnimationPath3d.h"
#import "NezAnimationPath3d.h"
#import "NezVertexArrayObjectParticleEmitter.h"
#import "NezVertexBufferObjectParticleVertex.h"
#import "NezVertexArrayObjectAcceleratingParticleEmitter.h"
#import "NezVertexBufferObjectLitVertex.h"
#import "NezVertexArrayObjectGeometryEmitter.h"
#import "NezVertexArrayObjectTexturedGeometryEmitter.h"
#import "NezInstanceAttributeBufferObjectGeometryParticle.h"
#import "NezAletterationTextureBlock.h"
#import "NezRandom.h"
#import "NezGCD.h"

@implementation NezAletterationAnimationRetireWord

+(void)animateWithRetiredWord:(NezAletterationRetiredWord*)retiredWord gameBoard:(NezAletterationGameBoard*)gameBoard andDidStopBlock:(NezAnimationBlock)didStopBlock {
	__weak NezAletterationGraphics *graphics = [NezAletterationAppDelegate sharedAppDelegate].graphics;
	__weak NezAletterationTextureBlock *congratulationWord = graphics.congratulationWord;
	
	GLKMatrix4 matrix = [gameBoard.retiredWordBoard nextWordMatrix];
	GLKQuaternion endOrientation = GLKQuaternionMakeWithMatrix4(matrix);
	
	GLKVector3 letterBlockDimensions = graphics.letterBlockDimensions;
	GLKVector3 endTarget = [gameBoard modelCoordinateForPoint:GLKVector3Make(-retiredWord.dimensions.x*0.5+letterBlockDimensions.x*0.5, letterBlockDimensions.y*2.0, letterBlockDimensions.x*3.0)];

	GLKVector3 congratulationWordStart = [gameBoard modelCoordinateForPoint:GLKVector3Make(-gameBoard.dimensions.x, -letterBlockDimensions.y*1.73, endTarget.z)];
	GLKVector3 congratulationWordEnd = [gameBoard modelCoordinateForPoint:GLKVector3Make(0.0, -letterBlockDimensions.y*1.0, endTarget.z)];
	GLKVector3 badgeEnd = [gameBoard modelCoordinateForPoint:GLKVector3Make(0.0, -letterBlockDimensions.y*1.0, endTarget.z)];

	__weak NezAletterationLetterBlock *currentLetterBlock = gameBoard.currentLetterBlock;
	GLKVector3 currentLetterBlockCenter, currentLetterBlockOffScreenCenter;
	if (currentLetterBlock) {
		currentLetterBlockCenter =currentLetterBlock.center;
		currentLetterBlockOffScreenCenter = currentLetterBlockCenter;
		currentLetterBlockOffScreenCenter.y -= gameBoard.dimensions.y;
		[NezAnimator animateVec3WithFromData:currentLetterBlockCenter ToData:currentLetterBlockOffScreenCenter Duration:0.5 EasingFunction:EASE_IN_CUBIC UpdateBlock:^(NezAnimation *ani) {
			currentLetterBlock.center = *((GLKVector3*)ani.newData);
		} DidStopBlock:^(NezAnimation *ani) {}];
	}
	
	[NezAnimator animateVec3WithFromData:congratulationWordStart ToData:congratulationWordEnd Duration:1.5 EasingFunction:EASE_OUT_ELASTIC UpdateBlock:^(NezAnimation *ani) {
		congratulationWord.center = *((GLKVector3*)ani.newData);
	} DidStopBlock:^(NezAnimation *ani) {
	}];

	NSInteger rayCount = ((retiredWord.letterBlockList.count-3)*2)+(retiredWord.bonusLetterCount)*3;
	for (NSInteger i=0; i<rayCount; i++) {
		[NezGCD dispatchBlock:^{
			[self startScoreRaysCounterAtLocation:badgeEnd];
		} afterSeconds:0.25*i+1.5];
	}
	
	NezCubicBezier3d *retiredWordPath = [NezCubicBezier3d bezierWithControlPointsP0:retiredWord.center P1Z:2.0 P1T:0.25 P2Z:2.5 P2T:0.75 P3:endTarget];
	NezAnimationPath3d *retiredWordAni = [retiredWord animationForPath:retiredWordPath FinalOrientation:endOrientation Duration:1.0 EasingFunction:EASE_IN_OUT_CUBIC andDidStopBlock:^(NezAnimation *ani) {
		__block int count = 0;
		[retiredWord.letterBlockList enumerateObjectsUsingBlock:^(NezAletterationLetterBlock *letterBlock, NSUInteger idx, BOOL *stop) {
			if (idx == 0 || idx >= 4) {
				float delay = count*0.5;
				if (retiredWord.letterBlockList.count == 4 || idx == retiredWord.letterBlockList.count-1) {
					*stop = YES;
					[self setPointLineWithLetterBlock:letterBlock andEndPoint:badgeEnd delay:delay andCompletionHandler:^(BOOL finished){
						[self startFireworksAtLocation:badgeEnd];
						[self animateBonusLettersWithRetiredWord:retiredWord badgePosition:badgeEnd andCompletionHandler:^(BOOL finished){
							[NezAnimator animateMat4WithFromData:retiredWord.modelMatrix ToData:matrix Duration:1.0 EasingFunction:EASE_IN_OUT_CUBIC UpdateBlock:^(NezAnimation *ani) {
								retiredWord.modelMatrix = *((GLKMatrix4*)ani.newData);
							} DidStopBlock:^(NezAnimation *ani) {
								if (didStopBlock) {
									didStopBlock(ani);
								}
							}];
							[NezAnimator animateVec3WithFromData:currentLetterBlockOffScreenCenter ToData:currentLetterBlockCenter Duration:0.5 EasingFunction:EASE_OUT_CUBIC UpdateBlock:^(NezAnimation *ani) {
								currentLetterBlock.center = *((GLKVector3*)ani.newData);
							} DidStopBlock:^(NezAnimation *ani) {}];
						}];
					}];
				} else {
					[NezAletterationAnimationRetireWord setPointLineWithLetterBlock:letterBlock andEndPoint:badgeEnd delay:delay andCompletionHandler:^(BOOL finished){
						[self startFireworksAtLocation:badgeEnd];
					}];
				}
				count++;
			}
		}];
	}];
	[NezAnimator addAnimation:retiredWordAni];
}

+(void)animateBonusLettersWithRetiredWord:(NezAletterationRetiredWord*)retiredWord badgePosition:(GLKVector3)badgePosition andCompletionHandler:(NezCompletionHandler)completionHandler {
	__block NSInteger count = 0;
	[retiredWord.letterBlockList enumerateObjectsUsingBlock:^(NezAletterationLetterBlock *letterBlock, NSUInteger idx, BOOL *stop) {
		if (letterBlock.isBonus) {
			GLKMatrix4 matrix = letterBlock.modelMatrix;
			__block float lastFiringAngle = 0;
			[NezAnimator animateVec2WithFromData:GLKVector2Make(0.0, 0.0) ToData:GLKVector2Make(2.0*M_PI, 1.0) Duration:1.0 EasingFunction:EASE_LINEAR UpdateBlock:^(NezAnimation *ani) {
				float angle = ani.newData[0];
				float zOffset = ani.newData[1];
				GLKMatrix4 rotMatrix = GLKMatrix4MakeYRotation(angle);
				rotMatrix.m32 = zOffset;
				letterBlock.modelMatrix = GLKMatrix4Multiply(matrix, rotMatrix);
				if (angle >= lastFiringAngle+((45.0*M_PI)/180.0) || lastFiringAngle == 0.0) {
					lastFiringAngle = angle;
					GLKVector4 color;
					NSInteger colorIndex = ((int)(ani.t*8.0))%4;
					if (colorIndex == 0) {
						color = GLKVector4Make(1.0, 0.0, 0.0, 1.0);
					} else if (colorIndex == 1) {
						color = GLKVector4Make(1.0, 1.0, 0.0, 1.0);
					} else if (colorIndex == 2) {
						color = GLKVector4Make(0.0, 1.0, 0.0, 1.0);
					} else {
						color = GLKVector4Make(0.0, 0.0, 1.0, 1.0);
					}
					[self startFireSpinnerAtLocation:letterBlock.center yRotation:0.0 andColor:color];
				}
			} DidStopBlock:^(NezAnimation *ani) {
				[self setPointLineWithLetterBlock:letterBlock andEndPoint:badgePosition delay:0.0 andCompletionHandler:^(BOOL finished){
					[self startFireworksAtLocation:badgePosition];
				}];
				[NezAnimator animateFloatWithFromData:letterBlock.center.z ToData:matrix.m32 Duration:0.5 EasingFunction:EASE_IN_QUAD UpdateBlock:^(NezAnimation *ani) {
					letterBlock.center = GLKVector3Make(matrix.m30, matrix.m31, ani.newData[0]);
				} DidStopBlock:^(NezAnimation *ani) {
					letterBlock.modelMatrix = matrix;
				}];
			}].delay = count*1.0;
			count++;
		}
	}];
	if (completionHandler) {
		[NezGCD dispatchBlock:^{
			completionHandler(YES);
		} afterSeconds:2.0+count*1.0];
	}
}

+(void)setPointLineWithLetterBlock:(NezAletterationLetterBlock*)letterBlock andEndPoint:(GLKVector3)p3 delay:(float)delay andCompletionHandler:(NezCompletionHandler)completionHandler {
	__weak NezAletterationGraphics *graphics = [NezAletterationAppDelegate sharedAppDelegate].graphics;

	GLKVector3 p0 = letterBlock.center;
	
	float dx = p3.x-p0.x;
	float dy = p3.y-p0.y;
	
	GLKVector3 p1 = GLKVector3Make(p0.x+dx*0.25, p0.y+dy*0.25, randomFloatInRange(6.0, 3.0));
	GLKVector3 p2 = GLKVector3Make(p0.x+dx*0.75, p0.y+dy*0.75, randomFloatInRange(6.0, 3.0));

	NezCubicBezier3d *emitterPath = [NezCubicBezier3d bezierWithControlPointsP0:p0 P1:p1 P2:p2 P3:p3];
	__weak NezVertexArrayObjectParticleEmitter *pointLineEmitter = graphics.nextPointLineEmitter;
	
	float growth = randomFloatInRange(0.25, 0.25);
	float stable = randomFloatInRange(0.0, 0.125);
	float decay = 0.25;
	
	pointLineEmitter.life = growth+stable+decay;
	pointLineEmitter.color0 = GLKVector4Make(randomFloatInRange(0.125, 0.5), randomFloatInRange(0.125, 0.5), randomFloatInRange(0.125, 0.5), 1.0);
	pointLineEmitter.color1 = GLKVector4Make(randomFloatInRange(0.125, 0.5), randomFloatInRange(0.125, 0.5), randomFloatInRange(0.125, 0.5), 1.0);
	pointLineEmitter.size = 3.0;
	[self setPointLineVertices:pointLineEmitter.vertexBufferObject forPath:emitterPath growth:growth stable:stable decay:decay];
	
	[NezGCD dispatchBlock:^{
		[pointLineEmitter startWithCompletionHandler:completionHandler];
	} afterSeconds:delay];
}

+(void)setPointLineVertices:(NezVertexBufferObjectParticleVertex*)vbo forPath:(NezCubicBezier3d*)emitterPath growth:(float)growth stable:(float)stable decay:(float)decay {
	NezParticleVertex *vertexList = vbo.vertexList;
	float fCount = vbo.vertexCount-1;
	for (int i=0,n=vbo.vertexCount; i<n; i++) {
		float t = ((float)(i)/fCount);
		vertexList[i].position = [emitterPath positionAt:t];
		vertexList[i].velocity = GLKVector3Make(0.0, 0.0, 0.0);
		vertexList[i].growth = growth*t;
		vertexList[i].stable = stable;
		vertexList[i].decay = decay;
	}
	[vbo fillVertexData];
}

+(void)startFireworksAtLocation:(GLKVector3)position {
	__weak NezAletterationGraphics *graphics = [NezAletterationAppDelegate sharedAppDelegate].graphics;
	__weak NezVertexArrayObjectAcceleratingParticleEmitter *emitter = graphics.nextStarEmitter;
	__weak NezVertexBufferObjectParticleVertex *vbo = emitter.vertexBufferObject;

	NezParticleVertex *vertexList = vbo.vertexList;
	double dlong = M_PI*(3.0-sqrt(5.0));  // ~2.39996323
	double dz    = 2.0/vbo.vertexCount;
	double theta = 0.0;
	double z     = (1.0 - dz/2.0);
	for (int k=0;k<vbo.vertexCount;k++) {
		double r = sqrt(1.0-z*z)+randomFloatInRange(-0.25, 0.5);
		GLKVector3 v = GLKVector3Make((cos(theta)*r)*3.5, (sin(theta)*r)*3.5, z*3.5);
		vertexList[k].velocity = v;
		z -= dz;
		theta += dlong;
	}
	[vbo fillVertexData];
	
	emitter.center = position;
	emitter.acceleration = GLKVector3Make(0.0, -4.0, 0.0);
	emitter.size = 5.0f;
	emitter.growth = 5.0f;
	emitter.decay = 1.25f;
	emitter.color0 = GLKVector4Make(1.0, 1.0, 1.0, 1.0);
	emitter.color1 = GLKVector4Make(1.0, 1.0, 1.0, 1.0);
	
	[emitter start];
}

+(void)startFireSpinnerAtLocation:(GLKVector3)position yRotation:(float)yRotation andColor:(GLKVector4)color {
	__weak NezAletterationGraphics *graphics = [NezAletterationAppDelegate sharedAppDelegate].graphics;
	__weak NezVertexArrayObjectGeometryEmitter *emitter = graphics.nextGeometryStarEmitter;
	__weak NezInstanceAttributeBufferObjectGeometryParticle *abo = emitter.instanceAttributeBufferObject;
	
	GLKQuaternion orientation = GLKQuaternionMakeWithAngleAndAxis(yRotation, 0.0, 1.0, 0.0);
	double theta = 0.0;
	NezInstanceAttributeGeometryParticle *attributeList = abo.instanceAttributeList;
	for (int k=0, n=abo.instanceCount;k<n;k++) {
		attributeList[k].color0 = GLKVector4Make(color.r, color.g, color.b, color.a);
		attributeList[k].color1 = GLKVector4Make(color.r, color.g, color.b, 0.0);
		attributeList[k].orientation = orientation;
		attributeList[k].angularVelocity = GLKQuaternionMake(0.0, 0.0, 0.75, 0.0);
		attributeList[k].scale = GLKVector3Make(1.0, 1.0, 1.0);
		
		theta = ((double)k/(double)n)*(2.0*M_PI);
		attributeList[k].velocity = GLKQuaternionRotateVector3(orientation, GLKVector3Make(cos(theta), sin(theta), 0.0));
	}
	[abo fillInstanceData];
	
	emitter.growth = 0.75f;
	emitter.decay = 0.25f;
	emitter.center = position;
	emitter.acceleration = GLKVector3Make(0.0, 0.0, 0.0);
	
	[emitter start];
}

+(void)startScoreRaysCounterAtLocation:(GLKVector3)position {
	__weak NezAletterationGraphics *graphics = [NezAletterationAppDelegate sharedAppDelegate].graphics;
	__weak NezVertexArrayObjectTexturedGeometryEmitter *emitter = graphics.nextScoreRaysEmitter;

	emitter.growth = 2.0f;
	emitter.decay = 3.0f;
	emitter.center = position;
	
	[emitter start];
}

@end
