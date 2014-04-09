//
//  NezAnimator.m
//  Aletteration
//
//  Created by David Nesbitt on 2/12/11.
//  Copyright 2011 David Nesbitt. All rights reserved.
//

#import "NezAnimator.h"
#import "NezAnimation.h"

//This class is NOT thread safe!!!

NSMutableArray *animationList;
NSMutableArray *addedList;
NSMutableArray *removedList;

@implementation NezAnimator

+(void)initialize {
    static BOOL initialized = NO;
    if(!initialized) {
        initialized = YES;

		animationList = [NSMutableArray arrayWithCapacity:128];
		addedList = [NSMutableArray arrayWithCapacity:128];
		removedList = [NSMutableArray arrayWithCapacity:128];
	}
}

+(NezAnimation*)animateFloatWithFromData:(float)from ToData:(float)to Duration:(NSTimeInterval)d EasingFunction:(EasingFunctionPtr)func UpdateBlock:(NezAnimationBlock)updateBlock DidStopBlock:(NezAnimationBlock)didStopBlock {
	return [NezAnimator addAnimation:[[NezAnimation alloc] initFloatWithFromData:from ToData:to Duration:d EasingFunction:func UpdateBlock:updateBlock DidStopBlock:didStopBlock]];
}

+(NezAnimation*)animateVec2WithFromData:(GLKVector2)from ToData:(GLKVector2)to Duration:(NSTimeInterval)d EasingFunction:(EasingFunctionPtr)func UpdateBlock:(NezAnimationBlock)updateBlock DidStopBlock:(NezAnimationBlock)didStopBlock {
	return [NezAnimator addAnimation:[[NezAnimation alloc] initVec2WithFromData:from ToData:to Duration:d EasingFunction:func UpdateBlock:updateBlock DidStopBlock:didStopBlock]];
}

+(NezAnimation*)animateVec3WithFromData:(GLKVector3)from ToData:(GLKVector3)to Duration:(NSTimeInterval)d EasingFunction:(EasingFunctionPtr)func UpdateBlock:(NezAnimationBlock)updateBlock DidStopBlock:(NezAnimationBlock)didStopBlock {
	return [NezAnimator addAnimation:[[NezAnimation alloc] initVec3WithFromData:from ToData:to Duration:d EasingFunction:func UpdateBlock:updateBlock DidStopBlock:didStopBlock]];
}

+(NezAnimation*)animateVec4WithFromData:(GLKVector4)from ToData:(GLKVector4)to Duration:(NSTimeInterval)d EasingFunction:(EasingFunctionPtr)func UpdateBlock:(NezAnimationBlock)updateBlock DidStopBlock:(NezAnimationBlock)didStopBlock {
	return [NezAnimator addAnimation:[[NezAnimation alloc] initVec4WithFromData:from ToData:to Duration:d EasingFunction:func UpdateBlock:updateBlock DidStopBlock:didStopBlock]];
}

+(NezAnimation*)animateMat4WithFromData:(GLKMatrix4)from ToData:(GLKMatrix4)to Duration:(NSTimeInterval)d EasingFunction:(EasingFunctionPtr)func UpdateBlock:(NezAnimationBlock)updateBlock DidStopBlock:(NezAnimationBlock)didStopBlock {
	return [NezAnimator addAnimation:[[NezAnimation alloc] initMat4WithFromData:from ToData:to Duration:d EasingFunction:func UpdateBlock:updateBlock DidStopBlock:didStopBlock]];
}

+(NezAnimation*)addAnimation:(NezAnimation*)animation {
	if (animation) {
		[addedList addObject:animation];
	}
	return animation;
}

+(void)removeAnimation:(NezAnimation*)animation {
	if (animation) {
		[removedList addObject:animation];
	}
}

+(void)removeAllAnimations {
	[removedList addObjectsFromArray:animationList];
}

+(void)cancelAnimation:(NezAnimation*)animation {
	if (animation) {
		animation.cancelled = YES;
		[removedList addObject:animation];
	}
}

+(void)updateWithTimeSinceLastUpdate:(NSTimeInterval)timeSinceLastUpdate {
	if ([removedList count] > 0) {
		[animationList removeObjectsInArray:removedList];
		[removedList removeAllObjects];
	}
	if ([addedList count] > 0) {
		for (NezAnimation *animation in addedList) {
			animation.elapsedTime = -animation.delay;
			[animationList addObject:animation];
		}
		[addedList removeAllObjects];
	}
	for (NezAnimation *ani in animationList) {
		if (!ani.cancelled) {
			ani.elapsedTime += timeSinceLastUpdate;
			if (ani.elapsedTime >= ani.duration) {
				ani.elapsedTime = ani.duration;
				for (int i=0; i<ani.dataLength; i++) {
					ani.newData[i] = ani.toData[i];
				}
				if (--ani.repeatCount > 0 || ani.loop == NEZ_ANI_LOOP_FORWARD) {
					if (ani.didStopBlock != NULL) {
						ani.didStopBlock(ani);
					}
					ani.updateFrameBlock(ani);
					ani.elapsedTime = -ani.delay;
				} else if(ani.loop == NEZ_ANI_LOOP_PINGPONG) {
					if (ani.didStopBlock != NULL) {
						ani.didStopBlock(ani);
					}
					ani.updateFrameBlock(ani);
					[ani pingPongAnimation];
				} else {
					ani.updateFrameBlock(ani);
					if (ani.chainLink) {
						[self addAnimation:ani.chainLink];
						ani.chainLink.elapsedTime = -ani.chainLink.delay;
						ani.chainLink = nil;
					}
					if (ani.removedWhenFinished) {
						[self removeAnimation:ani];
					}
					if (ani.didStopBlock != NULL) {
						ani.didStopBlock(ani);
					}
				}
			} else if(ani.elapsedTime >= 0) {
				if (ani.didStartBlock) {
					ani.didStartBlock(ani);
					ani.didStartBlock = NULL;
				}
				[ani runToElapsedTime];
				ani.updateFrameBlock(ani);
			}
		}
	}
}

@end
