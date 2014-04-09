//
//  NezAletterationPlayerOptionsViewController.h
//  Aletteration3
//
//  Created by David Nesbitt on 2013/11/11.
//  Copyright (c) 2013 David Nesbitt. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "NezGCD.h"

@interface NezAletterationPlayerOptionsViewController : UIViewController

@property (nonatomic, weak) IBOutlet UIImageView *photoImageView;
@property (nonatomic, weak) IBOutlet UILabel *nameLabel;
@property (nonatomic, weak) IBOutlet UILabel *nickNameLabel;

@property (nonatomic, weak) IBOutlet UISwitch *undoConfirmation;

@property (nonatomic, weak) IBOutlet UISwitch *soundsSwitch;
@property (nonatomic, weak) IBOutlet UISlider *soundsVolumeSlider;
@property (nonatomic, weak) IBOutlet UIImageView *soundsVolumeImageView;
@property (nonatomic, weak) IBOutlet UISwitch *musicSwitch;
@property (nonatomic, weak) IBOutlet UISlider *musicVolumeSlider;
@property (nonatomic, weak) IBOutlet UIImageView *musicVolumeImageView;

@property (nonatomic, weak) IBOutlet UIView *blockColorView;
@property (nonatomic, weak) IBOutlet UIButton *blockLetterButton;
@property (nonatomic, weak) IBOutlet UISlider *redSlider;
@property (nonatomic, weak) IBOutlet UISlider *greenSlider;
@property (nonatomic, weak) IBOutlet UISlider *blueSlider;

-(IBAction)slideColor:(id)sender;

-(void)initializeControls;
-(void)setColorFromSliderValues;

-(IBAction)toggleUndoConfirmationSwitch:(id)sender;

-(IBAction)toggleSoundsSwitch:(id)sender;
-(IBAction)slideSoundsVolume:(id)sender;
-(IBAction)toggleMusicSwitch:(id)sender;
-(IBAction)slideMusicVolume:(id)sender;
-(IBAction)changeCase:(id)sender;

@end
