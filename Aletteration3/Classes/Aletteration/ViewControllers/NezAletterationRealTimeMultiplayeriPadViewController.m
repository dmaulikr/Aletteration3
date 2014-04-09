//
//  NezAletterationRealTimeMultiplayeriPadViewController.m
//  Aletteration3
//
//  Created by David Nesbitt on 2013/11/18.
//  Copyright (c) 2013 David Nesbitt. All rights reserved.
//

#import "NezAletterationRealTimeMultiplayeriPadViewController.h"
#import "NezAletterationPlayerOptionsViewController.h"

@interface NezAletterationRealTimeMultiplayeriPadViewController () {
	UIPopoverController *_optionsPopoverController;
}

@end

@implementation NezAletterationRealTimeMultiplayeriPadViewController

-(void)setupOptionsView {
}

-(void)showOptionsView:(BOOL)animated {
	if (!_optionsPopoverController) {
		self.optionsOpen = YES;
		[self.optionsViewController initializeControls];
		_optionsPopoverController = [[UIPopoverController alloc] initWithContentViewController:self.optionsViewController];
		_optionsPopoverController.delegate = self;
		[_optionsPopoverController presentPopoverFromBarButtonItem:self.showOptionsButton permittedArrowDirections:UIPopoverArrowDirectionAny animated:YES];
	} else {
		[self hideOptionsView];
	}
}

-(void)hideMenuWithCompletionHandler:(NezCompletionHandler)completionHandler {
	if (self.optionsOpen) {
		[self hideOptionsView];
	}
	[super hideMenuWithCompletionHandler:completionHandler];
}

-(void)hideOptionsView {
	if (_optionsPopoverController && self.optionsOpen) {
		[_optionsPopoverController dismissPopoverAnimated:YES];
		[self popoverControllerDidDismissPopover:_optionsPopoverController];
	}
}

-(void)popoverControllerDidDismissPopover:(UIPopoverController *)popoverController {
	_optionsPopoverController.delegate = nil;
	_optionsPopoverController = nil;
	self.optionsOpen = NO;
}

@end
