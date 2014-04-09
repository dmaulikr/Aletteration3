//
//  NezAletterationAnimationBeginGame.h
//  Aletteration3
//
//  Created by David Nesbitt on 2013/10/27.
//  Copyright (c) 2013 David Nesbitt. All rights reserved.
//

#import <GLKit/GLKit.h>
#import "NezGCD.h"

@class NezAletterationPlayer;

@interface NezAletterationAnimationBeginGame : NSObject

+(void)animateWithPlayerList:(NSArray*)playerList localPlayer:(NezAletterationPlayer*)localPlayer andDidStopHandler:(NezVoidBlock)didStopHandler;

@end
