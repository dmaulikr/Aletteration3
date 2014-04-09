//
//  NezAletterationSinglePlayerViewController.h
//  Aletteration3
//
//  Created by David Nesbitt on 2013-09-25.
//  Copyright (c) 2013 David Nesbitt. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "NezGCD.h"

#define NEZ_ALETTERATION_DEFAULT_CAMERA_Z 9.0

@class NezGLCamera;
@class NezAletterationGraphics;
@class NezAletterationAppDelegate;
@class NezAletterationPlayer;
@class NezAletterationGameTable;
@class NezAletterationPlayerOptionsViewController;

@interface NezAletterationBaseGameViewController : UIViewController <UICollectionViewDelegate, UICollectionViewDataSource, UIScrollViewDelegate> {
	__weak NezGLCamera *_camera;
	__weak NezAletterationGraphics *_graphics;
	__weak NezAletterationAppDelegate *_app;
	__weak NezAletterationGameTable *_table;
	
	NSInteger _playerIndex;
}

@property (nonatomic, weak) IBOutlet UIButton *showMenuButton;
@property (nonatomic, weak) IBOutlet UIView *playerInfoContainer;
@property (nonatomic, weak) IBOutlet NSLayoutConstraint *playerInfoContainerBottomConstraint;
@property (nonatomic, weak) IBOutlet UIToolbar *topToolbar;
@property (nonatomic, weak) IBOutlet NSLayoutConstraint *topToolbarTopConstraint;
@property (nonatomic, weak) UICollectionView *collectionView;
@property (nonatomic, weak) IBOutlet UIBarButtonItem *showOptionsButton;
@property (nonatomic, strong) NezAletterationPlayerOptionsViewController *optionsViewController;
@property (nonatomic, assign) BOOL optionsOpen;

@property (nonatomic, assign) BOOL menuOpen;
@property (nonatomic, readonly) CGRect defaultEffectiveViewport;
@property (nonatomic, readonly) CGRect menusEffectiveViewport;

@property NSInteger localPlayerIndex;
@property NSInteger playerCount;
@property (readonly, getter = getLocalPlayer) NezAletterationPlayer *localPlayer;
@property (readonly, getter = getCurrentPlayer) NezAletterationPlayer *currentPlayer;
@property (readonly, getter = getPlayerList) NSArray *playerList;

-(void)receivedLocalPlayerPhotoChangedNotification:(NSNotification *)notification;
-(void)receivedLocalPlayerNameChangedNotification:(NSNotification *)notification;
-(void)receivedLocalPlayerNickNameChangedNotification:(NSNotification *)notification;
-(void)receivedLocalPlayerColorChangedNotification:(NSNotification *)notification;

-(IBAction)showMenu:(id)sender;
-(IBAction)hideMenu:(id)sender;
-(IBAction)showOptions:(id)sender;

-(void)showMenuWithCompletionHandler:(NezCompletionHandler)completionHandler;
-(void)hideMenuWithCompletionHandler:(NezCompletionHandler)completionHandler;

-(void)showOptionsView:(BOOL)animated;
-(void)hideOptionsView;

-(void)applicationFinishedRestoringState;
-(void)scrollToPlayerWithIndex:(NSInteger)index;
-(void)setupTable;

@end
