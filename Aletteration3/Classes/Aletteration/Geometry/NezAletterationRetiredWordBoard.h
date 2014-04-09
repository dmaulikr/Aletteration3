//
//  NezAletterationScoreboard.h
//  Aletteration3
//
//  Created by David Nesbitt on 2013/10/09.
//  Copyright (c) 2013 David Nesbitt. All rights reserved.
//

#import "NezAletterationRestorableGeometry.h"

@class NezAletterationRetiredWord;

@interface NezAletterationRetiredWordBoard : NezGeometry<NSCoding>

@property float spaceMultiplier;
@property (nonatomic, setter = setFirstWordMatrix:) GLKMatrix4 firstWordMatrix;
@property (nonatomic, setter = setOriginalMatrix:) GLKMatrix4 originalMatrix;

-(instancetype)initWithWidth:(float)width andHeight:(float)height;

-(void)addRetiredWord:(NezAletterationRetiredWord*)retiredWord;
-(NSMutableArray*)removeRetiredWordsForTurnIndex:(NSInteger)turnIndex;
-(void)restoreRetiredWordsWithLetterBlockList:(NSArray*)letterBlockList;

-(GLKMatrix4)nextWordMatrix;

@end
