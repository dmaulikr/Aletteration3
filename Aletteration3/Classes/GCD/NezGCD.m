//
//  NezGCD.m
//  Aletteration2
//
//  Created by David Nesbitt on 2012-10-21.
//  Copyright (c) 2012 David Nesbitt. All rights reserved.
//

#import "NezGCD.h"

@interface PrivateNezGCD : NSObject

+(void)runOnPriorityQueue:(int)queueType WithWorkBlock:(NezVoidBlock)workBlock DoneBlock:(NezVoidBlock)doneBlock;

@end

@implementation PrivateNezGCD

//This function runs workBlock in the a Priority Thread and then when that's done runs doneBlock in the Main Thread
+(void)runOnPriorityQueue:(int)queueType WithWorkBlock:(NezVoidBlock)workBlock DoneBlock:(NezVoidBlock)doneBlock {
	dispatch_async(dispatch_get_global_queue(queueType, 0), ^{
		if (workBlock != NULL) {
			workBlock();
		}
		if (doneBlock != NULL) {
			dispatch_async(dispatch_get_main_queue(), ^{
				doneBlock();
			});
		}
	});
}

@end

@implementation NezGCD

//This function runs workBlock in the High Priority Queue and then when that's done runs doneBlock in the Main Thread
+(void)runHighPriorityWithWorkBlock:(NezVoidBlock)workBlock DoneBlock:(NezVoidBlock)doneBlock {
	[PrivateNezGCD runOnPriorityQueue:DISPATCH_QUEUE_PRIORITY_HIGH WithWorkBlock:workBlock DoneBlock:doneBlock];
}

//This function runs workBlock in the Default Priority Queue and then when that's done runs doneBlock in the Main Thread
+(void)runDefaultPriorityWithWorkBlock:(NezVoidBlock)workBlock DoneBlock:(NezVoidBlock)doneBlock {
	[PrivateNezGCD runOnPriorityQueue:DISPATCH_QUEUE_PRIORITY_DEFAULT WithWorkBlock:workBlock DoneBlock:doneBlock];
}

//This function runs workBlock in the Low Priority Queue and then when that's done runs doneBlock in the Main Thread
+(void)runLowPriorityWithWorkBlock:(NezVoidBlock)workBlock DoneBlock:(NezVoidBlock)doneBlock {
	[PrivateNezGCD runOnPriorityQueue:DISPATCH_QUEUE_PRIORITY_LOW WithWorkBlock:workBlock DoneBlock:doneBlock];
}

//This function runs workBlock in the Background Priority Queue and then when that's done runs doneBlock in the Main Thread
+(void)runBackgroundPriorityWithWorkBlock:(NezVoidBlock)workBlock DoneBlock:(NezVoidBlock)doneBlock {
	[PrivateNezGCD runOnPriorityQueue:DISPATCH_QUEUE_PRIORITY_BACKGROUND WithWorkBlock:workBlock DoneBlock:doneBlock];
}

//calls dispatch_after using the block and dispatch_get_main_queue after number of milliseconds
+(void)dispatchBlock:(NezVoidBlock)block afterMilliseconds:(double)milliseconds {
	if (block != NULL) {
		dispatch_after(dispatch_time(DISPATCH_TIME_NOW, milliseconds * NSEC_PER_MSEC), dispatch_get_main_queue(), block);
	}
}

//calls dispatch_after using the block and dispatch_get_main_queue after number of seconds
+(void)dispatchBlock:(NezVoidBlock)block afterSeconds:(double)seconds {
	if (block != NULL) {
		dispatch_after(dispatch_time(DISPATCH_TIME_NOW, seconds * NSEC_PER_SEC), dispatch_get_main_queue(), block);
	}
}

@end
