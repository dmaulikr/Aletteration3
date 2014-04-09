//
//  NezAletterationRealTimeMultiplayerViewController.m
//  Aletteration3
//
//  Created by David Nesbitt on 2013/10/18.
//  Copyright (c) 2013 David Nesbitt. All rights reserved.
//

#import "NezAletterationRealTimeMultiplayerViewController.h"
#import "NezAletterationAppDelegate.h"
#import "NezAletterationGraphics.h"
#import "NezAletterationPlayer.h"
#import "NezAletterationPlayerPrefs.h"
#import "NezAletterationGameCenterPlayer.h"
#import "NezAletterationGameBoard.h"
#import "NezAletterationLetterBlock.h"
#import "NezAletterationAnimationBeginGame.h"
#import "NezAletterationWordLine.h"
#import "NezAnimator.h"
#import "NezAnimation.h"
#import "NezAletterationGameState.h"
#import "NezAletterationGameStateTurn.h"
#import "NezAletterationGameStateLineState.h"

#define NEZ_ALETTERATION_MIN_PLAYERS 2
#define NEZ_ALETTERATION_MAX_PLAYERS 4

@interface NezAletterationDataReceivedQueueItem : NSObject 

@property (readonly) NSData *data;
@property (readonly) NSString *playerID;

@end

@implementation NezAletterationDataReceivedQueueItem

+(NezAletterationDataReceivedQueueItem*)queueItemWithData:(NSData*)data andPlayerID:(NSString*)playerID {
	return [[NezAletterationDataReceivedQueueItem alloc] initWithData:data andPlayerID:playerID];
}

-(instancetype)initWithData:(NSData*)data andPlayerID:(NSString*)playerID {
	if ((self = [super init])) {
		_data = data;
		_playerID = playerID;
	}
	return self;
}

@end

@interface NezAletterationRealTimeMultiplayerViewController () {
	NSMutableDictionary *_gcPlayerDictionary;
	NSArray *_sortedPlayerList;
	NSMutableArray *_dataReceivedQueue;
}

@property (readonly) NezGameCenter *gameCenter;
@property (readonly) BOOL needsToShowFindMatchViewController;
@property (readonly, getter = getMainPlayer) NezAletterationPlayer *mainPlayer;
@property (readonly, getter = getMainGKPlayer) GKPlayer *mainGKPlayer;
@property (readonly, getter = getMainPlayerID) NSString *mainPlayerID;
@property (readonly, getter = getLocalPlayerID) NSString *localPlayerID;

@end

@implementation NezAletterationRealTimeMultiplayerViewController

-(id)initWithCoder:(NSCoder *)aDecoder {
	if ((self = [super initWithCoder:aDecoder])) {
		_gameCenter = [NezGameCenter sharedInstance];
		_needsToShowFindMatchViewController = YES;
		_dataReceivedQueue = [NSMutableArray array];
	}
	return self;
}

-(void)showFindMatchViewController {
	_needsToShowFindMatchViewController = NO;
	[[NezGameCenter sharedInstance] findMatchWithMinPlayers:NEZ_ALETTERATION_MIN_PLAYERS maxPlayers:NEZ_ALETTERATION_MAX_PLAYERS viewController:self delegate:self];
}

-(void)setupView {
	if (self.needsToShowFindMatchViewController && self.gameCenter.localPlayer.isAuthenticated) {
		[self showFindMatchViewController];
	} else {
		[[NezGameCenter sharedInstance] authenticateLocalUserWithHandler:^(UIViewController *viewController, NSError *error) {
			GKLocalPlayer *localPlayer = [GKLocalPlayer localPlayer];
			if(viewController) {
				//present the login view
				[self presentViewController:viewController animated:YES completion:^{}];
			} else if (self.needsToShowFindMatchViewController && self.gameCenter.localPlayer.isAuthenticated) {
				[self showFindMatchViewController];
			} else if (!localPlayer.isAuthenticated) {
				//TODO:error handling
				NSLog(@"%@", error);
			}
		}];
	}
}

-(NezAletterationPlayer*)getMainPlayer {
	return [self playerForID:self.mainPlayerID];
}

-(GKPlayer*)getMainGKPlayer {
	return _sortedPlayerList.firstObject;
}

-(NSString*)getMainPlayerID {
	GKPlayer *player = _sortedPlayerList.firstObject;
	return player.playerID;
}

-(NSString*)getLocalPlayerID {
	GKPlayer *player = _sortedPlayerList[self.localPlayerIndex];
	return player.playerID;
}

-(NezAletterationGameCenterPlayer*)gcPlayerForID:(NSString*)playerID {
	return _gcPlayerDictionary[playerID];
}

-(GKPlayer*)gkPlayerForID:(NSString*)playerID {
	NezAletterationGameCenterPlayer *gcPlayer = _gcPlayerDictionary[playerID];
	return gcPlayer.gkPlayer;
}

-(NezAletterationPlayer*)playerForID:(NSString*)playerID {
	NezAletterationGameCenterPlayer *gcPlayer = _gcPlayerDictionary[playerID];
	return gcPlayer.player;
}

-(void)setLetterBlockModelMatrix:(GLKMatrix4)modelMatrix forPlayer:(NezAletterationPlayer*)player {
	[super setLetterBlockModelMatrix:modelMatrix forPlayer:player];
	if (player == self.localPlayer) {
		[self sendNetworkMessageLetterBlockMoved];
	}
}

-(void)addLetterBlockForPlayer:(NezAletterationPlayer*)player toWordLine:(NezAletterationWordLine*)wordLine withAnimationFinishedBlock:(NezVoidBlock)animationFinishedBlock {
	if (player == self.localPlayer) {
		[self sendNetworkMessageLetterBlockPlacedAtLineIndex:wordLine.lineIndex withCompletionHandler:^(BOOL success, NSError *error) {
			[super addLetterBlockForPlayer:player toWordLine:wordLine withAnimationFinishedBlock:animationFinishedBlock];
		}];
	}
}

-(void)endTurnCompleted {
	[self sendNetworkMessageEndTurnWithCompletionHandler:^(BOOL success, NSError *error) {
		if (success) {
			[super endTurnCompleted];
		} else {
			//TODO:error handling
		}
	}];
}

-(IBAction)undoTurn:(id)sender {
	[self sendNetworkMessageUndoTurnWithCompletionHandler:^(BOOL success, NSError *error) {
		[super undoTurn:sender];
	}];
}

-(void)retireWordFromWordLine:(NezAletterationWordLine*)wordLine {
	[self sendNetworkMessageRetireWordFromLine:wordLine.lineIndex withCompletionHandler:^(BOOL success, NSError *error) {
		[super retireWordFromWordLine:wordLine];
	}];
}

-(void)receivedLocalPlayerColorChangedNotification:(NSNotification *)notification {
	[self sendNetworkMessageColorChangedWithCompletionHandler:^(BOOL success, NSError *error) {
		[super receivedLocalPlayerColorChangedNotification:notification];
	}];
}

-(BOOL)areAllPlayersNetworkStateEqual:(NezAletterationNetworkState)networkState {
	for (NezAletterationGameCenterPlayer *gcPlayer in [_gcPlayerDictionary allValues]) {
		NSLog(@"%d == %d", networkState, gcPlayer.networkState);
		if (gcPlayer.networkState != networkState) {
			return NO;
		}
	}
	return YES;
}

-(void)setNetworkStatus:(NezAletterationNetworkState)networkState forPlayer:(NSString*)playerID {
	NezAletterationGameCenterPlayer *gcPlayer = [self gcPlayerForID:playerID];
	gcPlayer.networkState = networkState;
}

-(void)processQueuedData {
	for (NezAletterationDataReceivedQueueItem *queueItem in _dataReceivedQueue) {
		[self didReceiveData:queueItem.data fromPlayer:queueItem.playerID];
	}
	[_dataReceivedQueue removeAllObjects];
}

-(void)didReceiveData:(NSData*)data fromPlayer:(NSString *)playerID {
	NezAletterationNetworkMessage *message = (NezAletterationNetworkMessage*)[data bytes];
	switch (message->messageType) {
		case kNezAletterationNetworkMessageTypeReadyForInitialization: {
			[self receivedNetworkMessageReadyForInitializationFromPlayer:playerID];
			break;
		} case kNezAletterationNetworkMessageTypePlayerInitialization: {
			[self receivedNetworkMessagePlayerInitializationData:data fromPlayer:playerID];
		} case kNezAletterationNetworkMessageTypeMatchStart: {
			break;
		} case kNezAletterationNetworkMessageTypeLetterBlockMoved: {
			[self receivedNetworkMessageLetterBlockMovedData:data fromPlayer:playerID];
			break;
		} case kNezAletterationNetworkMessageTypeLetterBlockPlaced: {
			[self receivedNetworkMessageLetterBlockPlacedData:data fromPlayer:playerID];
			break;
		} case kNezAletterationNetworkMessageTypeColorChanged: {
			[self receivedNetworkMessageColorChanged:data fromPlayer:playerID];
			break;
		} case kNezAletterationNetworkMessageTypeEndTurn: {
			[self receivedNetworkMessageTypeEndTurnData:data fromPlayer:playerID];
			break;
		} case kNezAletterationNetworkMessageTypeUndoTurn: {
			[self receivedNetworkMessageUndoTurnFromPlayer:playerID];
			break;
		} case kNezAletterationNetworkMessageTypeRetireWord: {
			[self receivedNetworkMessageRetireWordData:data FromPlayer:playerID];
			break;
		} case kNezAletterationNetworkMessageTypeGameOver: {
			break;
		}
			
	}
}

#pragma mark - Send Network Message methods

-(void)sendNetworkMessage:(NezAletterationNetworkMessageType)messageType withCompletionHandler:(NezGameCenterDataSentBlock)dataSentBlock {
	NezAletterationNetworkMessage message;
	message.messageType = messageType;
	NSData *data = [NSData dataWithBytes:&message length:sizeof(NezAletterationNetworkMessage)];
	[self.gameCenter sendDataReliable:data withDataSentBlock:dataSentBlock];
}

-(void)sendNetworkMessageLetterBlockMoved {
	if (self.localPlayer.currentLetterBlock) {
		NezAletterationNetworkMessageBlockModelMatrix message;
		message.message.messageType = kNezAletterationNetworkMessageTypeLetterBlockMoved;
		message.modelMatrix = self.localPlayer.gameBoard.currentLetterBlock.modelMatrix;
		NSData *data = [NSData dataWithBytes:&message length:sizeof(NezAletterationNetworkMessageBlockModelMatrix)];
		[self.gameCenter sendDataUnreliable:data withDataSentBlock:^(BOOL success, NSError *error) {}];
	}
}

-(void)sendNetworkMessageReadyForInitializationWithCompletionHandler:(NezGameCenterDataSentBlock)dataSentBlock {
	[self sendNetworkMessage:kNezAletterationNetworkMessageTypeReadyForInitialization withCompletionHandler:dataSentBlock];
}

-(void)sendNetworkMessagePlayerInitializationWithCompletionHandler:(NezGameCenterDataSentBlock)dataSentBlock {
	NezAletterationNetworkMessagePlayerInitialization playerInitializationData;
	playerInitializationData.message.messageType = kNezAletterationNetworkMessageTypePlayerInitialization;
	NezAletterationPlayer *player = self.localPlayer;
	[player.gameState copyLetterListIntoArray:playerInitializationData.letterList];
	playerInitializationData.color = player.gameBoard.color;
	
	NSData *data = [NSData dataWithBytes:&playerInitializationData length:sizeof(NezAletterationNetworkMessagePlayerInitialization)];
	[self.gameCenter sendDataReliable:data withDataSentBlock:dataSentBlock];
}

-(void)sendNetworkMessageLetterBlockPlacedAtLineIndex:(NSInteger)lineIndex withCompletionHandler:(NezGameCenterDataSentBlock)dataSentBlock {
	NezAletterationNetworkMessageLetterBlockPlaced letterBlockPlacedMessage;
	letterBlockPlacedMessage.message.messageType = kNezAletterationNetworkMessageTypeLetterBlockPlaced;
	letterBlockPlacedMessage.lineIndex = (int32_t)lineIndex;
	
	NSData *data = [NSData dataWithBytes:&letterBlockPlacedMessage length:sizeof(NezAletterationNetworkMessageLetterBlockPlaced)];
	[self.gameCenter sendDataReliable:data withDataSentBlock:dataSentBlock];
}

-(void)sendNetworkMessageColorChangedWithCompletionHandler:(NezGameCenterDataSentBlock)dataSentBlock {
	NezAletterationNetworkMessageColorChanged colorChangedMessage;
	colorChangedMessage.message.messageType = kNezAletterationNetworkMessageTypeColorChanged;
	colorChangedMessage.color = self.localPlayer.gameBoard.color;
	
	NSData *data = [NSData dataWithBytes:&colorChangedMessage length:sizeof(NezAletterationNetworkMessageColorChanged)];
	[self.gameCenter sendDataUnreliable:data withDataSentBlock:dataSentBlock];
}

-(void)sendNetworkMessageEndTurnWithCompletionHandler:(NezGameCenterDataSentBlock)dataSentBlock {
	NezAletterationNetworkMessageEndTurn endTurnMessage;
	endTurnMessage.message.messageType = kNezAletterationNetworkMessageTypeEndTurn;
	
	NezAletterationGameState *gameState = self.localPlayer.gameState;
	endTurnMessage.lineIndex = gameState.currentStateTurn.lineIndex;
	endTurnMessage.turn = (int32_t)gameState.turn;
	for (int i=0; i<NEZ_ALETTERATION_LINE_COUNT; i++) {
		NezAletterationGameStateLineState *lineState = [gameState currentLineStateForIndex:i];
		if (lineState) {
			endTurnMessage.lineState[i].index = lineState.index;
			endTurnMessage.lineState[i].length = lineState.length;
			endTurnMessage.lineState[i].state = lineState.state;
			endTurnMessage.lineState[i].turn = lineState.turn;
		} else {
			endTurnMessage.lineState[i].index = -1;
			endTurnMessage.lineState[i].length = -1;
			endTurnMessage.lineState[i].state = -1;
			endTurnMessage.lineState[i].turn = -1;
		}
	}
	NSData *data = [NSData dataWithBytes:&endTurnMessage length:sizeof(NezAletterationNetworkMessageEndTurn)];
	[self.gameCenter sendDataReliable:data withDataSentBlock:dataSentBlock];
}

-(void)sendNetworkMessageUndoTurnWithCompletionHandler:(NezGameCenterDataSentBlock)dataSentBlock {
	[self sendNetworkMessage:kNezAletterationNetworkMessageTypeUndoTurn withCompletionHandler:dataSentBlock];
}

-(void)sendNetworkMessageRetireWordFromLine:(NSInteger)lineIndex withCompletionHandler:(NezGameCenterDataSentBlock)dataSentBlock {
	NezAletterationNetworkMessageRetireWord retireWordMessage;
	NezAletterationGameStateLineState *lineState = [self.localPlayer.gameState currentLineStateForIndex:lineIndex];
	retireWordMessage.message.messageType = kNezAletterationNetworkMessageTypeRetireWord;
	retireWordMessage.lineIndex = (int32_t)lineIndex;
	retireWordMessage.letterIndex = lineState.index;
	
	NSData *data = [NSData dataWithBytes:&retireWordMessage length:sizeof(NezAletterationNetworkMessageRetireWord)];
	[self.gameCenter sendDataReliable:data withDataSentBlock:dataSentBlock];
}

#pragma mark - Received Network Message methods


-(void)receivedNetworkMessageLetterBlockMovedData:(NSData*)data fromPlayer:(NSString*)playerID {
	NezAletterationNetworkMessageBlockModelMatrix *blockModelMatrix = (NezAletterationNetworkMessageBlockModelMatrix*)[data bytes];
	[self setLetterBlockModelMatrix:blockModelMatrix->modelMatrix forPlayer:[self playerForID:playerID]];
}

-(void)receivedNetworkMessageReadyForInitializationFromPlayer:(NSString*)playerID {
	NSLog(@"Recieved kNezAletterationNetworkMessageTypeReadyForInitialization from %@", playerID);
	[self setNetworkStatus:kNezAletterationNetworkStateReadyForMatchInitialization forPlayer:playerID];
	if ([self areAllPlayersNetworkStateEqual:kNezAletterationNetworkStateReadyForMatchInitialization]) {
		[self setNetworkStatus:kNezAletterationNetworkStateWaitingForMatchStart forPlayer:self.localPlayerID];
		[self sendNetworkMessagePlayerInitializationWithCompletionHandler:^(BOOL success, NSError *error) {
			NSLog(@"Sent kNezAletterationNetworkMessageTypePlayerInitializationData");
			//TODO:error handling
		}];
	}
}

-(void)receivedNetworkMessagePlayerInitializationData:(NSData*)data fromPlayer:(NSString*)playerID {
	[self setNetworkStatus:kNezAletterationNetworkStateWaitingForMatchStart forPlayer:playerID];
	NezAletterationNetworkMessagePlayerInitialization playerInitializationData = *((NezAletterationNetworkMessagePlayerInitialization*)[data bytes]);
	NSLog(@"Recieved kNezAletterationNetworkMessageTypePlayerInitializationData from %@", playerID);
	if ([self.mainPlayerID isEqualToString:playerID]) {
		for (NezAletterationGameCenterPlayer *gcPlayer in [_gcPlayerDictionary allValues]) {
			[gcPlayer.player.gameState useLetterList:playerInitializationData.letterList];
			NSLog(@"using:%s", playerInitializationData.letterList);
		}
	}
	NezAletterationPlayer *player = [self playerForID:playerID];
	player.gameBoard.color = playerInitializationData.color;
	if ([self areAllPlayersNetworkStateEqual:kNezAletterationNetworkStateWaitingForMatchStart]) {
		[NezAletterationAnimationBeginGame animateWithPlayerList:self.playerList localPlayer:self.localPlayer andDidStopHandler:^{
			[self startGame];
		}];
	}
}

-(void)receivedNetworkMessageLetterBlockPlacedData:(NSData*)data fromPlayer:(NSString*)playerID {
	NSLog(@"received kNezAletterationNetworkMessageTypeLetterBlockPlaced");
	NezAletterationNetworkMessageLetterBlockPlaced *letterBlockPlacedMessage = (NezAletterationNetworkMessageLetterBlockPlaced*)[data bytes];
	NezAletterationPlayer *player = [self playerForID:playerID];
	NezAletterationWordLine *wordLine = player.gameBoard.wordLineList[letterBlockPlacedMessage->lineIndex];
	NezAletterationLetterBlock *letterBlock = player.currentLetterBlock;
	if (letterBlock) {
		player.currentLetterBlock = nil;
		GLKMatrix4 matrix = [wordLine nextLetterBlockMatrix];
		[wordLine addLetterBlock:letterBlock];
		[NezAnimator animateMat4WithFromData:letterBlock.modelMatrix ToData:matrix Duration:0.25 EasingFunction:easeInOutCubic UpdateBlock:^(NezAnimation *ani) {
			GLKMatrix4 *matrix = (GLKMatrix4*)ani.newData;
			letterBlock.modelMatrix = *matrix;
		} DidStopBlock:^(NezAnimation *ani) {
		}];
	}
}

-(void)receivedNetworkMessageColorChanged:(NSData*)data fromPlayer:(NSString*)playerID {
	NSLog(@"received kNezAletterationNetworkMessageTypeColorChanged");
	NezAletterationNetworkMessageColorChanged *colorChangedMessage = (NezAletterationNetworkMessageColorChanged*)[data bytes];
	NezAletterationPlayer *player = [self playerForID:playerID];
	float r = colorChangedMessage->color.r;
	float g = colorChangedMessage->color.g;
	float b = colorChangedMessage->color.b;
	float a = colorChangedMessage->color.a;
	player.gameBoard.color = GLKVector4Make(r, g, b, a);
}

-(void)receivedNetworkMessageTypeEndTurnData:(NSData*)data fromPlayer:(NSString*)playerID {
	NezAletterationNetworkMessageEndTurn *endTurnMessage = (NezAletterationNetworkMessageEndTurn*)[data bytes];
	
	NezAletterationPlayer *player = [self playerForID:playerID];
	
	if (endTurnMessage->turn == player.gameState.turn) {
		NSMutableArray *updatedLineStateList = [NSMutableArray arrayWithCapacity:NEZ_ALETTERATION_LINE_COUNT];
		for (int i=0; i<NEZ_ALETTERATION_LINE_COUNT; i++) {
			int32_t state = endTurnMessage->lineState[i].state;
			int32_t index = endTurnMessage->lineState[i].index;
			int32_t length = endTurnMessage->lineState[i].length;
			int32_t turn = endTurnMessage->lineState[i].turn;
			[updatedLineStateList addObject:[NezAletterationGameStateLineState lineStateWithState:state index:index length:length andTurn:turn]];
			NSLog(@"--> %@", updatedLineStateList.lastObject);
		}
		[player.gameState endTurnWithLineIndex:endTurnMessage->lineIndex andUpdatedLineStateList:updatedLineStateList];
		[player.gameBoard endTurnWithGameState:player.gameState];
		[self startTurnForPlayer:player];
	} else {
		NSLog(@"WTF!?!?!?");
	}
}

-(void)receivedNetworkMessageUndoTurnFromPlayer:(NSString*)playerID {
	NezAletterationPlayer *player = [self playerForID:playerID];
	[self undoTurnForPlayer:player];
}

-(void)receivedNetworkMessageRetireWordData:(NSData*)data FromPlayer:(NSString*)playerID {
	NezAletterationNetworkMessageRetireWord *retireWordMessage = (NezAletterationNetworkMessageRetireWord*)[data bytes];
	NezAletterationPlayer *player = [self playerForID:playerID];
	NezAletterationWordLine *wordLine = player.gameBoard.wordLineList[retireWordMessage->lineIndex];
	[self retireWordForPlayer:player fromWordLine:wordLine withAnimationFinishedBlock:^{
		[player.gameBoard setupLetterBlocksForGameState:player.gameState isAnimated:YES];
	}];
}

#pragma mark - NezGameCenterDelegate methods

-(void)matchStarted {
	NSLog(@"match started");
	
	self.playerCount = self.gameCenter.opponentPlayerIdList.count+1;
	if (self.playerCount > 1) {
		_gcPlayerDictionary = [NSMutableDictionary dictionaryWithCapacity:self.playerCount];
		
		GKPlayer *localPlayer = self.gameCenter.localPlayer;
		NSString *localPlayeID = localPlayer.playerID;
		NSMutableArray *gkPlayerList = [NSMutableArray arrayWithCapacity:self.playerCount];
		[gkPlayerList addObject:localPlayer];
		
		[_gameCenter lookupOpponentsWithCompletionHandler:^(NSArray *opponentList, NSError *error) {
			[opponentList enumerateObjectsUsingBlock:^(GKPlayer *oppenent, NSUInteger idx, BOOL *stop) {
				[gkPlayerList addObject:oppenent];
			}];
			_sortedPlayerList = [gkPlayerList sortedArrayUsingComparator:^NSComparisonResult(GKPlayer *player1, GKPlayer *player2) {
				return [player1.playerID compare:player2.playerID];
			}];
			//must set localPlayerIndex before calling setupTable
			[_sortedPlayerList enumerateObjectsUsingBlock:^(GKPlayer *gkPlayer, NSUInteger idx, BOOL *stop) {
				if ([gkPlayer.playerID isEqualToString:localPlayeID]) {
					self.localPlayerIndex = idx;
					*stop = YES;
				}
			}];
			[self setupTable];
			[self scrollToPlayerWithIndex:self.localPlayerIndex+1];
			[_sortedPlayerList enumerateObjectsUsingBlock:^(GKPlayer *gkPlayer, NSUInteger idx, BOOL *stop) {
				NezAletterationGameCenterPlayer *gcPlayer = [NezAletterationGameCenterPlayer gcPlayerWithPlayer:self.playerList[idx] andGKPlayer:gkPlayer];
				
				_gcPlayerDictionary[gkPlayer.playerID] = gcPlayer;
				
				gcPlayer.player.prefsName = gkPlayer.displayName;
				gcPlayer.player.prefsNickName = gkPlayer.alias;
				[self.gameCenter loadPhotoForPlayer:gkPlayer withCompletionHandler:^(UIImage *photo, NSError *error) {
					if (photo && !error) {
						gcPlayer.player.prefsPhoto = photo;
						[self.collectionView reloadData];
					} else {
						NSLog(@"%@", error);
					}
				}];
			}];
			if ([self.localPlayerID isEqualToString:self.mainPlayerID]) {
				for (NezAletterationGameCenterPlayer *gcPlayer in [_gcPlayerDictionary allValues]) {
					NezAletterationPlayer *mainPlayer = [self playerForID:self.mainPlayerID];
					if (![gcPlayer.gkPlayer.playerID isEqualToString:self.mainPlayerID]) {
						[gcPlayer.player.gameState useLetterList:mainPlayer.gameState.letterList];
						NSLog(@"using:%s", gcPlayer.player.gameState.letterList);
					}
				}
			}
			[self setNetworkStatus:kNezAletterationNetworkStateReadyForMatchInitialization forPlayer:self.localPlayerID];
			[self sendNetworkMessageReadyForInitializationWithCompletionHandler:^(BOOL success, NSError *error) {
				NSLog(@"kNezAletterationNetworkMessageTypeReadyForInitialization sent");
				if (success) {
					[self processQueuedData];
				} else {
					//TODO:error handling
				}
			}];
		}];
	}
}

-(void)matchEnded {
	
}

-(void)match:(GKMatch *)match didReceiveData:(NSData *)data fromPlayer:(NSString *)playerID {
	NezAletterationGameCenterPlayer *gcLocalPlayer = [self gcPlayerForID:self.gameCenter.localPlayer.playerID];
	if (!gcLocalPlayer || gcLocalPlayer.networkState == kNezAletterationNetworkStateWaitingForMatchInitialization || _dataReceivedQueue.count > 0) {
		NSLog(@"Data came too soon. Queue it up!");
		[_dataReceivedQueue addObject:[NezAletterationDataReceivedQueueItem queueItemWithData:data andPlayerID:playerID]];
	} else {
		[self didReceiveData:data fromPlayer:playerID];
	}
}

-(void)match:(GKMatch *)match connectionfromPlayer:(NSString *)playerID {
	
}

-(void)match:(GKMatch *)match disconnectionfromPlayer:(NSString *)playerID {
	
}

-(void)matchmakerViewControllerWasCancelled {
	[self performSegueWithIdentifier:@"ExitGameSegue" sender:self];
}

-(void)matchmakerViewControllerDidFailWithError:(NSError*)error {
	[self performSegueWithIdentifier:@"ExitGameSegue" sender:self];
}

-(void)dealloc {
	NSLog(@"NezAletterationRealTimeMultiplayerViewController dealloc");
}

@end
