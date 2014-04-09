//
//  NezGCD.h
//  Aletteration2
//
//  Created by David Nesbitt on 2012-10-21.
//  Copyright (c) 2012 David Nesbitt. All rights reserved.
//

typedef void (^ NezVoidBlock)(void);
typedef void (^ NezCompletionHandler)(BOOL finished);

@interface NezGCD : NSObject

//This function runs workBlock in the High Priority Thread and then when that's done runs doneBlock in the Main Thread
+(void)runHighPriorityWithWorkBlock:(NezVoidBlock)workBlock DoneBlock:(NezVoidBlock)doneBlock;

//This function runs workBlock in the Default Priority Thread and then when that's done runs doneBlock in the Main Thread
+(void)runDefaultPriorityWithWorkBlock:(NezVoidBlock)workBlock DoneBlock:(NezVoidBlock)doneBlock;

//This function runs workBlock in the Low Priority Thread and then when that's done runs doneBlock in the Main Thread
+(void)runLowPriorityWithWorkBlock:(NezVoidBlock)workBlock DoneBlock:(NezVoidBlock)doneBlock;

//This function runs workBlock in the Background Priority Thread and then when that's done runs doneBlock in the Main Thread
+(void)runBackgroundPriorityWithWorkBlock:(NezVoidBlock)workBlock DoneBlock:(NezVoidBlock)doneBlock;

//calls dispatch_after using the block and dispatch_get_main_queue after number of milliseconds
+(void)dispatchBlock:(NezVoidBlock)block afterMilliseconds:(double)milliseconds;

//calls dispatch_after using the block and dispatch_get_main_queue after number of seconds
+(void)dispatchBlock:(NezVoidBlock)block afterSeconds:(double)seconds;

@end
