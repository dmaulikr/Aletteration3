//
//  NezAletterationGameBoard.h
//  Aletteration3
//
//  Created by David Nesbitt on 2013-09-22.
//  Copyright (c) 2013 David Nesbitt. All rights reserved.
//

#import <GLKit/GLKit.h>
#import "NezAletterationRestorableGeometry.h"
#import "NezGCD.h"

#define NEZ_ALETTERATION_SELECTION_Z 5.0

@class NezAletterationGameState;
@class NezAletterationLetterBox;
@class NezAletterationLetterStack;
@class NezAletterationWordLine;
@class NezAletterationRetiredWordBoard;
@class NezAletterationLetterBox;
@class NezAletterationLetterBlock;
@class NezAletterationAnimationSlide;
@class NezAletterationRetiredWord;
@class NezRay;

@interface NezAletterationGameBoard : NezAletterationRestorableGeometry {
	NSMutableArray *_letterStackList;
	NSInteger _turn;
}

@property (readonly) NSArray *letterBlockList;
@property (readonly) NSArray *wordLineList;
@property float angle;
@property (nonatomic, setter = setColor:) GLKVector4 color;
@property (nonatomic, setter = setIsLowercase:) BOOL isLowercase;
@property (readonly, getter = getUpVector) GLKVector3 upVector;
@property (readonly) NezAletterationRestorableGeometry *mainBoardGeometry;
@property (readonly) NezAletterationRestorableGeometry *junkBoardGeometry;
@property (readonly) NezAletterationRetiredWordBoard *retiredWordBoard;
@property (readonly) NSMutableArray *usedLetterBlocksList;
@property NezAletterationLetterBox *letterBox;
@property (readonly) NezAletterationAnimationSlide *scrollLeft;
@property (readonly) NezAletterationAnimationSlide *scrollRight;
@property (nonatomic, weak) NezAletterationLetterBlock *currentLetterBlock;

-(instancetype)initWithLetterBox:(NezAletterationLetterBox*)letterBox blockList:(NSArray*)letterBlockList lineList:(NSArray*)lineList andLabelList:(NSArray*)labelList;

-(NezAletterationLetterStack*)stackForLetter:(char)letter;
-(NezAletterationWordLine*)wordLineIntersectingRay:(NezRay*)ray;

-(void)initializeBoardWithGameState:(NezAletterationGameState*)gameState;

-(NezAletterationLetterBlock*)popLetterBlockFromStackForLetter:(char)letter;

-(void)endTurnWithGameState:(NezAletterationGameState*)gameState;
-(void)setupLetterBlocksForGameState:(NezAletterationGameState*)gameState isAnimated:(BOOL)isAnimated;
-(void)setAllBlockMatrices;

-(void)addRetiredWord:(NezAletterationRetiredWord*)retiredWord;

-(void)moveBlocksFromLetterBoxToStacks;
-(void)moveBlocksFromStacksToLetterBox;
-(void)pushBackAllUsedLetterBlocks:(BOOL)isAnimated andCompletedHandler:(NezVoidBlock)completedHandler;

//Set all lines to color (for animating the color)
-(void)setLineColor:(GLKVector4)color;

//Set all stack labels to color (for animating the color)
-(void)setStackLabelColor:(GLKVector4)color;

-(GLKMatrix4)getPoppedLetterMatrixWithYOffset:(float)yOffset;

@end
