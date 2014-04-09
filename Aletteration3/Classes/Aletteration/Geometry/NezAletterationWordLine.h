//
//  NezAletterationLetterLine.h
//  Aletteration3
//
//  Created by David Nesbitt on 2013-09-23.
//  Copyright (c) 2013 David Nesbitt. All rights reserved.
//

#import <GLKit/GLKit.h>
#import "NezAletterationRestorableGeometry.h"
#import "NezInstanceAttributeTypes.h"

@class NezAletterationLetterBlock;
@class NezAletterationGameStateLineState;
@class NezInstanceVertexArrayObjectColor;

@interface NezAletterationWordLine : NezAletterationRestorableGeometry

@property NSInteger lineIndex;
@property (getter = getColor, setter = setColor:) GLKVector4 color;
@property GLKVector4 defaultColor;
@property GLKVector4 selectedColor;

-(instancetype)initWithLineVao:(NezInstanceVertexArrayObjectColor*)lineVao lineAttributeIndex:(NSInteger)lineAttributeIndex;

-(void)addLetterBlock:(NezAletterationLetterBlock*)letterBlock;
-(void)addLetterBlocks:(NSArray*)letterBlockList;

-(GLKMatrix4)letterBlockMatrixForIndex:(NSInteger)index;
-(GLKMatrix4)nextLetterBlockMatrix;

-(void)setAllBlockMatrices;
-(void)setAllBlockMatrices:(GLKMatrix4)matrix;
-(void)setupBlocksForState:(NezAletterationGameStateLineState*)lineState isAnimated:(BOOL)isAnimated;

-(NSArray*)removeBlocksInRange:(NSRange)range;
-(NezAletterationLetterBlock*)removeLastLetterBlock;
-(void)removeAllLetterBlocks;

-(void)animateSelected;
-(void)animateDeselected;

@end
