//
//  NezAletterationGameBoard.m
//  Aletteration3
//
//  Created by David Nesbitt on 2013-09-22.
//  Copyright (c) 2013 David Nesbitt. All rights reserved.
//

#import "NezAletterationGameBoard.h"
#import "NezAletterationAppDelegate.h"
#import "NezAletterationGraphics.h"
#import "NezAletterationLetterBox.h"
#import "NezAletterationLetterBlock.h"
#import "NezAletterationLetterStack.h"
#import "NezAletterationLetterStackLabel.h"
#import "NezAletterationWordLine.h"
#import "NezAletterationGameState.h"
#import "NezAletterationGameStateTurn.h"
#import "NezAletterationRetiredWordBoard.h"
#import "NezAletterationRetiredWord.h"
#import "NezAletterationGameStateRetiredWord.h"
#import "NezAletterationLetterBox.h"
#import "NezAletterationAnimationSlide.h"
#import "NezAletterationAnimationPushBackLetter.h"

static const float kHorizontalStackSpacer = 1.32f;
static const float kVerticalStackSpacer = 1.75f;
static const float kWordLineSpaceMultiplier = 1.03125f;

@interface NezAletterationGameBoard() {
	GLKVector3 _blockDimensions;
	GLKVector3 _wordLineDimensions;
}
@end

@implementation NezAletterationGameBoard

-(instancetype)initWithLetterBox:(NezAletterationLetterBox*)letterBox blockList:(NSArray*)letterBlockList lineList:(NSArray*)lineList andLabelList:(NSArray*)labelList {
	if ((self = [super init])) {
		_letterBlockList = letterBlockList;
		_wordLineList = lineList;
		_letterBox = letterBox;
		
		_usedLetterBlocksList = [NSMutableArray array];
		
		_letterStackList = [NSMutableArray arrayWithCapacity:NEZ_ALETTERATION_ALPHABET_COUNT];
		for (int i=0; i<NEZ_ALETTERATION_ALPHABET_COUNT; i++) {
			NezAletterationLetterStack *stack = [[NezAletterationLetterStack alloc] initWithLetter:i+'a' andLabel:labelList[i]];
			[_letterStackList addObject:stack];
		}
		[_letterBlockList enumerateObjectsUsingBlock:^(NezAletterationLetterBlock *block, NSUInteger idx, BOOL *stop) {
			block.index = idx;
			[_letterBox addLetterBlock:block];
		}];
		NezAletterationGraphics *graphics = [NezAletterationAppDelegate sharedAppDelegate].graphics;
		_blockDimensions = graphics.letterBlockDimensions;
		_wordLineDimensions = graphics.wordLineDimensions;
		_dimensions = GLKVector3Make((40)*_blockDimensions.x, (9.76)*_blockDimensions.y, 0.0);
		_mainBoardGeometry = [[NezAletterationRestorableGeometry alloc] initWithDimensions:GLKVector3Make(_wordLineDimensions.x, _dimensions.y, 0.0)];
		_junkBoardGeometry = [[NezAletterationRestorableGeometry alloc] initWithDimensions:GLKVector3Make(_blockDimensions.x*12.0, _dimensions.y, 0.0)];
		_retiredWordBoard = [[NezAletterationRetiredWordBoard alloc] initWithWidth:_blockDimensions.x*12.0 andHeight:_dimensions.y];

		_scrollLeft = [[NezAletterationAnimationSlide alloc] initWithFromGeometry:_mainBoardGeometry toGeometry:_junkBoardGeometry];
		_scrollRight = [[NezAletterationAnimationSlide alloc] initWithFromGeometry:_mainBoardGeometry toGeometry:_retiredWordBoard];
	}
	return self;
}

-(void)encodeRestorableStateWithCoder:(NSCoder*)coder {
	[super encodeRestorableStateWithCoder:coder];

	[coder encodeFloat:_color.r forKey:@"_color.r"];
	[coder encodeFloat:_color.g forKey:@"_color.g"];
	[coder encodeFloat:_color.b forKey:@"_color.b"];
	[coder encodeFloat:_color.a forKey:@"_color.a"];

	[coder encodeObject:_letterBlockList forKey:@"_letterBlockList"];
	[coder encodeObject:_wordLineList forKey:@"_wordLineList"];
	[coder encodeObject:_letterBox forKey:@"_letterBox"];
	[coder encodeObject:_currentLetterBlock forKey:@"_currentLetterBlock"];
	
	[coder encodeObject:_usedLetterBlocksList forKey:@"_usedLetterBlocksList"];
	[coder encodeObject:_letterStackList forKey:@"_letterStackList"];
	
	[coder encodeObject:_mainBoardGeometry forKey:@"_mainBoardGeometry"];
	[coder encodeObject:_junkBoardGeometry forKey:@"_junkBoardGeometry"];

	NSData *retiredWordBoardData = [NSKeyedArchiver archivedDataWithRootObject:_retiredWordBoard];
	[coder encodeObject:retiredWordBoardData forKey:@"retiredWordBoardData"];
}

-(void)decodeRestorableStateWithCoder:(NSCoder*)coder {
	[super decodeRestorableStateWithCoder:coder];
	
	_color.r = [coder decodeFloatForKey:@"_color.r"];
	_color.g = [coder decodeFloatForKey:@"_color.g"];
	_color.b = [coder decodeFloatForKey:@"_color.b"];
	_color.a = [coder decodeFloatForKey:@"_color.a"];
	
	_letterBlockList = [coder decodeObjectForKey:@"_letterBlockList"];
	_wordLineList = [coder decodeObjectForKey:@"_wordLineList"];
	_letterBox = [coder decodeObjectForKey:@"_letterBox"];
	_currentLetterBlock = [coder decodeObjectForKey:@"_currentLetterBlock"];
	
	_usedLetterBlocksList = [coder decodeObjectForKey:@"_usedLetterBlocksList"];
	_letterStackList = [coder decodeObjectForKey:@"_letterStackList"];

	_mainBoardGeometry = [coder decodeObjectForKey:@"_mainBoardGeometry"];
	_junkBoardGeometry = [coder decodeObjectForKey:@"_junkBoardGeometry"];
	
	NSData *retiredWordBoardData = [coder decodeObjectForKey:@"retiredWordBoardData"];
	_retiredWordBoard = [NSKeyedUnarchiver unarchiveObjectWithData:retiredWordBoardData];
}

-(void)registerChildObjectsForStateRestoration {
	[super registerChildObjectsForStateRestoration];
	
	[_letterBlockList enumerateObjectsUsingBlock:^(NezAletterationLetterBlock *letterBlock, NSUInteger idx, BOOL *stop) {
		[self registerChildObject:letterBlock withRestorationIdentifier:[NSString stringWithFormat:@"_letterBlockList[%lu]", (unsigned long)idx]];
	}];
	[_wordLineList enumerateObjectsUsingBlock:^(NezAletterationWordLine *wordLine, NSUInteger idx, BOOL *stop) {
		[self registerChildObject:wordLine withRestorationIdentifier:[NSString stringWithFormat:@"_wordLineList[%lu]", (unsigned long)idx]];
	}];
	[_letterStackList enumerateObjectsUsingBlock:^(NezAletterationLetterStack *letterStack, NSUInteger idx, BOOL *stop) {
		[self registerChildObject:letterStack withRestorationIdentifier:[NSString stringWithFormat:@"_letterStackList[%lu]", (unsigned long)idx]];
	}];
	[self registerChildObject:_letterBox withRestorationIdentifier:@"_letterBox"];
	[self registerChildObject:_mainBoardGeometry withRestorationIdentifier:@"_mainBoardGeometry"];
	[self registerChildObject:_junkBoardGeometry withRestorationIdentifier:@"_junkBoardGeometry"];
}

-(void)applicationFinishedRestoringState {
	NezAletterationGraphics *graphics = [NezAletterationAppDelegate sharedAppDelegate].graphics;
	_blockDimensions = graphics.letterBlockDimensions;
	_wordLineDimensions = graphics.wordLineDimensions;
	
	_scrollLeft = [[NezAletterationAnimationSlide alloc] initWithFromGeometry:_mainBoardGeometry toGeometry:_junkBoardGeometry];
	_scrollRight = [[NezAletterationAnimationSlide alloc] initWithFromGeometry:_mainBoardGeometry toGeometry:_retiredWordBoard];

	[_retiredWordBoard restoreRetiredWordsWithLetterBlockList:_letterBlockList];
}

-(NezAletterationLetterStack*)stackForLetter:(char)letter {
	if (letter >= 'a' && letter <= 'z') {
		return _letterStackList[letter-'a'];
	} else {
		return nil;
	}
}

-(void)setColor:(GLKVector4)color {
	_color = color;
	for (NezAletterationLetterBlock *block in _letterBlockList) {
		block.color = color;
	}
	_letterBox.color = color;
	GLKVector4 lineColor = GLKVector4Make(color.r, color.g, color.b, 0.5f);
	for (NezAletterationWordLine *line in _wordLineList) {
		line.color = lineColor;
		line.defaultColor = lineColor;
		line.selectedColor = GLKVector4Make(lineColor.r, lineColor.g, lineColor.b, 0.9f);
	}
}

-(void)setIsLowercase:(BOOL)isLowercase {
	_isLowercase = isLowercase;
	for (NezAletterationLetterBlock *block in _letterBlockList) {
		block.isLowercase = isLowercase;
	}
}

-(void)setLineColor:(GLKVector4)color {
	for (NezAletterationWordLine *line in _wordLineList) {
		line.color = color;
	}
}

-(void)setStackLabelColor:(GLKVector4)color {
	for (NezAletterationLetterStack *stack in _letterStackList) {
		stack.stackLabel.color = color;
	}
}

-(NezAletterationLetterBlock*)popLetterBlockFromStackForLetter:(char)letter {
	NezAletterationLetterStack *letterStack = [self stackForLetter:letter];
	NezAletterationLetterBlock *letterBlock = [letterStack pop];
	if (letterBlock) {
		[_usedLetterBlocksList addObject:letterBlock];
	}
	return letterBlock;
}

-(void)resetScrollGeometry {
	_mainBoardGeometry.dimensions = GLKVector3Make(_wordLineDimensions.x, _dimensions.y, 0.0);
	_junkBoardGeometry.dimensions = GLKVector3Make(_blockDimensions.x*12.0, _dimensions.y, 0.0);
	_retiredWordBoard = [[NezAletterationRetiredWordBoard alloc] initWithWidth:_blockDimensions.x*12.0 andHeight:_dimensions.y];
	
	_scrollLeft = [[NezAletterationAnimationSlide alloc] initWithFromGeometry:_mainBoardGeometry toGeometry:_junkBoardGeometry];
	_scrollRight = [[NezAletterationAnimationSlide alloc] initWithFromGeometry:_mainBoardGeometry toGeometry:_retiredWordBoard];
	
	[self setupScrollingGeometryWithModelMatrix:_modelMatrix];
}

-(void)pushBackAllUsedLetterBlocks:(BOOL)isAnimated andCompletedHandler:(NezVoidBlock)completedHandler {
	for (NezAletterationWordLine *wordLine in _wordLineList) {
		[wordLine removeAllLetterBlocks];
	}
	if (isAnimated) {
		NSMutableArray *letterListArray = [NSMutableArray arrayWithCapacity:NEZ_ALETTERATION_ALPHABET_COUNT];
		for (int i=0; i<NEZ_ALETTERATION_ALPHABET_COUNT; i++) {
			[letterListArray addObject:[NSMutableArray array]];
		}
		for (NezAletterationLetterBlock *letterBlock in _usedLetterBlocksList) {
			[letterListArray[letterBlock.letter-'a'] addObject:letterBlock];
		}
		[NezAletterationAnimationPushBackLetter animatePushBackWithLetterStackList:_letterStackList letterBlockListArray:letterListArray color:self.color andCompletedHandler:completedHandler];
	} else {
		for (NezAletterationLetterBlock *letterBlock in _usedLetterBlocksList) {
			NezAletterationLetterStack *letterStack = [self stackForLetter:letterBlock.letter];
			[letterStack push:letterBlock];
		}
		for (NezAletterationLetterStack *stack in _letterStackList) {
			stack.modelMatrix = stack.modelMatrix;
		}
	}
	[_usedLetterBlocksList removeAllObjects];
	[self resetScrollGeometry];
}

-(void)addRetiredWord:(NezAletterationRetiredWord*)retiredWord {
	[_retiredWordBoard addRetiredWord:retiredWord];
}

-(void)initializeBoardWithGameState:(NezAletterationGameState*)gameState {
//	[[gameState turnsInRange:NSMakeRange(_turn, gameState.turn-_turn)] enumerateObjectsUsingBlock:^(NezAletterationGameStateTurn *turn, NSUInteger idx, BOOL *stop) {
//		for (NezAletterationGameStateRetiredWord *gameStateRetiredWord in turn.retiredWordList) {
//			NezAletterationWordLine *wordLine = self.wordLineList[gameStateRetiredWord.lineIndex];
//			NSArray *letterBlockList = [wordLine removeBlocksInRange:gameStateRetiredWord.range];
//			NezAletterationRetiredWord *retiredWord = [[NezAletterationRetiredWord alloc] initWithGameStateRetiredWord:gameStateRetiredWord turnIndex:_turn+idx+1 andLetterBlockList:letterBlockList];
//			retiredWord.modelMatrix = [self.retiredWordBoard nextWordMatrix];
//			[self addRetiredWord:retiredWord];
//		}
//		if (turn.lineIndex > -1) {
//			NezAletterationLetterBlock *letterBlock = [self popLetterBlockFromStackForLetter:[gameState letterForTurn:_turn+idx]];
//			NezAletterationWordLine *wordLine = self.wordLineList[turn.lineIndex];
//			[wordLine addLetterBlock:letterBlock];
//		}
//	}];
}

-(void)endTurnWithGameState:(NezAletterationGameState*)gameState {
	_turn = gameState.turn;
	[self setupLetterBlocksForGameState:gameState isAnimated:YES];
}

-(void)setupLetterBlocksForGameState:(NezAletterationGameState*)gameState isAnimated:(BOOL)isAnimated {
	for (int i=0; i<NEZ_ALETTERATION_LINE_COUNT; i++) {
		NezAletterationWordLine *wordLine = self.wordLineList[i];
		[wordLine setupBlocksForState:[gameState currentLineStateForIndex:i] isAnimated:isAnimated];
	}
}

-(void)setAllBlockMatrices {
	for (int i=0; i<NEZ_ALETTERATION_LINE_COUNT; i++) {
		NezAletterationWordLine *wordLine = self.wordLineList[i];
		[wordLine setAllBlockMatrices];
	}
}

-(NezAletterationWordLine*)wordLineIntersectingRay:(NezRay*)ray {
	for (NezAletterationWordLine *line in _wordLineList) {
		if ([line intersect:ray]) {
			return line;
		}
	}
	return nil;
}

-(void)setupScrollingGeometryWithModelMatrix:(GLKMatrix4)modelMatrix {
	_mainBoardGeometry.modelMatrix = modelMatrix;
	_junkBoardGeometry.modelMatrix = GLKMatrix4Translate(modelMatrix, -_mainBoardGeometry.dimensions.x/2.0-_junkBoardGeometry.dimensions.x/2.0, 0.0f, 0.0f);
	_retiredWordBoard.originalMatrix = GLKMatrix4Translate(modelMatrix, _mainBoardGeometry.dimensions.x/2.0+_retiredWordBoard.dimensions.x/2.0, 0.0f, 0.0f);

	NezAletterationWordLine *line = _wordLineList.lastObject;
	_retiredWordBoard.firstWordMatrix = GLKMatrix4Translate(line.modelMatrix, line.dimensions.x/2.0f+_blockDimensions.x*0.75f, 0.0f, 0.0f);
	_retiredWordBoard.spaceMultiplier = kWordLineSpaceMultiplier;
}

-(void)setModelMatrix:(GLKMatrix4)modelMatrix {
	[super setModelMatrix:modelMatrix];

	float y = -_blockDimensions.y*2.0f;
	__block GLKMatrix4 mm = GLKMatrix4Translate(modelMatrix, -6.0f*_blockDimensions.x*kHorizontalStackSpacer, y, 0.0f);
	[_letterStackList enumerateObjectsUsingBlock:^(NezAletterationLetterStack *stack, NSUInteger idx, BOOL *stop) {
		stack.modelMatrix = mm;
		if (idx == 12) {
			mm = GLKMatrix4Translate(modelMatrix, -6.0f*_blockDimensions.x*kHorizontalStackSpacer, y-(_blockDimensions.y*kVerticalStackSpacer), 0.0f);
		} else {
			mm = GLKMatrix4Translate(mm, _blockDimensions.x*kHorizontalStackSpacer, 0.0f, 0.0f);
		}
	}];
	mm = GLKMatrix4Translate(modelMatrix, 0.0f, y+_blockDimensions.y*1.25, 0.0f);
	for (NezAletterationWordLine *line in _wordLineList) {
		line.modelMatrix = mm;
		mm = GLKMatrix4Translate(mm, 0.0f, _blockDimensions.y*kWordLineSpaceMultiplier, 0.0f);
	}
	[self setupScrollingGeometryWithModelMatrix:modelMatrix];
}

-(GLKVector3)getUpVector {
	return GLKMatrix3MultiplyVector3(GLKMatrix4GetMatrix3(_modelMatrix), GLKVector3Make(0.0f, 1.0f, 0.0f));
}

-(GLKMatrix4)getPoppedLetterMatrix {
	return GLKMatrix4Translate(_modelMatrix, 0.0f, -_blockDimensions.y*1.25, NEZ_ALETTERATION_SELECTION_Z);
}

-(GLKMatrix4)getPoppedLetterMatrixWithYOffset:(float)yOffset {
	return GLKMatrix4Translate(_modelMatrix, 0.0f, yOffset, NEZ_ALETTERATION_SELECTION_Z);
}

-(void)moveBlocksFromLetterBoxToStacks {
	[_letterBox detachBlocks];
	[_letterBox removeAllLetterBlocks];
	[_usedLetterBlocksList removeAllObjects];
	for (NezAletterationLetterBlock *block in _letterBlockList) {
		NezAletterationLetterStack *stack = _letterStackList[block.letter-'a'];
		[stack push:block];
	}
}


-(void)moveBlocksFromStacksToLetterBox {
	[_letterStackList enumerateObjectsUsingBlock:^(NezAletterationLetterStack *stack, NSUInteger idx, BOOL *stop) {
		[stack removeAllLetterBlocks];
	}];
	for (NezAletterationLetterBlock *block in _letterBlockList) {
		[_letterBox addLetterBlock:block];
	}
}

@end
