//
//  NezGLViewController.h
//  Aletteration7
//
//  Created by David Nesbitt on 2013-08-28.
//  Copyright (c) 2013 Nezsoft. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <GLKit/GLKit.h>

@interface NezAletterationGLKViewController : GLKViewController

-(void)update;

-(void)throttleRenderingFPS;
-(void)restoreRenderingFPS;

@end
