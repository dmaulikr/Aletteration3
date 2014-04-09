//
//  NezAppDelegate.m
//  Aletteration7
//
//  Created by David Nesbitt on 2013-08-28.
//  Copyright (c) 2013 Nezsoft. All rights reserved.
//

#import "NezAletterationAppDelegate.h"
#import "NezAletterationGraphics.h"
#import "NezAletterationGLKViewController.h"
#import "NezGLCamera.h"

#import "NezVertexArrayObject.h"
#import "NezInstanceVertexArrayObject.h"
#import "NezInstanceVertexArrayObjectLitColor.h"
#import "NezInstanceVertexArrayObjectLitColor.h"
#import "NezInstanceVertexArrayObjectColor.h"
#import "NezInstanceVertexArrayObjectColorTexture.h"
#import "NezInstanceVertexArrayObjectTexture.h"
#import "NezInstanceVertexArrayObjectLitTextureColor.h"
#import "NezInstanceVertexArrayObjectLitColorTexture.h"

#import "NezAletterationGameTable.h"
#import "NezAletterationGameBoard.h"
#import "NezAletterationLetterBlock.h"
#import "NezAletterationBox.h"
#import "NezAletterationLetterBox.h"
#import "NezAletterationWordLine.h"
#import "NezAletterationLetterStack.h"
#import "NezAletterationLetterStackLabel.h"
#import "NezAletterationRetiredWordBoard.h"

#import "NezAletterationPlayer.h"
#import "NezAletterationPlayerPrefs.h"

#define NEZ_ALETTERATION_LOCAL_PLAYER_PREFS @"NALPP"

typedef id<NezRestorable> (^ NezRestorableBlock)(id<NezRestorable> restorationParent);

@interface NezAletterationAppDelegate() {
	CADisplayLink *_displayLinkForUITrackingRunLoopMode;
	NezAletterationPlayerPrefs *_localPlayerPrefs;
	NSNotificationCenter *_defaultCenter;
}

@property (nonatomic, readonly) NSMutableDictionary *restorationObjectsDictionary;
@property (nonatomic, readonly) NSDictionary *restorationIdentifierToClassDictionary;

@end

@implementation NezAletterationAppDelegate

-(NezRestorableBlock)graphicsObjectBlock {
	NezRestorableBlock block = ^(id<NezRestorable> restorationParent) {
		return [NezAletterationAppDelegate sharedAppDelegate].graphics;
	};
	return [block copy];
}

-(NezRestorableBlock)restorableObjectBlockWithClass:(Class)class {
	NezRestorableBlock block = ^(id<NezRestorable> restorationParent) {
		return [[class alloc] init];
	};
	return [block copy];
}

-(NezRestorableBlock)restorableVboBlock {
	NezRestorableBlock block = ^(id<NezRestorable> restorationParent) {
		NezVertexArrayObject *parentVAO = (NezVertexArrayObject*)restorationParent;
		return [[parentVAO.vertexBufferObjectClass alloc] init];
	};
	return [block copy];
}

-(NezRestorableBlock)restorableIaboBlock {
	NezRestorableBlock block = ^(id<NezRestorable> restorationParent) {
		NezInstanceVertexArrayObject *parentVAO = (NezInstanceVertexArrayObject*)restorationParent;
		return [[parentVAO.instanceAttributeBufferObjectClass alloc] init];
	};
	return [block copy];
}

-(void)createRestorationIdentifierToClassDictionary {
	_restorationIdentifierToClassDictionary = @{
		@"_graphics":                         [self graphicsObjectBlock],
		@"_camera":                           [self restorableObjectBlockWithClass:[NezGLCamera class]],
		@"_light":                            [self restorableObjectBlockWithClass:[NezGLCamera class]],
		@"_gameTableVertexArrayObject":       [self restorableObjectBlockWithClass:[NezInstanceVertexArrayObjectLitColor class]],
		@"_wordLineVertexArrayObject":        [self restorableObjectBlockWithClass:[NezInstanceVertexArrayObjectColor class]],
		@"_labelVertexArrayObject":           [self restorableObjectBlockWithClass:[NezInstanceVertexArrayObjectColorTexture class]],
		@"_bigBoxLidVertexArrayObject":       [self restorableObjectBlockWithClass:[NezInstanceVertexArrayObjectLitTextureColor class]],
		@"_bigBoxVertexArrayObject":          [self restorableObjectBlockWithClass:[NezInstanceVertexArrayObjectLitColor class]],
		@"_smallBoxLidVertexArrayObject":     [self restorableObjectBlockWithClass:[NezInstanceVertexArrayObjectLitTextureColor class]],
		@"_smallBoxVertexArrayObject":        [self restorableObjectBlockWithClass:[NezInstanceVertexArrayObjectLitTextureColor class]],
		@"_letterBlockFrontVertexArrayObject":[self restorableObjectBlockWithClass:[NezInstanceVertexArrayObjectLitColorTexture class]],
		@"_letterBlockBackVertexArrayObject": [self restorableObjectBlockWithClass:[NezInstanceVertexArrayObjectLitColor class]],
		@"_vertexBufferObject":               [self restorableVboBlock],
		@"_instanceAttributeBufferObject":    [self restorableIaboBlock],
		@"_gameTable":                        [self restorableObjectBlockWithClass:[NezAletterationGameTable class]],
		@"_box":                              [self restorableObjectBlockWithClass:[NezAletterationBox class]],
		@"_lid":                              [self restorableObjectBlockWithClass:[NezAletterationLid class]],
		@"_lidProxyGeometry":                 [self restorableObjectBlockWithClass:[NezAletterationRestorableGeometry class]],
		@"_letterGroup":                      [self restorableObjectBlockWithClass:[NezAletterationLetterGroup class]],
		@"_gameBoard":                        [self restorableObjectBlockWithClass:[NezAletterationGameBoard class]],
		@"_player":                           [self restorableObjectBlockWithClass:[NezAletterationPlayer class]],
		@"_prefs":                            [self restorableObjectBlockWithClass:[NezAletterationPlayerPrefs class]],
		@"_letterBlock":                      [self restorableObjectBlockWithClass:[NezAletterationLetterBlock class]],
		@"_wordLine":                         [self restorableObjectBlockWithClass:[NezAletterationWordLine class]],
		@"_letterStack":                      [self restorableObjectBlockWithClass:[NezAletterationLetterStack class]],
		@"_stackLabel":                       [self restorableObjectBlockWithClass:[NezAletterationLetterStackLabel class]],
		@"_letterBox":                        [self restorableObjectBlockWithClass:[NezAletterationLetterBox class]],
		@"_mainBoardGeometry":                [self restorableObjectBlockWithClass:[NezAletterationRestorableGeometry class]],
		@"_junkBoardGeometry":                [self restorableObjectBlockWithClass:[NezAletterationRestorableGeometry class]],
	};
}

+(NSObject<UIStateRestoring>*)objectWithRestorationIdentifierPath:(NSArray*)identifierComponents coder:(NSCoder*)coder {
//	NSLog(@"%@ objectWithRestorationIdentifierPath:%@", NSStringFromClass([self class]), identifierComponents);
	NezAletterationAppDelegate *app = [NezAletterationAppDelegate sharedAppDelegate];
	NezAletterationGraphics *graphics = [NezAletterationAppDelegate sharedAppDelegate].graphics;
	NSDictionary *restorationIdentifierToClassDictionary = [NezAletterationAppDelegate sharedAppDelegate].restorationIdentifierToClassDictionary;
	id<NezRestorable> object = nil;
	id<NezRestorable> restorationParent = [app findParentRestorableObjectWithRestorationIdentifierPath:identifierComponents];
	
	NSString *identifier = identifierComponents.lastObject;
	
	if ([identifier hasSuffix:@"]"]) {
		NSRange range = [identifier rangeOfString:@"List[" options:NSBackwardsSearch];
		if (range.location != NSNotFound) {
			identifier = [identifier substringToIndex:range.location];
		}
	}

	NezRestorableBlock restoreObjectBlock = restorationIdentifierToClassDictionary[identifier];
	if (restoreObjectBlock) {
		object = restoreObjectBlock(restorationParent);
	}
	if (object) {
		[app addRestorableObject:object withRestorationIdentifierPath:identifierComponents];
		if (object != graphics) {
			object.restorationParent = restorationParent;
			object.objectRestorationClass = [self class];
			[UIApplication registerObjectForStateRestoration:object restorationIdentifier:identifierComponents.lastObject];
		}
	}
	return object;
}

-(void)addRestorableObject:(id<NezRestorable>)object withRestorationIdentifierPath:(NSArray*)identifierComponents {
	NSString *path = [NSString pathWithComponents:identifierComponents];
	[self.restorationObjectsDictionary setObject:object forKey:path];
}

-(id<NezRestorable>)findParentRestorableObjectWithRestorationIdentifierPath:(NSArray*)identifierComponents {
	if (identifierComponents.count > 1) {
		NSString *path = [NSString pathWithComponents:[identifierComponents subarrayWithRange:NSMakeRange(0, identifierComponents.count-1)]];
		return self.restorationObjectsDictionary[path];
	}
	return nil;
}

+(NezAletterationAppDelegate*)sharedAppDelegate {
    return (NezAletterationAppDelegate*)[[UIApplication sharedApplication] delegate];
}

-(BOOL)application:(UIApplication*)application shouldSaveApplicationState:(NSCoder *)coder {
	return YES;
}

-(BOOL)application:(UIApplication*)application shouldRestoreApplicationState:(NSCoder *)coder {
	return NO;
}

-(BOOL)application:(UIApplication *)application willFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
	NSLog(@"NezAletterationAppDelegate willFinishLaunchingWithOptions");
	_defaultCenter = [NSNotificationCenter defaultCenter];

	_graphics = [[NezAletterationGraphics alloc] init];
	_graphics.objectRestorationClass = [self class];
	[UIApplication registerObjectForStateRestoration:_graphics restorationIdentifier:@"_graphics"];
	
	[self loadLocalPlayerPrefs];
	NSLog(@"_localPlayerPrefs:%@", _localPlayerPrefs);
	
	_displayLinkForUITrackingRunLoopMode = [CADisplayLink displayLinkWithTarget:self selector:@selector(updateAndDisplay)];
	_displayLinkForUITrackingRunLoopMode.frameInterval = 2;
	[_displayLinkForUITrackingRunLoopMode addToRunLoop:[NSRunLoop mainRunLoop] forMode:UITrackingRunLoopMode];

	_restorationObjectsDictionary = [NSMutableDictionary dictionary];
	[self createRestorationIdentifierToClassDictionary];

   _rootGLKViewController = [self.window.rootViewController.storyboard instantiateViewControllerWithIdentifier:@"NezAletterationGLKViewController"];
	_rootGLKViewController.view.frame = self.currentFrame;
	[self.window.rootViewController.view insertSubview:_rootGLKViewController.view atIndex:0];
	
	return YES;
}

-(BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
	NSLog(@"NezAletterationAppDelegate didFinishLaunchingWithOptions");
	[_restorationObjectsDictionary removeAllObjects];
	_restorationObjectsDictionary = nil;
	_restorationIdentifierToClassDictionary = nil;

	[self updateAndDisplay];
	
	return YES;
}

-(void)saveLocalPlayerPrefs {
	NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
	NSData *localPlayerPrefsData = [NSKeyedArchiver archivedDataWithRootObject:_localPlayerPrefs];
	[defaults setObject:localPlayerPrefsData forKey:NEZ_ALETTERATION_LOCAL_PLAYER_PREFS];
	[defaults synchronize];
}

-(void)loadLocalPlayerPrefs {
	NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
	NSData *localPlayerPrefsData = [defaults objectForKey:NEZ_ALETTERATION_LOCAL_PLAYER_PREFS];
	if (localPlayerPrefsData != nil) {
		_localPlayerPrefs = [NSKeyedUnarchiver unarchiveObjectWithData:localPlayerPrefsData];
	} else {
		_localPlayerPrefs = [[NezAletterationPlayerPrefs alloc] init];
		[self saveLocalPlayerPrefs];
	}
}

-(UIImage*)getLocalPlayerPhoto {
	return _localPlayerPrefs.photo;
}

-(void)setLocalPlayerPhoto:(UIImage*)photo {
	_localPlayerPrefs.photo = photo;
	[_defaultCenter postNotificationName:NEZ_ALETTERATION_NOTIFICATION_LOCAL_PLAYER_PHOTO_CHANGED object:nil];
}

-(NSString*)getLocalPlayerName {
	return _localPlayerPrefs.name;
}

-(void)setLocalPlayerName:(NSString*)name {
	_localPlayerPrefs.name = name;
	[_defaultCenter postNotificationName:NEZ_ALETTERATION_NOTIFICATION_LOCAL_PLAYER_NAME_CHANGED object:nil];
}

-(NSString*)getLocalPlayerNickName {
	return _localPlayerPrefs.nickName;
}

-(void)setLocalPlayerNickName:(NSString*)nickName {
	_localPlayerPrefs.nickName = nickName;
	[_defaultCenter postNotificationName:NEZ_ALETTERATION_NOTIFICATION_LOCAL_PLAYER_NICK_NAME_CHANGED object:nil];
}

-(GLKVector4)getLocalPlayerColor {
	return _localPlayerPrefs.color;
}

-(void)setLocalPlayerColor:(GLKVector4)color {
	_localPlayerPrefs.color = color;
	[_defaultCenter postNotificationName:NEZ_ALETTERATION_NOTIFICATION_LOCAL_PLAYER_COLOR_CHANGED object:nil];
}

-(BOOL)getLocalPlayerUndoConfirmation {
	return _localPlayerPrefs.undoConfirmation;
}

-(void)setLocalPlayerUndoConfirmation:(BOOL)undoConfirmation {
	_localPlayerPrefs.undoConfirmation = undoConfirmation;
	[_defaultCenter postNotificationName:NEZ_ALETTERATION_NOTIFICATION_LOCAL_PLAYER_UNDO_CONFIRMATION_CHANGED object:nil];
}

-(NSInteger)getLocalPlayerUndoCount {
	return _localPlayerPrefs.undoCount;
}

-(void)setLocalPlayerUndoCount:(NSInteger)undoCount {
	_localPlayerPrefs.undoCount = undoCount;
	[_defaultCenter postNotificationName:NEZ_ALETTERATION_NOTIFICATION_LOCAL_PLAYER_UNDO_COUNT_CHANGED object:nil];
}

-(BOOL)getLocalPlayerSoundsEnabled {
	return _localPlayerPrefs.soundsEnabled;
}

-(void)setLocalPlayerSoundsEnabled:(BOOL)soundsEnabled {
	_localPlayerPrefs.soundsEnabled = soundsEnabled;
	[_defaultCenter postNotificationName:NEZ_ALETTERATION_NOTIFICATION_LOCAL_PLAYER_SOUNDS_VOLUME_CHANGED object:nil];
}

-(float)getLocalPlayerSoundsVolume {
	return _localPlayerPrefs.soundsVolume;
}

-(void)setLocalPlayerSoundsVolume:(float)soundsVolume {
	_localPlayerPrefs.soundsVolume = soundsVolume;
	[_defaultCenter postNotificationName:NEZ_ALETTERATION_NOTIFICATION_LOCAL_PLAYER_SOUNDS_VOLUME_CHANGED object:nil];
}

-(BOOL)getLocalPlayerMusicEnabled {
	return _localPlayerPrefs.musicEnabled;
}

-(void)setLocalPlayerMusicEnabled:(BOOL)musicEnabled {
	_localPlayerPrefs.musicEnabled = musicEnabled;
	[_defaultCenter postNotificationName:NEZ_ALETTERATION_NOTIFICATION_LOCAL_PLAYER_MUSIC_ENABLED_CHANGED object:nil];
}

-(float)getLocalPlayerMusicVolume {
	return _localPlayerPrefs.musicVolume;
}

-(void)setLocalPlayerMusicVolume:(float)musicVolume {
	_localPlayerPrefs.musicVolume = musicVolume;
	[_defaultCenter postNotificationName:NEZ_ALETTERATION_NOTIFICATION_LOCAL_PLAYER_MUSIC_VOLUME_CHANGED object:nil];
}

-(BOOL)getLocalPlayerIsLowercase {
	return _localPlayerPrefs.isLowercase;
}

-(void)setLocalPlayerIsLowercase:(BOOL)isLowercase {
	_localPlayerPrefs.isLowercase = isLowercase;
	[_defaultCenter postNotificationName:NEZ_ALETTERATION_NOTIFICATION_LOCAL_PLAYER_IS_LOWERCASE_CHANGED object:nil];
}

-(GLKView*)getRootGLKView {
	return (GLKView*)self.rootGLKViewController.view;
}

-(void)updateAndDisplay {
	[_graphics update];
	[self.rootGLKView display];
}

-(float)getScaleFactor {
	return [[UIScreen mainScreen] scale];
}

-(CGSize)getCurrentSize {
	CGSize size = [UIScreen mainScreen].bounds.size;
	if (UIInterfaceOrientationIsLandscape([UIApplication sharedApplication].statusBarOrientation)) {
		return CGSizeMake(size.height, size.width);
	}
	return size;
}

-(CGRect)getCurrentFrame {
	CGSize size = [UIScreen mainScreen].bounds.size;
	if (UIInterfaceOrientationIsLandscape([UIApplication sharedApplication].statusBarOrientation)) {
		return CGRectMake(0, 0, size.height, size.width);
	}
	return CGRectMake(0, 0, size.width, size.height);
}

@end
