//
//  NezGLViewController.m
//  Aletteration7
//
//  Created by David Nesbitt on 2013-08-28.
//  Copyright (c) 2013 Nezsoft. All rights reserved.
//

#import "NezAletterationGLKViewController.h"
#import "NezAletterationAppDelegate.h"
#import "NezAletterationGraphics.h"

@interface NezAletterationGLKViewController () {
	__weak NezAletterationGraphics *_graphics;
}

@property (strong, nonatomic) EAGLContext *context;

-(void)setupGL;
-(void)tearDownGL;

@end

@implementation NezAletterationGLKViewController

-(void)viewDidLoad {
	[super viewDidLoad];
	NSLog(@"NezAletterationGLKViewController viewDidLoad");
	
	self.context = [[EAGLContext alloc] initWithAPI:kEAGLRenderingAPIOpenGLES2];

	if (!self.context) {
		NSLog(@"Failed to create ES context");
	}
	GLKView *view = (GLKView *)self.view;
	view.context = self.context;

	[self setupGL];
}

-(void)dealloc {
    [self tearDownGL];
    
    if ([EAGLContext currentContext] == self.context) {
        [EAGLContext setCurrentContext:nil];
    }
}

-(void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];

    if ([self isViewLoaded] && ([[self view] window] == nil)) {
        self.view = nil;
        
        [self tearDownGL];
        
        if ([EAGLContext currentContext] == self.context) {
            [EAGLContext setCurrentContext:nil];
        }
        self.context = nil;
    }
}

-(void)setupGL {
	[EAGLContext setCurrentContext:self.context];
	
	_graphics = [NezAletterationAppDelegate sharedAppDelegate].graphics;

	glDisable(GL_DEPTH_TEST);
	glEnable(GL_CULL_FACE);
	glCullFace(GL_BACK);
	
	[self restoreRenderingFPS];
}

-(void)tearDownGL {
    [EAGLContext setCurrentContext:self.context];
}

-(void)setPaused:(BOOL)paused {
	NSLog(@"setPaused:%@", paused==YES?@"YES":@"NO");
	[super setPaused:paused];
	[_graphics setPaused:paused];
}

#pragma mark - GLKView and GLKViewController delegate methods

-(void)update {
	[_graphics update];
}

-(void)glkView:(GLKView *)view drawInRect:(CGRect)rect {
	[_graphics draw];
}

-(void)throttleRenderingFPS {
	NSLog(@"throttleRenderingFPS");
	self.preferredFramesPerSecond = 12;
}

-(void)restoreRenderingFPS {
	NSLog(@"restoreRenderingFPS");
	self.preferredFramesPerSecond = 30;
}

@end
