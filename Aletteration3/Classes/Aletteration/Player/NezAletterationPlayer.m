//
//  NezAletterationPlayer.m
//  Aletteration3
//
//  Created by David Nesbitt on 2013-09-30.
//  Copyright (c) 2013 David Nesbitt. All rights reserved.
//

#import "NezAletterationPlayer.h"
#import "NezAletterationPlayerPrefs.h"
#import "NezAletterationAppDelegate.h"
#import "NezAletterationGraphics.h"
#import "NezAletterationGameBoard.h"
#import "NezAletterationWordLine.h"
#import "NezAletterationLetterStack.h"
#import "NezAletterationLetterBlock.h"
#import "NezAletterationRetiredWordBoard.h"
#import "NezAletterationRetiredWord.h"
#import "NezAletterationGameState.h"
#import "NezAletterationGameStateTurn.h"
#import "NezAletterationGameStateRetiredWord.h"
#import "NezAletterationLetterBlock.h"
#import "NezAnimator.h"
#import "NezAnimation.h"
#import "NezCubicBezier3d.h"
#import "NezAletterationGameStateLineState.h"
#import "NezAletterationSQLiteDictionary.h"

@interface NezAletterationPlayer() {
	NezAletterationPlayerPrefs *_prefs;
}

@end

@implementation NezAletterationPlayer

+(instancetype)player {
	return [[NezAletterationPlayer alloc] init];
}

-(instancetype)init {
	return [self initWithGameState:nil];
}

-(instancetype)initWithGameState:(NezAletterationGameState*)gameState {
	if ((self = [super init])) {
		_gameState = gameState;
		_prefs = [[NezAletterationPlayerPrefs alloc] init];
	}
	return self;
}

-(void)encodeRestorableStateWithCoder:(NSCoder*)coder {
	[super encodeRestorableStateWithCoder:coder];
	
	NSData *gameStateData = [NSKeyedArchiver archivedDataWithRootObject:_gameState];
	[coder encodeObject:gameStateData forKey:@"gameStateData"];
	[coder encodeObject:_gameBoard forKey:@"_gameBoard"];
	[coder encodeObject:_prefs forKey:@"_prefs"];
}

-(void)decodeRestorableStateWithCoder:(NSCoder*)coder {
	[super decodeRestorableStateWithCoder:coder];
	
	NSData *gameStateData = [coder decodeObjectForKey:@"gameStateData"];
	_gameState = [NSKeyedUnarchiver unarchiveObjectWithData:gameStateData];
	_gameBoard = [coder decodeObjectForKey:@"_gameBoard"];
	_prefs = [coder decodeObjectForKey:@"_prefs"];
}

-(void)registerChildObjectsForStateRestoration {
	[super registerChildObjectsForStateRestoration];
	
	[self registerChildObject:_prefs withRestorationIdentifier:@"_prefs"];
}

-(void)setGameBoard:(NezAletterationGameBoard*)gameBoard {
	_gameBoard = gameBoard;
	_gameBoard.color = _prefs.color;
//	[_gameBoard initializeBoardWithGameState:_gameState];
//	[_gameBoard setupLetterBlocksForGameState:_gameState isAnimated:NO];
}

-(UIImage*)getPrefsPhoto {
	return _prefs.photo;
}

-(void)setPrefsPhoto:(UIImage*)photo {
	_prefs.photo = photo;
}

-(NSString*)getPrefsName {
	return _prefs.name;
}

-(void)setPrefsName:(NSString*)name {
	_prefs.name = name;
}

-(NSString*)getPrefsNickName {
	return _prefs.nickName;
}

-(void)setPrefsNickName:(NSString*)nickName {
	_prefs.nickName = nickName;
}

-(GLKVector4)getPrefsColor {
	return _prefs.color;
}

-(void)setPrefsColor:(GLKVector4)color {
	_prefs.color = color;
	_gameBoard.color = _prefs.color;
	[_gameBoard setupLetterBlocksForGameState:_gameState isAnimated:NO];
}

-(BOOL)getPrefsIsLowercase {
	return _prefs.isLowercase;
}

-(void)setPrefsIsLowercase:(BOOL)isLowercase {
	_prefs.isLowercase = isLowercase;
	_gameBoard.isLowercase = _prefs.isLowercase;
}

-(NezAletterationLetterBlock*)getCurrentLetterBlock {
	return _gameBoard.currentLetterBlock;
}

-(void)setCurrentLetterBlock:(NezAletterationLetterBlock*)currentLetterBlock {
	_gameBoard.currentLetterBlock = currentLetterBlock;
}

-(void)undoTurn {
	NSArray *unretiredList = [_gameBoard.retiredWordBoard removeRetiredWordsForTurnIndex:_gameState.turn];
	if (unretiredList.count > 0) {
		[unretiredList enumerateObjectsUsingBlock:^(NezAletterationRetiredWord *retiredWord, NSUInteger idx, BOOL *stop) {
			NezAletterationWordLine *wordLine = _gameBoard.wordLineList[retiredWord.retiredWord.lineIndex];
			retiredWord.modelMatrix = [wordLine nextLetterBlockMatrix];
			[wordLine addLetterBlocks:retiredWord.letterBlockList];
		}];
	}
	NezAletterationGameStateTurn *previousStateTurn = _gameState.previousStateTurn;
	NezAletterationWordLine *wordLine = _gameBoard.wordLineList[previousStateTurn.lineIndex];
	NezAletterationLetterBlock *letterBlock = [wordLine removeLastLetterBlock];
	NSLog(@"%@", letterBlock);
	self.currentLetterBlock = letterBlock;
	[_gameState undoTurn];
}

-(void)animateUndoWithFinishedBlock:(NezVoidBlock)undoFinishedBlock {
	__weak NezAletterationPlayer *myself = self;
	__weak NezAletterationGameBoard *gameBoard = myself.gameBoard;
	__weak NezAletterationLetterBlock *currentLetterBlock = gameBoard.currentLetterBlock;
	if (currentLetterBlock) {
		__weak NezAletterationLetterStack *letterStack = [gameBoard stackForLetter:currentLetterBlock.letter];
		[letterStack push:currentLetterBlock];
		[NezAnimator animateMat4WithFromData:currentLetterBlock.modelMatrix ToData:[letterStack topModelMatrix] Duration:0.25 EasingFunction:easeInOutCubic UpdateBlock:^(NezAnimation *ani) {
			GLKMatrix4 *matrix = (GLKMatrix4*)ani.newData;
			currentLetterBlock.modelMatrix = *matrix;
		} DidStopBlock:^(NezAnimation *ani) {
			[myself animateUndoWordsWithFinishedBlock:undoFinishedBlock];
		}];
	} else {
		[myself animateUndoWordsWithFinishedBlock:undoFinishedBlock];
	}
}
	
-(void)animateUndoWordsWithFinishedBlock:(NezVoidBlock)undoFinishedBlock {
	NSArray *unretiredList = [_gameBoard.retiredWordBoard removeRetiredWordsForTurnIndex:_gameState.turn];
	__weak NezAletterationPlayer *myself = self;
	__weak NezAletterationGameBoard *gameBoard = myself.gameBoard;
	NezVoidBlock undoBlock = ^{
		__weak NezAletterationGameStateTurn *previousStateTurn = myself.gameState.previousStateTurn;
		__weak NezAletterationWordLine *wordLine = gameBoard.wordLineList[previousStateTurn.lineIndex];
		myself.currentLetterBlock = [wordLine removeLastLetterBlock];
		NSLog(@"%@", myself.currentLetterBlock);
		[myself.gameState undoTurn];
		if (undoFinishedBlock) {
			undoFinishedBlock();
		}
	};
	if (unretiredList.count > 0) {
		[unretiredList enumerateObjectsUsingBlock:^(NezAletterationRetiredWord *retiredWord, NSUInteger idx, BOOL *stop) {
			__weak NezAletterationWordLine *wordLine = gameBoard.wordLineList[retiredWord.retiredWord.lineIndex];
			[NezAnimator animateMat4WithFromData:retiredWord.modelMatrix ToData:[wordLine nextLetterBlockMatrix] Duration:1.0 EasingFunction:easeInOutCubic UpdateBlock:^(NezAnimation *ani) {
				GLKMatrix4 *matrix = (GLKMatrix4*)ani.newData;
				retiredWord.modelMatrix = *matrix;
			} DidStopBlock:^(NezAnimation *ani) {
				if (idx == 0) {
					undoBlock();
				}
			}];
			[wordLine addLetterBlocks:retiredWord.letterBlockList];
		}];
	} else {
		undoBlock();
	}
}

-(void)startGame {
	[_gameBoard moveBlocksFromLetterBoxToStacks];
}

-(BOOL)isGameOver {
	if (self.gameState.turn <= 90) {
		return NO;
	}
	for (int i=0; i<NEZ_ALETTERATION_LINE_COUNT; i++) {
		NezAletterationGameStateLineState *lineState = [_gameState currentLineStateForIndex:i];
		if (lineState.state == NEZ_DIC_INPUT_ISWORD || lineState.state == NEZ_DIC_INPUT_ISBOTH) {
			return NO;
		}
	}
	return YES;
}

-(void)exitGame:(BOOL)isAnimated andCompletedHandler:(NezVoidBlock)completedHandler {
	[_gameBoard pushBackAllUsedLetterBlocks:isAnimated andCompletedHandler:completedHandler];
}

@end
