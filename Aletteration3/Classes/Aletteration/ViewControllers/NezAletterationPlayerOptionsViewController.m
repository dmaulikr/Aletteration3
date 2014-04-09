//
//  NezAletterationPlayerOptionsViewController.m
//  Aletteration3
//
//  Created by David Nesbitt on 2013/11/11.
//  Copyright (c) 2013 David Nesbitt. All rights reserved.
//

#import "NezAletterationPlayerOptionsViewController.h"
#import "NezAletterationAppDelegate.h"
#import "NezAletterationPlayerPrefs.h"
#import "NezAletterationGraphics.h"
#import "UIView+ExtraContraints.h"

@interface NezAletterationPlayerOptionsViewController () {
	NezAletterationAppDelegate *_app;
}

@property (readonly, getter = getBlockColor) GLKVector4 blockColor;

@end

@implementation NezAletterationPlayerOptionsViewController

-(instancetype)initWithCoder:(NSCoder *)aDecoder {
	if ((self = [super initWithCoder:aDecoder])) {
		_app = [NezAletterationAppDelegate sharedAppDelegate];
	}
	return self;
}

-(void)viewDidLoad {
	[self.photoImageView addConstraintWidthEqualsHeight];
	[self.blockColorView addConstraintWidthEqualsHeight];
	[self initializeControls];
}

-(void)initializeControls {
	GLKVector4 color = _app.localPlayerColor;
	self.redSlider.value = color.r;
	self.greenSlider.value = color.g;
	self.blueSlider.value = color.b;
	[self setBlockColor:color];

	self.undoConfirmation.on = _app.localPlayerUndoConfirmation;

	self.soundsSwitch.on = _app.localPlayerSoundsEnabled;
	self.soundsVolumeSlider.value = _app.localPlayerSoundsVolume;
	[self setVolumeImageWithSwitch:self.soundsSwitch Slider:self.soundsVolumeSlider andImageView:self.soundsVolumeImageView];
	[self setVolumeImageWithSlider:self.soundsVolumeSlider andImageView:self.soundsVolumeImageView];
	
	self.musicSwitch.on = _app.localPlayerMusicEnabled;
	self.musicVolumeSlider.value = _app.localPlayerMusicVolume;
	[self setVolumeImageWithSwitch:self.musicSwitch Slider:self.musicVolumeSlider andImageView:self.musicVolumeImageView];
	[self setVolumeImageWithSlider:self.musicVolumeSlider andImageView:self.musicVolumeImageView];

	self.photoImageView.image = _app.localPlayerPhoto;
	self.nameLabel.text = _app.localPlayerName;
	self.nickNameLabel.text = _app.localPlayerNickName;
}

-(GLKVector4)getBlockColor {
	return GLKVector4Make(self.redSlider.value, self.greenSlider.value, self.blueSlider.value, 1.0);
}

-(void)setVolumeImageWithSwitch:(UISwitch*)volumeSwitch Slider:(UISlider*)volumeSlider andImageView:(UIImageView*)volumeImageView {
	volumeSlider.enabled = volumeSwitch.on;
	volumeImageView.alpha = volumeSwitch.on?1.0:0.25;
}

-(void)setVolumeImageWithSlider:(UISlider*)volumeSlider andImageView:(UIImageView*)volumeImageView {
	float volume = volumeSlider.value;
	if (volume == 0.0) {
		volumeImageView.image = [UIImage imageNamed:@"vol0.png"];
	} else if (volume < 0.33) {
		volumeImageView.image = [UIImage imageNamed:@"vol1.png"];
	} else if (volume < 0.66) {
		volumeImageView.image = [UIImage imageNamed:@"vol2.png"];
	} else {
		volumeImageView.image = [UIImage imageNamed:@"vol3.png"];
	}
}

-(void)setBlockColor:(GLKVector4)color {
	float luma = [NezAletterationGraphics getLuma:color];
	UIImage *image = luma>0.5?[UIImage imageNamed:@"a-black.png"]:[UIImage imageNamed:@"a-white.png"];
	[self.blockLetterButton setImage:image forState:UIControlStateNormal];
	[self.blockLetterButton setImage:image forState:UIControlStateHighlighted];
	self.blockColorView.backgroundColor = [UIColor colorWithRed:color.r green:color.g blue:color.b alpha:color.a];
	[self setBlockCaseWithBlockColor:color];
}

-(void)setBlockCase {
	_app.localPlayerIsLowercase = !_app.localPlayerIsLowercase;
	[self setBlockCaseWithBlockColor:self.blockColor];
}

-(void)setBlockCaseWithBlockColor:(GLKVector4)blockColor {
	NSString *caseString = [NSString stringWithFormat:@"%@", (_app.localPlayerIsLowercase?@"lowercase":@"uppercase")];
	float luma = [NezAletterationGraphics getLuma:blockColor];
	UIImage *image = [UIImage imageNamed:[NSString stringWithFormat:@"a-%@-%@.png", (luma>0.5?@"black":@"white"), caseString]];
	[self.blockLetterButton setImage:image forState:UIControlStateNormal];
	[self.blockLetterButton setImage:image forState:UIControlStateHighlighted];
}

-(void)setColorFromSliderValues {
	GLKVector4 color = self.blockColor;
	[self setBlockColor:color];
	_app.localPlayerColor = color;
}

-(IBAction)slideColor:(id)sender {
	[self setColorFromSliderValues];
}

-(IBAction)toggleUndoConfirmationSwitch:(id)sender {
	_app.localPlayerUndoConfirmation = self.undoConfirmation.on;
}

-(IBAction)toggleSoundsSwitch:(id)sender {
	[self setVolumeImageWithSwitch:self.soundsSwitch Slider:self.soundsVolumeSlider andImageView:self.soundsVolumeImageView];
	_app.localPlayerSoundsEnabled = self.soundsSwitch.on;
}

-(IBAction)slideSoundsVolume:(id)sender {
	[self setVolumeImageWithSlider:self.soundsVolumeSlider andImageView:self.soundsVolumeImageView];
	_app.localPlayerSoundsVolume = self.soundsVolumeSlider.value;
}

-(IBAction)toggleMusicSwitch:(id)sender {
	[self setVolumeImageWithSwitch:self.musicSwitch Slider:self.musicVolumeSlider andImageView:self.musicVolumeImageView];
	_app.localPlayerMusicEnabled = self.musicSwitch.on;
}

-(IBAction)slideMusicVolume:(id)sender {
	[self setVolumeImageWithSlider:self.musicVolumeSlider andImageView:self.musicVolumeImageView];
	_app.localPlayerMusicVolume = self.musicVolumeSlider.value;
}

-(IBAction)changeCase:(id)sender {
	[self setBlockCase];
}

-(void)dealloc {
	NSLog(@"NezAletterationPlayerOptionsViewController dealloc");
}

@end
