//
//  NezPath2dAnimation.h
//  Aletteration3
//
//  Created by David Nesbitt on 2013/11/09.
//  Copyright (c) 2013 David Nesbitt. All rights reserved.
//

#import "NezAnimation.h"

@class NezAnimationPath2d;
@class NezPath2d;

typedef void (^NezAnimationPath2dBlock)(NezAnimationPath2d *ani, GLKVector2 positionOnPath);

@interface NezAnimationPath2d : NezAnimation {
}

@property(nonatomic, strong) NezPath2d *path;

-(instancetype)initWithPath:(NezPath2d*)path Duration:(CFTimeInterval)d EasingFunction:(EasingFunctionPtr)func UpdateBlock:(NezAnimationPath2dBlock)updateBlock DidStopBlock:(NezAnimationBlock)didStopBlock;

@end