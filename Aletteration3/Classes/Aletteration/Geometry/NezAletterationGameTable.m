//
//  NezAletterationGameTable.m
//  Aletteration3
//
//  Created by David Nesbitt on 2013-09-25.
//  Copyright (c) 2013 David Nesbitt. All rights reserved.
//

#import "NezAletterationGameTable.h"
#import "NezAletterationGameBoard.h"
#import "NezAletterationGameState.h"
#import "NezAletterationLetterBox.h"
#import "NezAletterationPlayer.h"
#import "NezInstanceVertexArrayObjectLitColor.h"
#import "NezInstanceAttributeBufferObjectColor.h"
#import "NezVertexBufferObjectLitVertex.h"
#import "NezRandom.h"
#import "NezAletterationAppDelegate.h"

static const float kBoxSpacer = 0.1;
static const float kBigBoxThickness = 0.16;

@interface NezAletterationGameTable () {
	float _angle;
	float _offset;
	float _lidProxyGeometryOffsetY;
	NezInstanceVertexArrayObjectLitColor *_instanceVao;
	NezInstanceAttributeColor *_instanceAttributePtr;
	
	NSArray *_currentGamePlayerList;
}

@end

@implementation NezAletterationGameTable

-(instancetype)initWithGameBoardList:(NSArray*)gameBoardList instanceVao:(NezInstanceVertexArrayObjectLitColor*)instanceVao andBox:(NezAletterationBox*)box {
	if ((self = [super init])) {
		_gameBoardList = gameBoardList;
		_instanceVao = instanceVao;
		_instanceAttributePtr = _instanceVao.instanceAttributeList;
		_dimensions = _instanceVao.vertexBufferObject.dimensions;
		_box = box;

		_playerList = [NSMutableArray arrayWithCapacity:_gameBoardList.count];
		for (NezAletterationGameBoard *gameBoard in _gameBoardList) {
			NezAletterationPlayer *player = [[NezAletterationPlayer alloc] init];
			player.gameBoard = gameBoard;
			[_playerList addObject:player];
		}

		CGSize size = [NezAletterationAppDelegate sharedAppDelegate].currentSize;
		NezAletterationBox *bigBox = self.box;
		NezAletterationLid *bigLid = bigBox.lid;
		
		GLKVector3 lidProxyGeometryDimensions = bigLid.dimensions;
		float bigLidHeight = lidProxyGeometryDimensions.y;
		lidProxyGeometryDimensions.y = lidProxyGeometryDimensions.x*(size.height/size.width);
		
		_lidProxyGeometry = [[NezAletterationRestorableGeometry alloc] initWithDimensions:lidProxyGeometryDimensions];
		_lidProxyGeometryOffsetY = (bigLidHeight*0.5)-(bigLidHeight*0.117)-(_lidProxyGeometry.dimensions.y*0.5);
	}
	return self;
}

-(void)encodeRestorableStateWithCoder:(NSCoder*)coder {
	[super encodeRestorableStateWithCoder:coder];

	[coder encodeFloat:_angle forKey:@"_angle"];
	[coder encodeFloat:_offset forKey:@"_offset"];
	[coder encodeObject:_instanceVao forKey:@"_instanceVao"];

	[coder encodeObject:_box forKey:@"_box"];
	[coder encodeFloat:_lidProxyGeometryOffsetY forKey:@"_lidProxyGeometryOffsetY"];
	[coder encodeObject:_lidProxyGeometry forKey:@"_lidProxyGeometry"];

	[coder encodeObject:_gameBoardList forKey:@"_gameBoardList"];
	[coder encodeObject:_playerList forKey:@"_playerList"];
	
	if (_currentGamePlayerList) {
		[coder encodeObject:_currentGamePlayerList forKey:@"_currentGamePlayerList"];
	}
}

-(void)decodeRestorableStateWithCoder:(NSCoder*)coder {
	[super decodeRestorableStateWithCoder:coder];

	_angle = [coder decodeFloatForKey:@"_angle"];
	_offset = [coder decodeFloatForKey:@"_offset"];
	_instanceVao = [coder decodeObjectForKey:@"_instanceVao"];
	
	_box = [coder decodeObjectForKey:@"_box"];
	_lidProxyGeometryOffsetY = [coder decodeFloatForKey:@"_lidProxyGeometryOffsetY"];
	_lidProxyGeometry = [coder decodeObjectForKey:@"_lidProxyGeometry"];

	_gameBoardList = [coder decodeObjectForKey:@"_gameBoardList"];
	_playerList = [coder decodeObjectForKey:@"_playerList"];
	_playerCount = _playerList.count;

	_currentGamePlayerList = [coder decodeObjectForKey:@"_currentGamePlayerList"];
}

-(void)applicationFinishedRestoringState {
	_instanceAttributePtr = _instanceVao.instanceAttributeBufferObject.instanceAttributeList;
}

-(void)registerChildObjectsForStateRestoration {
	[super registerChildObjectsForStateRestoration];
	
	[_gameBoardList enumerateObjectsUsingBlock:^(NezAletterationGameBoard *gameBoard, NSUInteger idx, BOOL *stop) {
		[self registerChildObject:gameBoard withRestorationIdentifier:[NSString stringWithFormat:@"_gameBoardList[%lu]", (unsigned long)idx]];
	}];
	[_playerList enumerateObjectsUsingBlock:^(NezAletterationPlayer *player, NSUInteger idx, BOOL *stop) {
		[self registerChildObject:player withRestorationIdentifier:[NSString stringWithFormat:@"_playerList[%lu]", (unsigned long)idx]];
	}];
	[self registerChildObject:_box withRestorationIdentifier:@"_box"];
	[self registerChildObject:_lidProxyGeometry withRestorationIdentifier:@"_lidProxyGeometry"];
}

-(void)setModelMatrix:(GLKMatrix4)modelMatrix {
	_instanceAttributePtr->matrix = modelMatrix;

	self.box.modelMatrix = GLKMatrix4Translate(modelMatrix, 0.0f, 0.0f, self.box.dimensions.z/2.0f);
	GLKMatrix4 lidMatrix = [self.box lidMatrix];
	self.lidProxyGeometry.modelMatrix = GLKMatrix4Translate(lidMatrix, 0.0, _lidProxyGeometryOffsetY, 0.0);

	[_gameBoardList enumerateObjectsUsingBlock:^(NezAletterationGameBoard *gameBoard, NSUInteger i, BOOL *stop) {
		if (i < _playerCount) {
			gameBoard.modelMatrix = GLKMatrix4Translate(GLKMatrix4Rotate(modelMatrix, _angle*i, 0.0f, 0.0f, 1.0f), 0.0f, -_offset, 0.0f);
			gameBoard.angle = _angle*i;
		} else {
			gameBoard.modelMatrix = GLKMatrix4Scale(GLKMatrix4MakeTranslation(100000.0f, 100000.0f, 100000.0f), 0.0, 0.0, 0.0);//move the boards not in play offscreen and scale to zero
			gameBoard.angle = 0.0f;
		}
		NezAletterationLetterBox *letterBox = gameBoard.letterBox;
		letterBox.modelMatrix = [self matrixForLetterBox:letterBox andIndex:i];
	}];
	[super setModelMatrix:modelMatrix];
}

-(GLKMatrix4)matrixForLetterBox:(NezAletterationLetterBox*)letterBox andIndex:(NSInteger)index {
	float halfLidWidth = letterBox.lid.dimensions.x*0.5;
	float halfLidHeight = letterBox.lid.dimensions.y*0.5;
	float halfLidDepth = letterBox.lid.dimensions.z*0.5;
	float boxZ = halfLidDepth+kBigBoxThickness;
	float x = (index == 0 || index == 1)?-halfLidWidth-kBoxSpacer:halfLidWidth+kBoxSpacer;
	float y = (index == 0 || index == 3)?-halfLidHeight-kBoxSpacer:halfLidHeight+kBoxSpacer;
	return GLKMatrix4Translate(_modelMatrix, x, y, boxZ);
}

-(void)setColor:(GLKVector4)color {
	_instanceAttributePtr->color = color;
}

-(GLKVector4)getColor {
	return _instanceAttributePtr->color;
}

-(NSArray*)getCurrentGamePlayerList {
	return _currentGamePlayerList;
}

-(void)setupTableForPlayerCount:(NSInteger)playerCount {
	_playerCount = playerCount;
	
	NezAletterationGameBoard *gameBoard = _gameBoardList.firstObject;
	GLKVector3 boardDimensions = gameBoard.dimensions;
	if (_playerCount == 1) {
		_angle = 0;
		_offset = boardDimensions.y;
	} else if (_playerCount == 2) {
		_angle = M_PI;
		_offset = boardDimensions.y;
	} else if (_playerCount > 2) {
		_angle = (M_PI*2.0f)/(float)_playerCount;
		_offset = ((boardDimensions.x/2.0f)/tanf(_angle/2.0f))+(boardDimensions.y/2.0f);
	}
	for (NSInteger i=0; i<_playerCount;i++) {
		NezAletterationPlayer *player = _playerList[i];
		player.gameState = [[NezAletterationGameState alloc] init];
	}
	_currentGamePlayerList = [_playerList subarrayWithRange:NSMakeRange(0, _playerCount)];
}

-(NezGeometry*)getLidProxyGeeometry {
	return _lidProxyGeometry;
}

@end
