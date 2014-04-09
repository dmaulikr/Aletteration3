//
//  NezAletterationPlayer.h
//  Aletteration3
//
//  Created by David Nesbitt on 2013-09-30.
//  Copyright (c) 2013 David Nesbitt. All rights reserved.
//

#import <GLKit/GLKit.h>
#import "NezGCD.h"
#import "NezRestorableObject.h"

@class NezAletterationGameBoard;
@class NezAletterationGameState;
@class NezAletterationLetterBlock;
@class NezAletterationPlayerPrefs;

@interface NezAletterationPlayer: NezRestorableObject

@property (nonatomic, strong) NezAletterationGameState *gameState;
@property (nonatomic, setter = setGameBoard:) NezAletterationGameBoard *gameBoard;
@property (getter = getCurrentLetterBlock, setter = setCurrentLetterBlock:) NezAletterationLetterBlock *currentLetterBlock;
@property (nonatomic, getter = getPrefsPhoto, setter = setPrefsPhoto:) UIImage *prefsPhoto;
@property (nonatomic, getter = getPrefsName, setter = setPrefsName:) NSString *prefsName;
@property (nonatomic, getter = getPrefsNickName, setter = setPrefsNickName:) NSString *prefsNickName;
@property (nonatomic, getter = getPrefsColor, setter = setPrefsColor:) GLKVector4 prefsColor;
@property (nonatomic, getter = getPrefsIsLowercase, setter = setPrefsIsLowercase:) BOOL prefsIsLowercase;
@property (readonly, getter = isGameOver) BOOL isGameOver;

+(instancetype)player;

-(instancetype)init;
-(instancetype)initWithGameState:(NezAletterationGameState*)gameState;

-(void)startGame;
-(BOOL)isGameOver;
-(void)exitGame:(BOOL)isAnimated andCompletedHandler:(NezVoidBlock)completedHandler;

-(void)undoTurn;
-(void)animateUndoWithFinishedBlock:(NezVoidBlock)undoFinishedBlock;

@end

