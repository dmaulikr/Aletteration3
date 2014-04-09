//
//  NezAletterationMainMenuViewController.h
//  Aletteration3
//
//  Created by David Nesbitt on 2013-09-29.
//  Copyright (c) 2013 David Nesbitt. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "NezGameCenter.h"

@interface NezAletterationMainMenuViewController : UIViewController<GKLocalPlayerListener>

-(IBAction)unwindToMainMenuViewController:(UIStoryboardSegue *)unwindSegue;
-(IBAction)playRealTimeMultiplayer:(id)sender;

@property (nonatomic, weak) IBOutlet UIButton *playRealTimeMultiplayerButton;

@end
