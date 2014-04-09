//
//  NezPathAnimation.h
//  Aletteration3
//
//  Created by David Nesbitt on 2013/10/25.
//  Copyright (c) 2013 David Nesbitt. All rights reserved.
//

#import "NezAnimation.h"

@class NezAnimationPath3d;
@class NezPath3d;

typedef void (^NezAnimationPath3dBlock)(NezAnimationPath3d *ani, GLKVector3 positionOnPath);

@interface NezAnimationPath3d : NezAnimation {
}

@property(nonatomic, strong) NezPath3d *path;

-(instancetype)initWithPath:(NezPath3d*)path Duration:(CFTimeInterval)d EasingFunction:(EasingFunctionPtr)func UpdateBlock:(NezAnimationPath3dBlock)updateBlock DidStopBlock:(NezAnimationBlock)didStopBlock;

@end