//
//  NezAletterationGameState.h
//  Aletteration3
//
//  Created by David Nesbitt on 2013-09-30.
//  Copyright (c) 2013 David Nesbitt. All rights reserved.
//

#define NEZ_ALETTERATION_ALPHABET_COUNT 26
#define NEZ_ALETTERATION_LINE_COUNT 6

typedef struct NezAletterationLetterBag {
	unsigned char count[NEZ_ALETTERATION_ALPHABET_COUNT];
} NezAletterationLetterBag;

@class NezAletterationGameStateTurn;
@class NezAletterationGameStateLineState;
@class NezAletterationGameStateRetiredWord;

@interface NezAletterationGameState : NSObject<NSCoding>

@property (readonly, getter = getLetterList) char *letterList;
@property (readonly, getter = getCurrentLetter) char currentLetter;
@property (readonly, getter = getCurrentLetterIndex) char currentLetterIndex;
@property (readonly, getter = getTurn) NSInteger turn;
@property (readonly, getter = getPreviousTurn) NSInteger previousTurn;
@property (readonly, getter = getCurrentStateTurn) NezAletterationGameStateTurn *currentStateTurn;
@property (readonly, getter = getPreviousStateTurn) NezAletterationGameStateTurn *previousStateTurn;

+(int)letterCount;
+(NezAletterationLetterBag)fullLetterBag;

-(BOOL)startTurn;
-(void)endTurn;
-(void)endTurnWithLineIndex:(NSInteger)lineIndex andUpdatedLineStateList:(NSArray*)updatedLineStateList;
-(void)undoTurn;

-(NezAletterationGameStateLineState*)currentLineStateForIndex:(NSInteger)index;

-(NezAletterationGameStateRetiredWord*)retireWordFromLine:(NSInteger)lineIndex;

-(char)letterForTurn:(NSInteger)turnIndex;
-(NSArray*)turnsInRange:(NSRange)range;

-(void)useLetterList:(char*)srcLetterList;
-(void)copyLetterListIntoArray:(char*)dstLetterList;

@end
