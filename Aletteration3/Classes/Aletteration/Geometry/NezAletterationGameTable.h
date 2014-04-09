//
//  NezAletterationGameTable.h
//  Aletteration3
//
//  Created by David Nesbitt on 2013-09-25.
//  Copyright (c) 2013 David Nesbitt. All rights reserved.
//

#import "NezAletterationRestorableGeometry.h"
#import "NezInstanceAttributeTypes.h"

@class NezAletterationGameState;
@class NezInstanceVertexArrayObjectLitColor;
@class NezAletterationBox;
@class NezAletterationLetterBox;

@interface NezAletterationGameTable : NezAletterationRestorableGeometry {
}

@property (getter = getColor, setter = setColor:) GLKVector4 color;
@property (nonatomic, readonly) NSArray *gameBoardList;
@property (nonatomic, readonly) NezAletterationBox *box;
@property (nonatomic, readonly, getter = getLidProxyGeometry) NezAletterationRestorableGeometry *lidProxyGeometry;
@property (nonatomic, getter = getCurrentGamePlayerList) NSMutableArray *playerList;
@property (nonatomic, readonly) NSInteger playerCount;

-(instancetype)initWithGameBoardList:(NSArray*)gameBoardList instanceVao:(NezInstanceVertexArrayObjectLitColor*)instanceVao andBox:(NezAletterationBox*)box;

-(void)setupTableForPlayerCount:(NSInteger)playerCount;
-(GLKMatrix4)matrixForLetterBox:(NezAletterationLetterBox*)letterBox andIndex:(NSInteger)index;

@end
