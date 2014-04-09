//
//  NezAletterationAnimationSlide.h
//  Aletteration3
//
//  Created by David Nesbitt on 2013/11/08.
//  Copyright (c) 2013 David Nesbitt. All rights reserved.
//

#import <GLKit/GLKit.h>

@class NezGeometry;
@class NezGLCamera;

@interface NezAletterationAnimationSlide : NSObject {
	NezGeometry *_fromGeometry;
	NezGeometry *_toGeometry;
	NezGLCamera *_cam;
}

-(instancetype)initWithFromGeometry:(NezGeometry*)fromGeometry toGeometry:(NezGeometry*)toGeometry;

-(void)scrollToPositionWithTime:(float)t andCamera:(NezGLCamera*)camera;

@end
