//
//  NezAletterationAnimationPushBackLetter.h
//  Aletteration3
//
//  Created by David Nesbitt on 2013/10/30.
//  Copyright (c) 2013 David Nesbitt. All rights reserved.
//

#import <GLKit/GLKit.h>
#import "NezGCD.h"

@interface NezAletterationAnimationPushBackLetter : NSObject

+(void)animatePushBackWithLetterStackList:(NSMutableArray*)letterStackList letterBlockListArray:(NSMutableArray*)letterBlockListArray color:(GLKVector4)color andCompletedHandler:(NezVoidBlock)completedHandler;


@end
