//
//  NezAletterationSinglePlayerViewController.m
//  Aletteration3
//
//  Created by David Nesbitt on 2013-09-25.
//  Copyright (c) 2013 David Nesbitt. All rights reserved.
//

#import <GLKit/GLKit.h>
#import "NezGLCamera.h"
#import "NezAletterationGraphics.h"
#import "NezAletterationAppDelegate.h"
#import "NezAletterationGLKViewController.h"
#import "NezAnimation.h"
#import "NezAnimator.h"
#import "NezCubicBezier3d.h"
#import "NezAletterationGameState.h"
#import "NezAletterationGameTable.h"
#import "NezAletterationGameBoard.h"
#import "NezAletterationAnimationNextGameBoard.h"
#import "NezAletterationBaseGameViewController.h"
#import "NezAletterationPlayerCollectionViewCell.h"
#import "NezAletterationPlayer.h"
#import "NezAletterationWordLine.h"
#import "NezRandom.h"
#import "NezAletterationAnimationSlide.h"
#import "NezAletterationPlayerPrefs.h"
#import "NezAletterationPlayerOptionsViewController.h"
#import "NezGameCenter.h"
#import "UIView+ExtraContraints.h"

#define NEZ_LOOK_AT_BORDER_WIDTH 3

typedef struct {
	NSInteger page1;
	NSInteger page2;
	float t;
} NezAletterationPageInfo;

@interface NezAletterationBaseGameViewController () {
	NSMutableArray *_boardAnimationList;
	
	NezAnimation *_lightAnimation;

	NSInteger _dragCounter;
}

@property (readonly, getter = getCurrentPageInfo) NezAletterationPageInfo currentPageInfo;
@property (readonly, getter = getCurrentPage) NSInteger currentPage;
@property (readonly, getter = getCurrentFractionalPage) CGFloat currentFractionalPage;
@property (readonly, getter = getCollectionViewContentWidth) CGFloat collectionViewContentWidth;

@end

@implementation NezAletterationBaseGameViewController

-(instancetype)initWithCoder:(NSCoder *)aDecoder {
	NSLog(@"NezAletterationBaseGameViewController initWithCoder");
	if ((self = [super initWithCoder:aDecoder])) {
		_app = [NezAletterationAppDelegate sharedAppDelegate];
		_graphics = _app.graphics;
		_camera = _graphics.camera;
		_table = _graphics.gameTable;
		
		NSNotificationCenter *nc = [NSNotificationCenter defaultCenter];
		[nc addObserver:self selector:@selector(receivedLocalPlayerPhotoChangedNotification:) name:NEZ_ALETTERATION_NOTIFICATION_LOCAL_PLAYER_PHOTO_CHANGED object:nil];
		[nc addObserver:self selector:@selector(receivedLocalPlayerNameChangedNotification:) name:NEZ_ALETTERATION_NOTIFICATION_LOCAL_PLAYER_NAME_CHANGED object:nil];
		[nc addObserver:self selector:@selector(receivedLocalPlayerNickNameChangedNotification:) name:NEZ_ALETTERATION_NOTIFICATION_LOCAL_PLAYER_NICK_NAME_CHANGED object:nil];
		[nc addObserver:self selector:@selector(receivedLocalPlayerColorChangedNotification:) name:NEZ_ALETTERATION_NOTIFICATION_LOCAL_PLAYER_COLOR_CHANGED object:nil];
		[nc addObserver:self selector:@selector(receivedLocalPlayerIsLowercaseChangedNotification:) name:NEZ_ALETTERATION_NOTIFICATION_LOCAL_PLAYER_IS_LOWERCASE_CHANGED object:nil];

	}
	return self;
}

-(void)receivedLocalPlayerPhotoChangedNotification:(NSNotification *)notification {
	self.localPlayer.prefsPhoto = _app.localPlayerPhoto;
	[self.collectionView reloadData];
	_optionsViewController.photoImageView.image = _app.localPlayerPhoto;
}

-(void)receivedLocalPlayerNameChangedNotification:(NSNotification *)notification {
	self.localPlayer.prefsName = _app.localPlayerName;
	[self.collectionView reloadData];
	_optionsViewController.nameLabel.text = _app.localPlayerName;
}

-(void)receivedLocalPlayerNickNameChangedNotification:(NSNotification *)notification {
	self.localPlayer.prefsNickName = _app.localPlayerNickName;
	[self.collectionView reloadData];
	_optionsViewController.nickNameLabel.text = _app.localPlayerNickName;
}

-(void)receivedLocalPlayerColorChangedNotification:(NSNotification *)notification {
	self.localPlayer.prefsColor = _app.localPlayerColor;
}

-(void)receivedLocalPlayerIsLowercaseChangedNotification:(NSNotification *)notification {
	self.localPlayer.prefsIsLowercase = _app.localPlayerIsLowercase;
}

-(void)encodeRestorableStateWithCoder:(NSCoder*)coder {
	[super encodeRestorableStateWithCoder:coder];
	[coder encodeBool:_menuOpen forKey:@"_menuOpen"];
	[coder encodeBool:_optionsOpen forKey:@"_optionsOpen"];
}

-(void)decodeRestorableStateWithCoder:(NSCoder*)coder {
	[super decodeRestorableStateWithCoder:coder];
	_menuOpen = [coder decodeBoolForKey:@"_menuOpen"];
	_optionsOpen = [coder decodeBoolForKey:@"_optionsOpen"];
}

-(void)viewWillAppear:(BOOL)animated {
	NSLog(@"NezAletterationBaseGameViewController viewWillAppear");
	[super viewWillAppear:animated];
	
	_optionsViewController = [self.storyboard instantiateViewControllerWithIdentifier:@"NezAletterationPlayerOptionsViewController"];
	_optionsViewController.photoImageView.image = _app.localPlayerPhoto;
	_optionsViewController.nameLabel.text = _app.localPlayerName;
	_optionsViewController.nickNameLabel.text = _app.localPlayerNickName;
}

-(void)viewDidAppear:(BOOL)animated {
	NSLog(@"NezAletterationBaseGameViewController viewDidAppear");
	[super viewDidAppear:animated];
	
	CGSize size = _app.currentSize;
	CGSize toolbarSize = self.topToolbar.bounds.size;
	CGSize playerInfoContainerSize = self.playerInfoContainer.bounds.size;
	
	_defaultEffectiveViewport.origin.x = NEZ_LOOK_AT_BORDER_WIDTH;
	_defaultEffectiveViewport.origin.y = NEZ_LOOK_AT_BORDER_WIDTH;
	_defaultEffectiveViewport.size.width = size.width-NEZ_LOOK_AT_BORDER_WIDTH-NEZ_LOOK_AT_BORDER_WIDTH;
	_defaultEffectiveViewport.size.height = size.height-NEZ_LOOK_AT_BORDER_WIDTH-NEZ_LOOK_AT_BORDER_WIDTH;
	
	_menusEffectiveViewport.origin.x = NEZ_LOOK_AT_BORDER_WIDTH;
	_menusEffectiveViewport.origin.y = toolbarSize.height+NEZ_LOOK_AT_BORDER_WIDTH;
	_menusEffectiveViewport.size.width = size.width-NEZ_LOOK_AT_BORDER_WIDTH-NEZ_LOOK_AT_BORDER_WIDTH;
	_menusEffectiveViewport.size.height = size.height-toolbarSize.height-NEZ_LOOK_AT_BORDER_WIDTH-NEZ_LOOK_AT_BORDER_WIDTH-playerInfoContainerSize.height;
	
	[_camera stopLookingAtGeometry];
	
	if (_menuOpen) {
		self.topToolbarTopConstraint.constant = 0;
		self.playerInfoContainerBottomConstraint.constant = 0;
		_camera.effectiveViewport = _menusEffectiveViewport;
	} else {
		self.topToolbarTopConstraint.constant = -toolbarSize.height;
		self.playerInfoContainerBottomConstraint.constant = -playerInfoContainerSize.height;
		_camera.effectiveViewport = _defaultEffectiveViewport;
	}
}

-(IBAction)showMenu:(id)sender {
	[self showMenuWithCompletionHandler:nil];
}

-(IBAction)hideMenu:(id)sender {
	[self hideMenuWithCompletionHandler:nil];
}

-(IBAction)showOptions:(id)sender {
	[self showOptionsView:YES];
}

-(void)showMenuWithCompletionHandler:(NezCompletionHandler)completionHandler {
	_menuOpen = YES;
	self.topToolbarTopConstraint.constant = 0;
	self.playerInfoContainerBottomConstraint.constant = 0;
	[self.view setNeedsUpdateConstraints];
	[UIView animateWithDuration:0.25 delay:0.0 options:UIViewAnimationOptionCurveEaseInOut animations:^{
		[self.view layoutIfNeeded];
	} completion:completionHandler];
}

-(void)hideMenuWithCompletionHandler:(NezCompletionHandler)completionHandler {
	_menuOpen = NO;
	CGSize toolbarSize = self.topToolbar.bounds.size;
	CGSize playerInfoContainerSize = self.playerInfoContainer.bounds.size;
	self.topToolbarTopConstraint.constant = -toolbarSize.height;
	self.playerInfoContainerBottomConstraint.constant = -playerInfoContainerSize.height;
	[self.view setNeedsUpdateConstraints];
	[UIView animateWithDuration:0.25 delay:0.0 options:UIViewAnimationOptionCurveEaseInOut animations:^{
		[self.view layoutIfNeeded];
	} completion:completionHandler];
}

-(void)showOptionsView:(BOOL)animated {}
-(void)hideOptionsView {}

-(void)applicationFinishedRestoringState {
	_camera = _graphics.camera;
	_table = _graphics.gameTable;
}

-(NezAletterationPlayer*)getLocalPlayer {
	return self.playerList[self.localPlayerIndex];
}

-(NezAletterationPlayer*)getCurrentPlayer {
	return _table.playerList[_playerIndex];
}

-(NSArray*)getPlayerList {
	return _table.playerList;
}

-(void)scrollToPlayerWithIndex:(NSInteger)index {
	[self.collectionView scrollToItemAtIndexPath:[NSIndexPath indexPathForItem:index inSection:0] atScrollPosition:UICollectionViewScrollPositionLeft animated:NO];
}

-(void)setupTable {
	if (_playerCount > 0) {
		_playerIndex = _localPlayerIndex;
		[_table setupTableForPlayerCount:_playerCount];
		_table.modelMatrix = GLKMatrix4Identity;
		_table.color = GLKVector4Make(1.0, 0.0, 0.0, 1.0);
		
		if (_playerCount > 1) {
			_boardAnimationList = [NSMutableArray arrayWithCapacity:_playerCount];
			for (int i=0; i<_playerCount-1; i++) {
				NezAletterationPlayer *player = _table.playerList[i];
				NezAletterationPlayer *nextPlayer = _table.playerList[i+1];
				[_boardAnimationList addObject:[[NezAletterationAnimationNextGameBoard alloc] initWithBoard:player.gameBoard nextBoard:nextPlayer.gameBoard]];
			}
			NezAletterationPlayer *firstPlayer = _table.playerList.firstObject;
			NezAletterationPlayer *lastPlayer = _table.playerList.lastObject;
			
			NezAletterationAnimationNextGameBoard *nextBoardAnimation = [[NezAletterationAnimationNextGameBoard alloc] initWithBoard:lastPlayer.gameBoard nextBoard:firstPlayer.gameBoard];
			[_boardAnimationList addObject:nextBoardAnimation];
			if (_playerCount == 2) {
				nextBoardAnimation.startOrientation = GLKQuaternionConjugate(nextBoardAnimation.startOrientation);
			}
		} else {
			_boardAnimationList = nil;
		}
		[self animateLight];
		
		self.localPlayer.prefsPhoto = _app.localPlayerPhoto;
		self.localPlayer.prefsName = _app.localPlayerName;
		self.localPlayer.prefsNickName = _app.localPlayerNickName;
		self.localPlayer.prefsColor = _app.localPlayerColor;

		[self.collectionView reloadData];
	}
}

-(void)animateLight {
	__weak NezGLCamera *light = _graphics.light;
	_lightAnimation = [[NezAnimation alloc] initFloatWithFromData:0.0 ToData:2*M_PI Duration:10.0 EasingFunction:easeLinear UpdateBlock:^(NezAnimation *ani) {
		float angle = *ani.newData;
		[light lookAtEye:GLKVector3Make(cosf(angle)*15.0, sinf(angle)*8.0, 12.0f) target:GLKVector3Make(0.0f, 0.0f, 0.0f) upVector:GLKVector3Make(0.0f, 0.0f, 1.0f)];
	} DidStopBlock:^(NezAnimation *ani) {}];
	_lightAnimation.loop = NEZ_ANI_LOOP_FORWARD;
	[NezAnimator addAnimation:_lightAnimation];
}

-(NezAletterationPageInfo)getCurrentPageInfo {
	NezAletterationPageInfo pageInfo;

	float fractionalPage = self.currentFractionalPage;
	double intPart;
	double t = modf(fractionalPage, &intPart);
	if (fractionalPage < 1 || fractionalPage > _playerCount) {
		if (fractionalPage >= (_playerCount+1.0f)) {
			t = 1.0;
		}
		pageInfo.page1 = (_playerCount-1);
	} else {
		pageInfo.page1 = ((int)fractionalPage)-1;
	}
	pageInfo.page2 = pageInfo.page1>=(_playerCount-1)?0:pageInfo.page1+1;
	pageInfo.t = t;
	
	return pageInfo;
}

-(void)scrollViewDidScroll:(UIScrollView *)scrollView {
	if (scrollView == self.collectionView) {
		if (_playerCount > 1) {
			NezAletterationPageInfo pageInfo = self.currentPageInfo;
			if (pageInfo.page1 > -1) {
	//			NSInteger page2 = page1>=(_playerCount-1)?0:page1+1;
	//			NezAletterationPlayer *p1 = _playerList[page1];
	//			NezAletterationPlayer *p2 = _playerList[page2];
	//			GLKVector4 color1 = p1.gameBoard.color;
	//			GLKVector4 color2 = p2.gameBoard.color;
	//			GLKVector4 color = GLKVector4Lerp(color1, color2, t);
	//			self.pauseMenuContainerView.backgroundColor = [UIColor colorWithRed:color.r green:color.g blue:color.b alpha:self.menuAlpha];
	
	//			GLKVector3 black = {0.0f, 0.0f, 0.0f};
	//			GLKVector3 white = {1.0f, 1.0f, 1.0f};
	//			GLKVector3 tintColor1 = [NezAletterationGraphics getLuma:color1]>0.5?black:white;
	//			GLKVector3 tintColor2 = [NezAletterationGraphics getLuma:color2]>0.5?black:white;
	//			GLKVector3 tintColor = GLKVector3Lerp(tintColor1, tintColor2, t);
	//			self.pauseMenuToolbar.tintColor = [UIColor colorWithRed:tintColor.r green:tintColor.g blue:tintColor.b alpha:self.menuAlpha];
				if (_boardAnimationList) {
					NezAletterationAnimationNextGameBoard *boardAni = _boardAnimationList[pageInfo.page1];
					[boardAni lookAtPathLocation:pageInfo.t withCamera:_graphics.camera];
				}
			}
		}
	}
}

-(void)scrollViewDidEndDragging:(UIScrollView *)scrollView willDecelerate:(BOOL)decelerate {
	if (!decelerate) {
		if (scrollView == self.collectionView) {
			_dragCounter--;
			[self setPage];
		}
	}
}

-(void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView {
	if (scrollView == self.collectionView) {
		_dragCounter--;
		[self setPage];
	}
}

-(void)scrollViewWillBeginDragging:(UIScrollView *)scrollView {
	if (scrollView == self.collectionView) {
		_dragCounter++;
		[self setPage];
	}
}
-(void)setPage {
	if (_playerCount > 1) {
		if (self.currentPage == 0) {
			[self.collectionView setContentOffset:CGPointMake(self.collectionViewContentWidth+self.collectionView.contentOffset.x,0)];
		} else if (self.currentFractionalPage > (_playerCount+0.5f)) {
			float offset = self.collectionView.contentOffset.x-(self.collectionViewContentWidth);
			[self.collectionView setContentOffset:CGPointMake(offset,0)];
		}
		_playerIndex = self.currentPage-1;
	}
}

-(NSInteger)getCurrentPage {
	return (NSInteger)[self getCurrentFractionalPage];
}

-(CGFloat)getCurrentFractionalPage {
	CGFloat pageWidth = self.collectionView.bounds.size.width;
	return (self.collectionView.contentOffset.x / pageWidth);
}

-(NSInteger)playerIndexForIndexPath:(NSIndexPath *)indexPath {
	NSInteger playerIndex;
	if (_playerCount > 1) {
		if (indexPath.row == 0) {
			playerIndex = _playerCount-1;
		} else if (indexPath.row == _playerCount+1) {
			playerIndex = 0;
		} else {
			playerIndex = indexPath.row-1;
		}
	} else {
		playerIndex = 0;
	}
	return playerIndex;
}

-(CGFloat)getCollectionViewContentWidth {
	return self.collectionView.bounds.size.width*_playerCount;
}

-(void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
	if ([segue.identifier isEqualToString:@"PlayerCollectionContainerViewSegue"]) {
		UICollectionViewController *collectionViewController = segue.destinationViewController;
		self.collectionView = collectionViewController.collectionView;
		self.collectionView.dataSource = self;
		self.collectionView.delegate = self;
	}
}

-(NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView {
	return 1;
}

-(NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
	if (_playerCount > 1) {
		return _playerCount+2;
	} else {
		return _playerCount;
	}
}

-(UICollectionViewCell*)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
	NezAletterationPlayerCollectionViewCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:@"NezAletterationPlayerInfoCollectionViewCell" forIndexPath:indexPath];
	[cell.playerPhotoImageView addConstraintWidthEqualsHeight];
	
	NSInteger playerIndex = [self playerIndexForIndexPath:indexPath];
	NezAletterationPlayer *player = self.playerList[playerIndex];
	cell.playerPhotoImageView.image = player.prefsPhoto;
	cell.playerNameLabel.text = player.prefsNickName;
	
	return cell;
}

-(CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath {
	return self.collectionView.bounds.size;
}

-(void)dealloc {
	NSLog(@"NezAletterationBaseGameViewController dealloc");
	if (_lightAnimation) {
		[NezAnimator removeAnimation:_lightAnimation];
		_lightAnimation = nil;
	}
	[[NSNotificationCenter defaultCenter] removeObserver:self];
}

@end
