//
//  NezAletterationSinglePlayerGameViewController.h
//  Aletteration3
//
//  Created by David Nesbitt on 2013-09-30.
//  Copyright (c) 2013 David Nesbitt. All rights reserved.
//

#import <GLKit/GLKit.h>
#import "NezGCD.h"
#import "NezAletterationBaseGameViewController.h"

@class NezAletterationPlayer;
@class NezAletterationLetterBlock;
@class NezAletterationGameState;
@class NezAletterationGameBoard;
@class NezAletterationWordLine;

@interface NezAletterationSinglePlayerGameViewController : NezAletterationBaseGameViewController<UIAlertViewDelegate>

@property (weak, nonatomic) IBOutlet UIScrollView *dragBoardScrollView;
@property (nonatomic, weak) IBOutlet UIScrollView *optionsScrollView;

@property (getter = getAcceptsInput, setter = setAcceptsInput:) BOOL acceptsInput;

-(IBAction)exitAction:(id)sender;

-(void)setupView;
-(void)startGame;
-(void)startTurnForPlayer:(NezAletterationPlayer*)player;
-(void)endTurnCompleted;

-(IBAction)undoTurn:(id)sender;
-(void)undoTurnForPlayer:(NezAletterationPlayer*)player;

-(void)setLetterBlockModelMatrix:(GLKMatrix4)modelMatrix forPlayer:(NezAletterationPlayer*)player;
-(void)addLetterBlockForPlayer:(NezAletterationPlayer*)player toWordLine:(NezAletterationWordLine*)wordLine withAnimationFinishedBlock:(NezVoidBlock)animationFinishedBlock;

-(void)retireWordForPlayer:(NezAletterationPlayer*)player fromWordLine:(NezAletterationWordLine*)wordLine withAnimationFinishedBlock:(NezVoidBlock)animationFinishedBlock;
-(void)retireWordFromWordLine:(NezAletterationWordLine*)wordLine;

@end
