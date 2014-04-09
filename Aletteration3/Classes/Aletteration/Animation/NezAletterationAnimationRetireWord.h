//
//  NezAletterationAnimationRetireWord.h
//  Aletteration3
//
//  Created by David Nesbitt on 2013/10/29.
//  Copyright (c) 2013 David Nesbitt. All rights reserved.
//

#import "NezAnimator.h"

@class NezAletterationRetiredWord;
@class NezAletterationGameBoard;

@interface NezAletterationAnimationRetireWord : NSObject

+(void)animateWithRetiredWord:(NezAletterationRetiredWord*)retiredWord gameBoard:(NezAletterationGameBoard*)gameBoard andDidStopBlock:(NezAnimationBlock)didStopBlock;

@end
