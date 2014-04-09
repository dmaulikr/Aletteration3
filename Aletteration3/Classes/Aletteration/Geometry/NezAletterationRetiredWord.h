//
//  NezAletterationRetiredWord.h
//  Aletteration3
//
//  Created by David Nesbitt on 2013/10/09.
//  Copyright (c) 2013 David Nesbitt. All rights reserved.
//

#import "NezAletterationRestorableGeometry.h"

@class NezAletterationGameStateRetiredWord;

@interface NezAletterationRetiredWord : NezGeometry<NSCoding>

@property (nonatomic, readonly) NSArray *letterBlockList;
@property (nonatomic, readonly) NezAletterationGameStateRetiredWord *retiredWord;
@property (readonly) NSInteger turnIndex;
@property (readonly, getter = getBonusLetterCount) NSInteger bonusLetterCount;

-(instancetype)initWithGameStateRetiredWord:(NezAletterationGameStateRetiredWord*)retiredWord turnIndex:(NSInteger)turnIndex andLetterBlockList:(NSArray*)leterBlockList;

-(void)restoreLetterBlockListWithLetterBlockList:(NSArray*)letterBlockList;

@end
