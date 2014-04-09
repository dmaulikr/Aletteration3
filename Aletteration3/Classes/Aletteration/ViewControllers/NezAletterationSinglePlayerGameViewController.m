//
//  NezAletterationSinglePlayerGameViewController.m
//  Aletteration3
//
//  Created by David Nesbitt on 2013-09-30.
//  Copyright (c) 2013 David Nesbitt. All rights reserved.
//

#import "NezAletterationSinglePlayerGameViewController.h"
#import "NezAletterationAppDelegate.h"
#import "NezAletterationAnimationBeginGame.h"
#import "NezAletterationAnimationExitGame.h"
#import "NezAletterationRetiredWordBoard.h"
#import "NezAletterationLetterBlock.h"
#import "NezAletterationPlayer.h"
#import "NezAletterationGameState.h"
#import "NezAletterationGameStateTurn.h"
#import "NezAletterationGameBoard.h"
#import "NezAletterationWordLine.h"
#import "NezAletterationAnimationSlide.h"
#import "NezAletterationAnimationRetireWord.h"
#import "NezAnimator.h"
#import "NezGLCamera.h"
#import "NezAletterationSQLiteDictionary.h"
#import "NezAletterationGameStateLineState.h"
#import "NezAletterationRetiredWord.h"
#import "NezAletterationGameStateRetiredWord.h"
#import "NezAletterationSaveGame.h"
#import "NezAletterationGraphics.h"
#import "NezCubicBezier2d.h"
#import "NezAnimationPath2d.h"
#import "NezAletterationPlayerOptionsViewController.h"
#import "NezGCD.h"
#import "NezRandom.h"
#import "NezVertexArrayObjectAcceleratingParticleEmitter.h"

@interface NezAletterationSinglePlayerGameViewController () {
	BOOL _acceptsInput;

	BOOL _tapInsideSelectedBlock;
	BOOL _tapCloseToSelectedBlock;
	NezAletterationWordLine *_blockOverLine;

	float _dragScrollOffset;
	CGSize _dragScrollSize;
	BOOL _autoScroll;

	BOOL _stateLoaded;
	
	NezCubicBezier2d *_easeInOutPath;
	
	UIAlertView *_undoConfirmationAlertView;
	UIAlertView *_getMoreUndoConfirmationAlertView;
}

@property (readonly, getter = getPoppedOffset) float poppedOffset;

@end

@implementation NezAletterationSinglePlayerGameViewController

-(void)animateParticles {
	__weak NezAletterationPlayer *localPlayer = self.localPlayer;
	__weak NezAletterationGraphics *graphics = _graphics;
	NezAnimation *ani = [[NezAnimation alloc] initFloatWithFromData:0.0 ToData:1.0 Duration:1.0 EasingFunction:easeLinear UpdateBlock:^(NezAnimation *ani) {
		if (localPlayer.currentLetterBlock) {
			NezVertexArrayObjectAcceleratingParticleEmitter *emitter = graphics.nextStarEmitter;
			emitter.center = localPlayer.currentLetterBlock.center;
			emitter.acceleration = GLKVector3Make(0.0, 6.0, 0.0);
			emitter.size = 5.0f;
			emitter.growth = 0.25f+randomFloatInRange(0.0, 0.15);
			emitter.decay = 0.25f+randomFloatInRange(0.0, 0.15);
			emitter.color0 = GLKVector4Make(0.0, 0.0, 0.5+randomFloatInRange(0.0, 0.25), 1.0);
			emitter.color1 = GLKVector4Make(0.0, 0.2+randomFloatInRange(0.0, 0.25), 0.25+randomFloatInRange(0.0, 0.25), 1.0);

			[emitter start];
		}
	} DidStopBlock:^(NezAnimation *ani) {
	}];
	ani.loop = NEZ_ANI_LOOP_FORWARD;
	[NezAnimator addAnimation:ani];
}

-(instancetype)initWithCoder:(NSCoder *)aDecoder {
	NSLog(@"NezAletterationSinglePlayerGameViewController initWithCoder");
	if ((self = [super initWithCoder:aDecoder])) {
		self.playerCount = 1;
		_easeInOutPath = [NezCubicBezier2d bezierWithControlPointsP0:GLKVector2Make(0.0, 0.0) P1:GLKVector2Make(0.42, 0.0) P2:GLKVector2Make(0.58, 1.0) P3:GLKVector2Make(1.0, 1.0)];
		_stateLoaded = NO;
		_dragScrollOffset = _app.currentSize.width;
	}
	return self;
}

-(void)viewWillAppear:(BOOL)animated {
	NSLog(@"NezAletterationSinglePlayerGameViewController viewWillAppear");
	[super viewWillAppear:animated];

	[self becomeFirstResponder];
	
	_dragScrollSize = _app.currentSize;
	_dragBoardScrollView.contentSize = CGSizeMake(_dragScrollSize.width*3.0f, _dragScrollSize.height);
	_dragBoardScrollView.contentOffset = CGPointMake(_dragScrollOffset, 0.0f);
	_dragBoardScrollView.hidden = YES;
	[self.view addGestureRecognizer:_dragBoardScrollView.panGestureRecognizer];

	[self setupOptionsView];
	if (self.optionsOpen) {
		[self showOptionsView:NO];
	}
}

-(void)viewDidAppear:(BOOL)animated {
	NSLog(@"NezAletterationSinglePlayerGameViewController viewDidAppear");
	[super viewDidAppear:animated];
	
	[self setupView];
}

-(void)viewDidDisappear:(BOOL)animated {
	[super viewDidDisappear:animated];
	NSLog(@"NezAletterationSinglePlayerGameViewController viewDidDisappear");
	[self.view removeGestureRecognizer:_dragBoardScrollView.panGestureRecognizer];
}

-(void)encodeRestorableStateWithCoder:(NSCoder*)coder {
	[super encodeRestorableStateWithCoder:coder];
	[coder encodeFloat:_dragBoardScrollView.contentOffset.x forKey:@"_dragScrollOffset"];
}

-(void)decodeRestorableStateWithCoder:(NSCoder*)coder {
	[super decodeRestorableStateWithCoder:coder];
	_dragScrollOffset = [coder decodeFloatForKey:@"_dragScrollOffset"];
}

-(void)applicationFinishedRestoringState {
	[super applicationFinishedRestoringState];
	NSLog(@"NezAletterationSinglePlayerGameViewController applicationFinishedRestoringState");
	_stateLoaded = YES;
}

-(void)setupView {
	if (!_stateLoaded) {
		[self setupTable];
		
		__weak NezAletterationSinglePlayerGameViewController *myself = self;
		[NezGCD dispatchBlock:^{
			[NezAletterationAnimationBeginGame animateWithPlayerList:self.playerList localPlayer:self.localPlayer andDidStopHandler:^{
				[myself startGame];
//				[myself animateParticles];
			}];
		} afterMilliseconds:150];
	} else {
		if (_dragBoardScrollView.contentOffset.x < _dragScrollSize.width) {
			[_camera lookAtGeometry:self.currentPlayer.gameBoard.junkBoardGeometry withZoomOptions:NezGLCameraZoomToFarthest];
		} else if (_dragBoardScrollView.contentOffset.x > _dragScrollSize.width) {
			[_camera lookAtGeometry:self.currentPlayer.gameBoard.retiredWordBoard withZoomOptions:NezGLCameraZoomToFarthest];
		} else {
			[_camera lookAtGeometry:self.currentPlayer.gameBoard.mainBoardGeometry withZoomOptions:NezGLCameraZoomToFarthest];
		}
		if (!self.localPlayer.isGameOver) {
			self.acceptsInput = YES;
		}
		NSLog(@"_stateLoaded");
	}
}

-(void)setupOptionsView {
	CGSize size = _app.currentSize;

	self.optionsViewController.view.frame = CGRectMake(0.0f, 0.0f, size.width, size.height);
	
	_optionsScrollView.contentSize = CGSizeMake(size.width, size.height*2.0f);
	_optionsScrollView.contentOffset = CGPointMake(0.0f, size.height);
	[_optionsScrollView addSubview:self.optionsViewController.view];
	_optionsScrollView.hidden = YES;
}

-(void)animateMenuWithCompletionHandler:(NezCompletionHandler)completionHandler {
	__weak NezAletterationSinglePlayerGameViewController *myself = self;
	__weak NezGLCamera *camera = _camera;

	CGRect startViewport = self.defaultEffectiveViewport;
	CGRect endViewport = self.menusEffectiveViewport;
	
	float dx = (endViewport.origin.x-startViewport.origin.x);
	float dy = (endViewport.origin.y-startViewport.origin.y);
	float dw = (endViewport.size.width-startViewport.size.width);
	float dh = (endViewport.size.height-startViewport.size.height);

	NezAnimationPath2d *ani = [[NezAnimationPath2d alloc] initWithPath:_easeInOutPath Duration:0.25 EasingFunction:EASE_LINEAR UpdateBlock:^(NezAnimationPath2d *ani, GLKVector2 positionOnPath) {
		float posY = myself.menuOpen?(1.0-positionOnPath.y):positionOnPath.y;
		float x = startViewport.origin.x+dx*positionOnPath.x;
		float y = startViewport.origin.y+dy*posY;
		float w = startViewport.size.width+dw*positionOnPath.x;
		float h = startViewport.size.height+dh*posY;
		CGRect viewport = CGRectMake(x, y, w, h);
		camera.effectiveViewport = viewport;
		
		myself.topToolbarTopConstraint.constant = -self.topToolbar.frame.size.height*(1.0-posY);
		myself.playerInfoContainerBottomConstraint.constant = -self.playerInfoContainer.frame.size.height*(1.0-posY);
	} DidStopBlock:^(NezAnimation *ani) {
		myself.menuOpen = !myself.menuOpen;
		if (completionHandler) {
			completionHandler(YES);
		}
	}];
	[NezAnimator addAnimation:ani];
}

-(void)showMenuWithCompletionHandler:(NezCompletionHandler)completionHandler {
	if (!self.menuOpen) {
		[self animateMenuWithCompletionHandler:^(BOOL finished) {
			[self moveCurrentLetterBlockForPlayer:self.localPlayer toDefaultPositionWithAnimationFinishedBlock:^{}];
			if (completionHandler) {
				completionHandler(finished);
			}
		}];
	} else if(completionHandler) {
		completionHandler(YES);
	}
}

-(void)hideMenuWithCompletionHandler:(NezCompletionHandler)completionHandler {
	if (self.menuOpen) {
		[self animateMenuWithCompletionHandler:^(BOOL finished) {
			[self moveCurrentLetterBlockForPlayer:self.localPlayer toDefaultPositionWithAnimationFinishedBlock:^{}];
			if (completionHandler) {
				completionHandler(finished);
			}
		}];
	} else if(completionHandler) {
		completionHandler(YES);
	}
}

-(void)showOptionsView:(BOOL)animated {
	_dragBoardScrollView.panGestureRecognizer.enabled = NO;
	self.optionsOpen = YES;
	CGSize size = _app.currentSize;
	[self.optionsViewController initializeControls];
	_optionsScrollView.hidden = NO;
	if (animated) {
		[self hideMenuWithCompletionHandler:^(BOOL finished) {}];
		[_optionsScrollView scrollRectToVisible:CGRectMake(0.0f, 0.0f, size.width, size.height) animated:animated];
	} else {
		_optionsScrollView.contentOffset = CGPointZero;
	}
}

-(void)hideOptionsView {
	self.optionsOpen = NO;
	_optionsScrollView.hidden = YES;
	_dragBoardScrollView.panGestureRecognizer.enabled = _acceptsInput;
}

-(IBAction)exitAction:(UIBarButtonItem*)sender {
	sender.enabled = NO;
	self.showMenuButton.enabled = NO;
	self.showMenuButton.hidden = YES;
	[self exitGame:YES];
}

-(void)exitGame:(BOOL)isAnimated {
	self.acceptsInput = NO;
	if (_dragBoardScrollView.contentOffset.x != _dragScrollSize.width) {
		[_camera stopLookingAtGeometry];
		_autoScroll = YES;
		[_dragBoardScrollView scrollRectToVisible:CGRectMake(_dragScrollSize.width, 0.0, _dragScrollSize.width, _dragScrollSize.height) animated:isAnimated];
	}
	[self hideMenuWithCompletionHandler:^(BOOL finished) {
		__weak NezAletterationPlayer *localPlayer = self.localPlayer;
		__weak NezAletterationSinglePlayerGameViewController *myself = self;
		[self.playerList enumerateObjectsUsingBlock:^(NezAletterationPlayer *player, NSUInteger idx, BOOL *stop) {
			[player.gameBoard pushBackAllUsedLetterBlocks:YES andCompletedHandler:^{
				if (player == localPlayer) {
					[NezAletterationAnimationExitGame animateWithPlayerList:self.playerList localPlayer:player andDidStopHandler:^{
						[myself performSegueWithIdentifier:@"ExitGameSegue" sender:self];
					}];
				}
			}];
		}];
	}];
}

-(BOOL)getAcceptsInput {
	return _acceptsInput;
}

-(void)setAcceptsInput:(BOOL)acceptsInput {
	_acceptsInput = acceptsInput;
	_dragBoardScrollView.panGestureRecognizer.enabled = acceptsInput;
}

-(void)startGame {
	[self.playerList enumerateObjectsUsingBlock:^(NezAletterationPlayer *player, NSUInteger idx, BOOL *stop) {
		[player startGame];
		[self startTurnForPlayer:player];
	}];
}

-(void)startTurnForPlayer:(NezAletterationPlayer*)player {
	BOOL turnStarted = [player.gameState startTurn];
	if (turnStarted) {
		player.currentLetterBlock = [player.gameBoard popLetterBlockFromStackForLetter:player.gameState.currentLetter];
		if (player == self.localPlayer && player.currentLetterBlock) {
			__weak NezAletterationSinglePlayerGameViewController *myself = self;
			[self moveCurrentLetterBlockForPlayer:self.localPlayer toDefaultPositionWithAnimationFinishedBlock:^{
				myself.acceptsInput = YES;
			}];
		}
	}
}

-(void)endTurn {
	[_blockOverLine addLetterBlock:self.localPlayer.currentLetterBlock];
	
	_blockOverLine = nil;
	_tapInsideSelectedBlock = NO;
	_tapCloseToSelectedBlock = NO;
	
	//[gameState endTurn] checks the database and can be quite slow. Run in a low priority block.
	__weak NezAletterationSinglePlayerGameViewController *myself = self;
	__weak NezAletterationGameState *gameState = self.localPlayer.gameState;
	__weak NezAletterationGameBoard *gameBoard = self.localPlayer.gameBoard;
	
	[NezGCD runLowPriorityWithWorkBlock:^{
		[gameState endTurn];
	} DoneBlock:^{
		[gameBoard endTurnWithGameState:gameState];
		[myself endTurnCompleted];
	}];
}

-(void)endTurnCompleted {
	[self startTurnForPlayer:self.localPlayer];
}

-(float)getPoppedOffset {
	if (self.menuOpen) {
		return _graphics.letterBlockDimensions.y*-2.00;
	} else {
		return _graphics.letterBlockDimensions.y*-1.25;
	}
}

-(void)moveCurrentLetterBlockForPlayer:(NezAletterationPlayer*)player toDefaultPositionWithAnimationFinishedBlock:(NezVoidBlock)animationFinishedBlock {
	if (player.currentLetterBlock) {
		player.gameState.currentStateTurn.temporaryLineIndex = -1;
		if (animationFinishedBlock) {
			GLKMatrix4 matrix = [player.gameBoard getPoppedLetterMatrixWithYOffset:self.poppedOffset];
			__weak NezAletterationSinglePlayerGameViewController *myself = self;
			[NezAnimator animateMat4WithFromData:player.currentLetterBlock.modelMatrix ToData:matrix Duration:0.75 EasingFunction:EASE_OUT_ELASTIC UpdateBlock:^(NezAnimation *ani) {
				GLKMatrix4 *matrix = (GLKMatrix4*)ani.newData;
				[myself setLetterBlockModelMatrix:*matrix forPlayer:player];
			} DidStopBlock:^(NezAnimation *ani) {
				animationFinishedBlock();
			}];
		} else {
			[self setLetterBlockModelMatrix:[player.gameBoard getPoppedLetterMatrixWithYOffset:self.poppedOffset] forPlayer:player];
		}
	}
}

-(void)setLetterBlockModelMatrix:(GLKMatrix4)modelMatrix forPlayer:(NezAletterationPlayer*)player {
	if (player && player.currentLetterBlock) {
		player.currentLetterBlock.modelMatrix = modelMatrix;
	}
}

-(void)addLetterBlockForPlayer:(NezAletterationPlayer*)player toWordLine:(NezAletterationWordLine*)wordLine withAnimationFinishedBlock:(NezVoidBlock)animationFinishedBlock {
	if (player.currentLetterBlock && wordLine) {
		player.gameState.currentStateTurn.temporaryLineIndex = wordLine.lineIndex;
		if (animationFinishedBlock) {
			BOOL acceptsInput = self.acceptsInput;
			self.acceptsInput = NO;
			GLKMatrix4 matrix = [wordLine nextLetterBlockMatrix];
			
			__weak NezAletterationSinglePlayerGameViewController *myself = self;
			[NezAnimator animateMat4WithFromData:player.currentLetterBlock.modelMatrix ToData:matrix Duration:0.25 EasingFunction:easeInOutCubic UpdateBlock:^(NezAnimation *ani) {
				GLKMatrix4 *matrix = (GLKMatrix4*)ani.newData;
				player.currentLetterBlock.modelMatrix = *matrix;
			} DidStopBlock:^(NezAnimation *ani) {
				animationFinishedBlock();
				myself.acceptsInput = acceptsInput;
			}];
		} else {
			GLKMatrix4 matrix = [wordLine nextLetterBlockMatrix];
			player.currentLetterBlock.modelMatrix = matrix;
		}
	}
}

-(void)retireWordFromWordLine:(NezAletterationWordLine*)wordLine {
	__weak NezAletterationSinglePlayerGameViewController *myself = self;
	[self retireWordForPlayer:self.localPlayer fromWordLine:wordLine withAnimationFinishedBlock:^{
		[myself.localPlayer.gameBoard setupLetterBlocksForGameState:myself.localPlayer.gameState isAnimated:YES];
	}];
}

-(void)retireWordForPlayer:(NezAletterationPlayer*)player fromWordLine:(NezAletterationWordLine*)wordLine withAnimationFinishedBlock:(NezVoidBlock)animationFinishedBlock {
	if (wordLine) {
		NezAletterationGameStateLineState *lineState = [player.gameState currentLineStateForIndex:wordLine.lineIndex];
		if (lineState.state == NEZ_DIC_INPUT_ISWORD || lineState.state == NEZ_DIC_INPUT_ISBOTH) {
			NezAletterationGameStateRetiredWord *gameStateRetiredWord = [player.gameState retireWordFromLine:wordLine.lineIndex];
			NSArray *letterBlockList = [wordLine removeBlocksInRange:gameStateRetiredWord.range];
			NezAletterationRetiredWord *retiredWord = [[NezAletterationRetiredWord alloc] initWithGameStateRetiredWord:gameStateRetiredWord turnIndex:player.gameState.turn andLetterBlockList:letterBlockList];
			if (animationFinishedBlock) {
				BOOL acceptsInput = self.acceptsInput;
				if (player == self.localPlayer) {
					self.acceptsInput = NO;
				}
				__weak NezAletterationSinglePlayerGameViewController *myself = self;
				__weak NezAletterationGameBoard *gameBoard = player.gameBoard;
				[NezAletterationAnimationRetireWord animateWithRetiredWord:retiredWord gameBoard:gameBoard andDidStopBlock:^(NezAnimation *ani) {
					[gameBoard addRetiredWord:retiredWord];
					animationFinishedBlock();
					if (player == myself.localPlayer) {
						myself.acceptsInput = acceptsInput;
					}
				}];
			} else {
				retiredWord.modelMatrix = [player.gameBoard.retiredWordBoard nextWordMatrix];
			}
		}
	}
}

-(void)motionEnded:(UIEventSubtype)motion withEvent:(UIEvent *)event {
	if (!self.acceptsInput) {
		return;
	}
	if (motion == UIEventSubtypeMotionShake) {
		[self undoTurn:self];
	}
}

-(GLKVector2)getPositionForAnyTouch:(NSSet*)touches TapCount:(NSInteger*)tapCount {
	return [self getPositionTouch:[touches anyObject] TapCount:tapCount];
}

-(GLKVector2)getPositionTouch:(UITouch*)touch TapCount:(NSInteger*)tapCount {
	if (tapCount) {
		*tapCount = [touch tapCount];
	}
	CGPoint currentLocation = [touch locationInView:self.view];
	return GLKVector2Make(currentLocation.x, currentLocation.y);
}

-(void)touchesBegan:(NSSet*)touches withEvent:(UIEvent*)event {
	if (!self.acceptsInput) {
		return;
	}
	NSInteger tapCount;
	GLKVector2 touchPos = [self getPositionForAnyTouch:touches TapCount:&tapCount];
	NezRay *ray = [_camera getWorldRay:touchPos];
	if ([self.localPlayer.currentLetterBlock intersect:ray]) {
		_tapInsideSelectedBlock = YES;
		_dragBoardScrollView.panGestureRecognizer.enabled = NO;
	} else {
		_tapInsideSelectedBlock = NO;
		if ([self.localPlayer.currentLetterBlock intersect:ray withExtraSize:0.5]) {
			_tapCloseToSelectedBlock = YES;
			_dragBoardScrollView.panGestureRecognizer.enabled = NO;
		} else {
			_tapCloseToSelectedBlock = NO;
		}
	}
}

-(void)touchesMoved:(NSSet*)touches withEvent:(UIEvent*)event {
	if (!self.acceptsInput) {
		return;
	}
	NSInteger tapCount;
	GLKVector2 touchPos = [self getPositionForAnyTouch:touches TapCount:&tapCount];
	NezRay *ray = [_camera getWorldRay:touchPos];
	if (_tapCloseToSelectedBlock) {
		if ([self.localPlayer.currentLetterBlock intersect:ray]) {
			_tapInsideSelectedBlock = YES;
			_tapCloseToSelectedBlock = NO;
		}
	}
	if (_tapInsideSelectedBlock) {
		GLKVector3 worldPos = [_camera getWorldCoordinates:touchPos atWorldZ:NEZ_ALETTERATION_SELECTION_Z];
		GLKMatrix4 matrix = [self.localPlayer.gameBoard getPoppedLetterMatrixWithYOffset:0.0f];
		matrix.m30 = worldPos.x;
		matrix.m31 = worldPos.y;
		matrix.m32 = worldPos.z;
		[self setLetterBlockModelMatrix:matrix forPlayer:self.localPlayer];
		NezAletterationWordLine *wordLine = [self.localPlayer.gameBoard wordLineIntersectingRay:ray];
		if (wordLine != _blockOverLine) {
			[_blockOverLine animateDeselected];
			_blockOverLine = wordLine;
			[_blockOverLine animateSelected];
		}
	}
}

-(void)touchesEnded:(NSSet*)touches withEvent:(UIEvent*)event {
	if (self.acceptsInput) {
		__weak NezAletterationSinglePlayerGameViewController *myself = self;
		if (_blockOverLine) {
			[_blockOverLine animateDeselected];
			[self addLetterBlockForPlayer:self.localPlayer toWordLine:_blockOverLine withAnimationFinishedBlock:^() {
				[myself endTurn];
			}];
		} else {
			if (_tapInsideSelectedBlock) {
				BOOL acceptsInput = self.acceptsInput;
				self.acceptsInput = NO;
				[self moveCurrentLetterBlockForPlayer:self.localPlayer toDefaultPositionWithAnimationFinishedBlock:^{
					myself.acceptsInput = acceptsInput;
				}];
			} else {
				NSInteger tapCount = 0;
				GLKVector2 touchPos = [self getPositionForAnyTouch:touches TapCount:&tapCount];
				if (tapCount == 2) {
					NezRay *ray = [_camera getWorldRay:touchPos];
					NezAletterationWordLine *wordLine = [self.localPlayer.gameBoard wordLineIntersectingRay:ray];
					if (wordLine) {
						NezAletterationGameStateLineState *lineState = [self.localPlayer.gameState currentLineStateForIndex:wordLine.lineIndex];
						if (lineState.state == NEZ_DIC_INPUT_ISWORD || lineState.state == NEZ_DIC_INPUT_ISBOTH) {
							[self retireWordFromWordLine:wordLine];
						}
					}
				}
			}
		}
	}
	_tapInsideSelectedBlock = NO;
	_tapCloseToSelectedBlock = NO;
	_dragBoardScrollView.panGestureRecognizer.enabled = _acceptsInput;
}

-(void)touchesCancelled:(NSSet*)touches withEvent:(UIEvent*)event {
	_tapInsideSelectedBlock = NO;
	_tapCloseToSelectedBlock = NO;
	_dragBoardScrollView.panGestureRecognizer.enabled = _acceptsInput;
}

-(void)scrollViewDidScroll:(UIScrollView *)scrollView {
	if (!self.acceptsInput && !_autoScroll) {
		return;
	}
	if (scrollView == _dragBoardScrollView) {
		float xOffset = _dragBoardScrollView.contentOffset.x;
		if (xOffset > _dragScrollSize.width) {
			float t = (xOffset-_dragScrollSize.width)/_dragScrollSize.width;
			//Drag to retired board
			[self.currentPlayer.gameBoard.scrollRight scrollToPositionWithTime:t andCamera:_camera];
		} else if (xOffset < _dragScrollSize.width) {
			float t = 1.0f-(xOffset/_dragScrollSize.width);
			//Drag to junk
			[self.currentPlayer.gameBoard.scrollLeft scrollToPositionWithTime:t andCamera:_camera];
		} else {
			[_camera lookAtGeometry:self.currentPlayer.gameBoard.mainBoardGeometry withZoomOptions:NezGLCameraZoomToFarthest];
		}
	} else if (scrollView == _optionsScrollView) {
		if (_optionsScrollView.contentOffset.y == self.view.frame.size.height) {
			[self hideOptionsView];
		}
	} else {
		[super scrollViewDidScroll:scrollView];
	}
}

-(void)alertView:(UIAlertView *)alertView didDismissWithButtonIndex:(NSInteger)buttonIndex {
	if (buttonIndex != alertView.cancelButtonIndex){
		if (alertView == _undoConfirmationAlertView) {
			_undoConfirmationAlertView.delegate = nil;
			_undoConfirmationAlertView = nil;
			[self undoTurnForLocalPlayer];
		} else if (alertView == _getMoreUndoConfirmationAlertView) {
			_getMoreUndoConfirmationAlertView.delegate = nil;
			_getMoreUndoConfirmationAlertView = nil;
			_app.localPlayerUndoCount = 10;
		}
	}
}

-(IBAction)undoTurn:(id)sender {
	if (self.localPlayer.gameState.turn > 1) {
		if (_app.localPlayerUndoCount == 0) {
			_getMoreUndoConfirmationAlertView = [[UIAlertView alloc] initWithTitle:@"Need More Undos"
																							  message:@"You don't have anymore undos left.\nWould you like to get some more?"
																							 delegate:self
																				 cancelButtonTitle:@"Cancel"
																				 otherButtonTitles:@"Get More!", nil];
			[_getMoreUndoConfirmationAlertView show];
		} else {
			if (_app.localPlayerUndoConfirmation) {
				NSString *undoMessage;
				if (_app.localPlayerUndoCount == 1) {
					undoMessage = @"only 1 undo";
				} else {
					undoMessage = [NSString stringWithFormat:@"%d undos", (int)_app.localPlayerUndoCount];
				}
				_undoConfirmationAlertView = [[UIAlertView alloc] initWithTitle:@"Undo Turn"
																						  message:[NSString stringWithFormat:@"You have %@ remaining.\nDo you really want to undo turn?", undoMessage]
																						 delegate:self
																			 cancelButtonTitle:@"Cancel"
																			 otherButtonTitles:@"Undo", nil];
				[_undoConfirmationAlertView show];
			} else {
				[self undoTurnForLocalPlayer];
			}
		}
	}
}

-(void)undoTurnForLocalPlayer {
	_app.localPlayerUndoCount = _app.localPlayerUndoCount-1;
	[self undoTurnForPlayer:self.localPlayer];
}

-(void)undoTurnForPlayer:(NezAletterationPlayer*)player {
	__weak NezAletterationSinglePlayerGameViewController *myself = self;
	[player animateUndoWithFinishedBlock:^{
		[NezAnimator animateVec4WithFromData:player.currentLetterBlock.color ToData:player.gameBoard.color Duration:0.25 EasingFunction:easeInOutCubic UpdateBlock:^(NezAnimation *ani) {
			player.currentLetterBlock.color = (*(GLKVector4*)ani.newData);
		} DidStopBlock:^(NezAnimation *ani) {}];
		[myself moveCurrentLetterBlockForPlayer:player toDefaultPositionWithAnimationFinishedBlock:^{
			[player.gameBoard setupLetterBlocksForGameState:player.gameState isAnimated:YES];
		}];
	}];
}

@end
