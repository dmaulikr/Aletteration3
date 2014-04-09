//
//  NezAletterationAnimationPushBackLetter.m
//  Aletteration3
//
//  Created by David Nesbitt on 2013/10/30.
//  Copyright (c) 2013 David Nesbitt. All rights reserved.
//

#import "NezAletterationAnimationPushBackLetter.h"
#import "NezAletterationAppDelegate.h"
#import "NezAletterationGraphics.h"
#import "NezAletterationLetterBlock.h"
#import "NezAletterationLetterStack.h"
#import "NezAletterationLetterStackLabel.h"
#import "NezAnimator.h"
#import "NezAnimation.h"

@implementation NezAletterationAnimationPushBackLetter

+(void)animatePushBackWithLetterStackList:(NSMutableArray*)letterStackList letterBlockListArray:(NSMutableArray*)letterBlockListArray color:(GLKVector4)color andCompletedHandler:(NezVoidBlock)completedHandler {
	float duration = 1.5;
	GLKVector3 letterBlockDimensions = [NezAletterationAppDelegate sharedAppDelegate].graphics.letterBlockDimensions;
	
	[letterStackList enumerateObjectsUsingBlock:^(NezAletterationLetterStack *stack, NSUInteger idx, BOOL *stop) {
		[stack.stackLabel animateColor:GLKVector4Make(0.0, 0.0, 0.0, 0.0)];
		GLKMatrix4 matrix = [stack nextModelMatrix];
		for (NezAletterationLetterBlock *block in letterBlockListArray[idx]) {
			[NezAnimator animateVec4WithFromData:block.color ToData:color Duration:0.75 EasingFunction:EASE_IN_OUT_CUBIC UpdateBlock:^(NezAnimation *ani) {
				GLKVector4 *color = (GLKVector4*)(ani.newData);
				block.color = *color;
			} DidStopBlock:^(NezAnimation *ani) {
			}];
			[NezAnimator animateMat4WithFromData:block.modelMatrix ToData:matrix Duration:duration EasingFunction:EASE_IN_OUT_CUBIC UpdateBlock:^(NezAnimation *ani) {
				GLKMatrix4 *mat = (GLKMatrix4*)(ani.newData);
				block.modelMatrix = *mat;
			} DidStopBlock:^(NezAnimation *ani) {
				[stack push:block];
			}];
			matrix = GLKMatrix4Translate(matrix, 0.0, 0.0, letterBlockDimensions.z);
		}
	}];
	[NezAnimator animateFloatWithFromData:0.0 ToData:1.0 Duration:duration EasingFunction:EASE_LINEAR UpdateBlock:^(NezAnimation *ani) {
	} DidStopBlock:^(NezAnimation *ani) {
		if (completedHandler) {
			completedHandler();
		}
	}];
}

@end
