//
//  NezAppDelegate.h
//  Aletteration7
//
//  Created by David Nesbitt on 2013-08-28.
//  Copyright (c) 2013 Nezsoft. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <GLKit/GLKit.h>

#define NEZ_ALETTERATION_NOTIFICATION_LOCAL_PLAYER_PHOTO_CHANGED @"NEZ_ALETTERATION_NOTIFICATION_LOCAL_PLAYER_PHOTO_CHANGED"
#define NEZ_ALETTERATION_NOTIFICATION_LOCAL_PLAYER_NAME_CHANGED @"NEZ_ALETTERATION_NOTIFICATION_LOCAL_PLAYER_NAME_CHANGED"
#define NEZ_ALETTERATION_NOTIFICATION_LOCAL_PLAYER_NICK_NAME_CHANGED @"NEZ_ALETTERATION_NOTIFICATION_LOCAL_PLAYER_NICK_NAME_CHANGED"
#define NEZ_ALETTERATION_NOTIFICATION_LOCAL_PLAYER_COLOR_CHANGED @"NEZ_ALETTERATION_NOTIFICATION_LOCAL_PLAYER_COLOR_CHANGED"

#define NEZ_ALETTERATION_NOTIFICATION_LOCAL_PLAYER_UNDO_CONFIRMATION_CHANGED @"NEZ_ALETTERATION_NOTIFICATION_LOCAL_PLAYER_UNDO_CONFIRMATION_CHANGED"
#define NEZ_ALETTERATION_NOTIFICATION_LOCAL_PLAYER_UNDO_COUNT_CHANGED @"NEZ_ALETTERATION_NOTIFICATION_LOCAL_PLAYER_UNDO_COUNT_CHANGED"

#define NEZ_ALETTERATION_NOTIFICATION_LOCAL_PLAYER_SOUNDS_ENABLED_CHANGED @"NEZ_ALETTERATION_NOTIFICATION_LOCAL_PLAYER_SOUNDS_ENABLED_CHANGED"
#define NEZ_ALETTERATION_NOTIFICATION_LOCAL_PLAYER_SOUNDS_VOLUME_CHANGED @"NEZ_ALETTERATION_NOTIFICATION_LOCAL_PLAYER_SOUNDS_VOLUME_CHANGED"
#define NEZ_ALETTERATION_NOTIFICATION_LOCAL_PLAYER_MUSIC_ENABLED_CHANGED @"NEZ_ALETTERATION_NOTIFICATION_LOCAL_PLAYER_MUSIC_ENABLED_CHANGED"
#define NEZ_ALETTERATION_NOTIFICATION_LOCAL_PLAYER_MUSIC_VOLUME_CHANGED @"NEZ_ALETTERATION_NOTIFICATION_LOCAL_PLAYER_MUSIC_VOLUME_CHANGED"

#define NEZ_ALETTERATION_NOTIFICATION_LOCAL_PLAYER_IS_LOWERCASE_CHANGED @"NEZ_ALETTERATION_NOTIFICATION_LOCAL_PLAYER_IS_LOWERCASE_CHANGED"

@class NezAletterationGLKViewController;
@class NezAletterationGraphics;
@class NezGLCamera;
@class NezAletterationPlayerPrefs;

@interface NezAletterationAppDelegate : UIResponder <UIApplicationDelegate,UIObjectRestoration>

@property (strong, nonatomic) UIWindow *window;
@property (nonatomic, readonly) NezAletterationGraphics *graphics;
@property (nonatomic, readonly) NezAletterationGLKViewController *rootGLKViewController;
@property (nonatomic, readonly, getter = getRootGLKView) GLKView *rootGLKView;

@property (nonatomic, getter = getLocalPlayerPhoto, setter = setLocalPlayerPhoto:) UIImage *localPlayerPhoto;
@property (nonatomic, getter = getLocalPlayerName, setter = setLocalPlayerName:) NSString *localPlayerName;
@property (nonatomic, getter = getLocalPlayerNickName, setter = setLocalPlayerNickName:) NSString *localPlayerNickName;
@property (nonatomic, getter = getLocalPlayerColor, setter = setLocalPlayerColor:) GLKVector4 localPlayerColor;

@property (nonatomic, getter = getLocalPlayerUndoConfirmation, setter = setLocalPlayerUndoConfirmation:) BOOL localPlayerUndoConfirmation;
@property (nonatomic, getter = getLocalPlayerUndoCount, setter = setLocalPlayerUndoCount:) NSInteger localPlayerUndoCount;

@property (nonatomic, getter = getLocalPlayerSoundsEnabled, setter = setLocalPlayerSoundsEnabled:) BOOL localPlayerSoundsEnabled;
@property (nonatomic, getter = getLocalPlayerSoundsVolume, setter = setLocalPlayerSoundsVolume:) float localPlayerSoundsVolume;
@property (nonatomic, getter = getLocalPlayerMusicEnabled, setter = setLocalPlayerMusicEnabled:) BOOL localPlayerMusicEnabled;
@property (nonatomic, getter = getLocalPlayerMusicVolume, setter = setLocalPlayerMusicVolume:) float localPlayerMusicVolume;

@property (nonatomic, getter = getLocalPlayerIsLowercase, setter = setLocalPlayerIsLowercase:) BOOL localPlayerIsLowercase;

@property (readonly, getter = getCurrentSize) CGSize currentSize;
@property (readonly, getter = getCurrentFrame) CGRect currentFrame;
@property (readonly, getter = getScaleFactor) float scaleFactor;

+(NezAletterationAppDelegate*)sharedAppDelegate;

-(void)updateAndDisplay;
-(void)saveLocalPlayerPrefs;

@end
