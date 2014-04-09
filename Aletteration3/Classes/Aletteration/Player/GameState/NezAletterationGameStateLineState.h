//
//  NezAletterationWordState.h
//  Aletteration3
//
//  Created by David Nesbitt on 2013-10-01.
//  Copyright (c) 2013 David Nesbitt. All rights reserved.
//

@class NezAletterationGameStateLineState;

@interface NezAletterationGameStateLineState : NSObject<NSCoding>

@property int32_t state;
@property int32_t index;
@property int32_t length;
@property int32_t turn;

+(NezAletterationGameStateLineState*)lineState;
+(NezAletterationGameStateLineState*)lineStateCopy:(NezAletterationGameStateLineState*)lineState;
+(NezAletterationGameStateLineState*)nextLineState:(NezAletterationGameStateLineState*)lineState;
+(NezAletterationGameStateLineState*)lineStateWithState:(int32_t)state index:(int32_t)index length:(int32_t)length andTurn:(int32_t)turn;

-(BOOL)isEqual:(NezAletterationGameStateLineState*)lineState;

@end
