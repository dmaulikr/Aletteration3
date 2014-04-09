//
//  NezAletterationAnimationViewNextGameBoard.h
//  Aletteration3
//
//  Created by David Nesbitt on 2013-09-24.
//  Copyright (c) 2013 David Nesbitt. All rights reserved.
//

#import <GLKit/GLKit.h>

@class NezCubicBezier3d;
@class NezAletterationGameBoard;
@class NezGLCamera;

@interface NezAletterationAnimationNextGameBoard : NSObject

@property GLKQuaternion startOrientation;
@property GLKQuaternion endOrientation;

-(instancetype)initWithBoard:(NezAletterationGameBoard*)board nextBoard:(NezAletterationGameBoard*)nextBoard;

-(void)lookAtPathLocation:(float)t withCamera:(NezGLCamera*)camera;

@end
