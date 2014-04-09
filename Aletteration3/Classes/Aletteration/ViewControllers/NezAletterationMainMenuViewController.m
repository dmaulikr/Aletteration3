//
//  NezAletterationMainMenuViewController.m
//  Aletteration3
//
//  Created by David Nesbitt on 2013-09-29.
//  Copyright (c) 2013 David Nesbitt. All rights reserved.
//

#import "NezAletterationMainMenuViewController.h"
#import "NezAletterationBaseGameViewController.h"
#import "NezAletterationAppDelegate.h"
#import "NezAletterationGraphics.h"
#import "NezGLCamera.h"
#import "NezGCD.h"
#import "NezAletterationBox.h"
#import "NezAletterationGameTable.h"
#import "NezAletterationAnimationExitGame.h"

@interface NezAletterationMainMenuViewController () {
	UIViewController *_gameCenterLoginViewController;
	__weak NezGameCenter *_gameCenter;
}

@end

@implementation NezAletterationMainMenuViewController

-(void)viewDidLoad {
	[super viewDidLoad];
	
	_gameCenter = [NezGameCenter sharedInstance];
	NezAletterationGraphics *graphics = [NezAletterationAppDelegate sharedAppDelegate].graphics;
	
	NezGLCamera *camera = graphics.camera;
	camera.effectiveViewport = graphics.viewport;
	[camera lookAtGeometry:graphics.gameTable.lidProxyGeometry withZoomOptions:NezGLCameraZoomToWidth];
	
	NSNotificationCenter *nc = [NSNotificationCenter defaultCenter];
	[nc addObserver:self selector:@selector(receivedAuthenticationChangedNotification:) name:GKPlayerAuthenticationDidChangeNotificationName object:nil];
}

-(void)viewWillAppear:(BOOL)animated {
	[[NezAletterationAppDelegate sharedAppDelegate] updateAndDisplay];
	self.playRealTimeMultiplayerButton.enabled = _gameCenter.localPlayer.isAuthenticated;
}

-(void)viewDidAppear:(BOOL)animated {
	NSLog(@"NezAletterationMainMenuViewController viewDidAppear");
	[super viewDidAppear:animated];
	if (!_gameCenter.localPlayer.isAuthenticated) {
		[_gameCenter authenticateLocalUserWithHandler:^(UIViewController *viewController, NSError *error) {
			_gameCenterLoginViewController = viewController;
			self.playRealTimeMultiplayerButton.enabled = YES;
		}];
	}
}

-(IBAction)unwindToMainMenuViewController:(UIStoryboardSegue *)unwindSegue {
	NSLog(@"unwind to here!");
}

-(IBAction)playRealTimeMultiplayer:(id)sender {
	NSLog(@"%@", _gameCenterLoginViewController);
	if (_gameCenter.localPlayer.isAuthenticated) {
		[self performSegueWithIdentifier:@"PlayRealTimeMultiplayerSegue" sender:self];
	} else if (_gameCenterLoginViewController) {
		[self presentViewController:_gameCenterLoginViewController animated:YES completion:^{}];
	}
}

-(void)receivedAuthenticationChangedNotification:(NSNotification *)notification {
	if (_gameCenter.localPlayer.isAuthenticated) {
		[self setLocalPlayerPrefs];
	}
	if (_gameCenter.localPlayer.isAuthenticated && _gameCenterLoginViewController) {
		_gameCenterLoginViewController = nil;
		[self performSegueWithIdentifier:@"PlayRealTimeMultiplayerSegue" sender:self];
	}
}

-(void)setLocalPlayerPrefs {
	__weak NezAletterationAppDelegate *app = [NezAletterationAppDelegate sharedAppDelegate];

	app.localPlayerName = _gameCenter.localPlayer.displayName;
	app.localPlayerNickName = _gameCenter.localPlayer.alias;
	[_gameCenter loadPhotoForLocalPlayerWithCompletionHandler:^(UIImage *photo, NSError *error) {
		app.localPlayerPhoto = photo;
	}];
}

-(void)dealloc {
	NSLog(@"NezAletterationMainMenuViewController dealloc");
	[[NSNotificationCenter defaultCenter] removeObserver:self];
}

@end
