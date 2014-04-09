//
//  NezAletterationRealTimeMultiplayerViewController.h
//  Aletteration3
//
//  Created by David Nesbitt on 2013/10/18.
//  Copyright (c) 2013 David Nesbitt. All rights reserved.
//

#import <GLKit/GLKit.h>
#import "NezAletterationSinglePlayerGameViewController.h"
#import "NezGameCenter.h"
#import "NezAletterationGameState.h"

typedef enum {
	kNezAletterationNetworkMessageTypeReadyForInitialization = 0,
	kNezAletterationNetworkMessageTypePlayerInitialization,
	kNezAletterationNetworkMessageTypeMatchStart,
	kNezAletterationNetworkMessageTypeLetterBlockMoved,
	kNezAletterationNetworkMessageTypeLetterBlockPlaced,
	kNezAletterationNetworkMessageTypeColorChanged,
	kNezAletterationNetworkMessageTypeEndTurn,
	kNezAletterationNetworkMessageTypeUndoTurn,
	kNezAletterationNetworkMessageTypeRetireWord,
	kNezAletterationNetworkMessageTypeGameOver
} NezAletterationNetworkMessageType;

typedef struct {
	NezAletterationNetworkMessageType messageType;
} NezAletterationNetworkMessage;

typedef struct {
	NezAletterationNetworkMessage message;
	GLKVector4 color;
	char letterList[91];
} NezAletterationNetworkMessagePlayerInitialization;

typedef struct {
	NezAletterationNetworkMessage message;
	GLKMatrix4 modelMatrix;
} NezAletterationNetworkMessageBlockModelMatrix;

typedef struct {
	NezAletterationNetworkMessage message;
	int32_t lineIndex;
} NezAletterationNetworkMessageLetterBlockPlaced;

typedef struct {
	NezAletterationNetworkMessage message;
	GLKVector4 color;
} NezAletterationNetworkMessageColorChanged;

typedef struct {
	NezAletterationNetworkMessage message;
	int32_t lineIndex;
	int32_t turn;
	struct {
		int32_t state;
		int32_t index;
		int32_t length;
		int32_t turn;
	} lineState[NEZ_ALETTERATION_LINE_COUNT];
} NezAletterationNetworkMessageEndTurn;

typedef struct {
	NezAletterationNetworkMessage message;
	int32_t lineIndex;
	int32_t letterIndex;
} NezAletterationNetworkMessageRetireWord;

@interface NezAletterationRealTimeMultiplayerViewController : NezAletterationSinglePlayerGameViewController<NezGameCenterDelegate>

@end
