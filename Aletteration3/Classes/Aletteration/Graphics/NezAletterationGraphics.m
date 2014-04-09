//
//  NezAletterationGraphics.m
//  Aletteration3
//
//  Created by David Nesbitt on 2013-09-21.
//  Copyright (c) 2013 David Nesbitt. All rights reserved.
//

#import <GLKit/GLKit.h>
#import <mach/mach_time.h>

#import "NezAletterationAppDelegate.h"
#import "NezAletterationGraphics.h"
#import "NezSimpleObjLoader.h"
#import "NezGLSLCompiler.h"
#import "NezGLSLProgram.h"
#import "NezGLCamera.h"
#import "NezAnimator.h"
#import "NezAletterationGameTable.h"
#import "NezAletterationGameBoard.h"
#import "NezAletterationBox.h"
#import "NezAletterationLetterBox.h"
#import "NezAletterationWordLine.h"
#import "NezAletterationLetterBlock.h"
#import "NezAletterationLetterStackLabel.h"
#import "NezAletterationGameState.h"
#import "NezGLFrameBufferObject.h"
#import "NezMaterials.h"
#import "NezInstanceVertexArrayObjectLitColor.h"
#import "NezVertexBufferObjectLitVertex.h"
#import "NezInstanceAttributeBufferObjectColor.h"
#import "NezInstanceVertexArrayObjectLitColorTexture.h"
#import "NezVertexBufferObjectLitInstanceTextureVertex.h"
#import "NezInstanceAttributeBufferObjectColorTexture.h"
#import "NezInstanceVertexArrayObjectColor.h"
#import "NezVertexBufferObjectVertex.h"
#import "NezInstanceAttributeBufferObjectColor.h"
#import "NezInstanceVertexArrayObjectTexture.h"
#import "NezVertexBufferObjectInstanceTextureVertex.h"
#import "NezInstanceAttributeBufferObjectTexture.h"
#import "NezInstanceVertexArrayObjectColorTexture.h"
#import "NezInstanceVertexArrayObjectLitTextureColor.h"
#import "NezVertexBufferObjectLitTextureVertex.h"
#import "NezVertexArrayObjectTexture.h"
#import "NezInstanceVertexArrayObjectLitColorTintTexture.h"
#import "NezInstanceAttributeBufferObjectColorTintTexture.h"
#import "NezVertexBufferObjectTextureVertex.h"
#import "NezAletterationSaveGame.h"
#import "NezRestorable.h"
#import "NezRandom.h"

#import "NezVertexArrayObjectParticleEmitter.h"
#import "NezVertexArrayObjectAcceleratingParticleEmitter.h"
#import "NezVertexBufferObjectParticleVertex.h"
#import "NezInstanceAttributeBufferObjectGeometryParticle.h"
#import "NezVertexArrayObjectGeometryEmitter.h"
#import "NezVertexArrayObjectTexturedGeometryEmitter.h"

#import "NezAletterationTextureBlock.h"

#define NEZ_ALETTERATION_MAX_PLAYER_COUNT 4

@interface NezAletterationGraphics () {
	NSDictionary *_textureInfoDict;
	NSMutableArray *_vertexArrayList;

	NSDictionary *_vertexShaderDict;
	NSDictionary *_fragmentShaderDict;
	
	NezInstanceVertexArrayObjectLitColor *_letterBlockBackVertexArrayObject;
	NezInstanceVertexArrayObjectLitColorTintTexture *_letterBlockFrontVertexArrayObject;
	NezInstanceVertexArrayObjectColor *_wordLineVertexArrayObject;
	NezInstanceVertexArrayObjectColorTexture *_labelVertexArrayObject;
	NezInstanceVertexArrayObjectLitColor *_gameTableVertexArrayObject;
	NezInstanceVertexArrayObjectLitColor *_bigBoxVertexArrayObject;
	NezInstanceVertexArrayObjectLitTextureColor *_bigBoxLidVertexArrayObject;
	NezInstanceVertexArrayObjectLitTextureColor *_smallBoxVertexArrayObject;
	NezInstanceVertexArrayObjectLitTextureColor *_smallBoxLidVertexArrayObject;
	
	NezVertexArrayObjectTexture *_congratulationWordsVertexArrayObject;
	NezAletterationTextureBlock *_congratulationWordTextureBlock;
	
	NSMutableArray *_emitterList;

	NSMutableArray *_starEmitterList;
	NSInteger _currentStarEmitterIndex;
	
	NSMutableArray *_pointLineEmitterList;
	NSInteger _currentPointLineEmitterIndex;
	
	NSMutableArray *_geometryStarEmitterList;
	NSInteger _currentGeometryStarEmitterIndex;
	
	NSMutableArray *_scoreRaysEmitterList;
	NSInteger _currentScoreRaysEmitterIndex;
	
	NezGLCamera *_drawingViewCamera;
	NezGLCamera *_camera;
	NezGLCamera *_light;
	
	BOOL _loadingComplete;
	BOOL _loadingStarted;

	double _ticksToSecondsRatio;
	NSTimeInterval _lastUpdateTimeStamp;
	NSTimeInterval _currentUpdateTimeStamp;
	BOOL _paused;
	
	BOOL _depthTest;

	__weak NezAletterationAppDelegate *_app;
	
	CGRect _viewport;
	BOOL _viewportChanged;
}

@property (readonly, getter = getTimestamp) double timestamp;

@end

@implementation NezAletterationGraphics

+(float)getLuma:(GLKVector4)color {
	return ((color.r * 299.0) + (color.g * 587.0) + (color.b * 114.0)) / 1000.0;
}

-(double)getTimestamp {
	uint64_t timeStampInTicks = mach_absolute_time();
	return (double)timeStampInTicks*_ticksToSecondsRatio;
}

-(instancetype)init {
	if ((self = [super init])) {
		_loadingStarted = NO;
		_loadingComplete = NO;
		_vertexArrayList = [NSMutableArray array];

		_camera = [[NezGLCamera alloc] initWithEye:GLKVector3Make(0.0f, 0.0f, 0.0f) Target:GLKVector3Make(0.0f, 0.0f, 0.0f) UpVector:GLKVector3Make(0.0f, 1.0f, 0.0f)];
		_light = [[NezGLCamera alloc] initWithEye:GLKVector3Make(6.0f, 6.0f, 6.0f) Target:GLKVector3Make(0.0f, 0.0f, 0.0f) UpVector:GLKVector3Make(0.0f, 0.0f, 1.0f)];
		_drawingViewCamera = _camera;
		
		mach_timebase_info_data_t timebase;
		mach_timebase_info(&timebase);
		_ticksToSecondsRatio = ((double)timebase.numer/(double)timebase.denom)/1000000000.0;
		_paused = NO;
		
		_currentUpdateTimeStamp = self.timestamp;
		_lastUpdateTimeStamp = _currentUpdateTimeStamp;
		
		_app = [NezAletterationAppDelegate sharedAppDelegate];
		self.viewport = _app.currentFrame;
	}
	return self;
}

-(void)encodeRestorableStateWithCoder:(NSCoder*)coder {
	NSLog(@"NezAletterationGraphics encodeRestorableStateWithCoder");
	GLKVector3 sizeArray[2] = {_letterBlockDimensions, _wordLineDimensions};
	NSData *sizeData = [NSData dataWithBytes:sizeArray length:sizeof(sizeArray)];
	[coder encodeObject:sizeData forKey:@"_letterBlockDimensions,_wordLineDimensions"];
	
	[coder encodeObject:_camera forKey:@"_camera"];
	[coder encodeObject:_light forKey:@"_light"];
	[coder encodeObject:_drawingViewCamera forKey:@"_drawingViewCamera"];
	
	[coder encodeObject:_gameTable forKey:@"_gameTable"];
	
	[coder encodeObject:_gameTableVertexArrayObject forKey:@"_gameTableVertexArrayObject"];
	[coder encodeObject:_wordLineVertexArrayObject forKey:@"_wordLineVertexArrayObject"];
	[coder encodeObject:_labelVertexArrayObject forKey:@"_labelVertexArrayObject"];
	[coder encodeObject:_bigBoxLidVertexArrayObject forKey:@"_bigBoxLidVertexArrayObject"];
	[coder encodeObject:_bigBoxVertexArrayObject forKey:@"_bigBoxVertexArrayObject"];
	[coder encodeObject:_smallBoxLidVertexArrayObject forKey:@"_smallBoxLidVertexArrayObject"];
	[coder encodeObject:_smallBoxVertexArrayObject forKey:@"_smallBoxVertexArrayObject"];
	[coder encodeObject:_letterBlockFrontVertexArrayObject forKey:@"_letterBlockFrontVertexArrayObject"];
	[coder encodeObject:_letterBlockBackVertexArrayObject forKey:@"_letterBlockBackVertexArrayObject"];
}

-(void)decodeRestorableStateWithCoder:(NSCoder*)coder {
	NSLog(@"NezAletterationGraphics decodeRestorableStateWithCoder");
	NSData *sizeData = [coder decodeObjectForKey:@"_letterBlockDimensions,_wordLineDimensions"];
	GLKVector3 *sizeArray = (GLKVector3*)sizeData.bytes;
	_letterBlockDimensions = sizeArray[0];
	_wordLineDimensions = sizeArray[1];
	
	_camera = [coder decodeObjectForKey:@"_camera"];
	_light = [coder decodeObjectForKey:@"_light"];
	_drawingViewCamera = [coder decodeObjectForKey:@"_drawingViewCamera"];
	
	_gameTable = [coder decodeObjectForKey:@"_gameTable"];
	
	_gameTableVertexArrayObject = [coder decodeObjectForKey:@"_gameTableVertexArrayObject"];
	_wordLineVertexArrayObject = [coder decodeObjectForKey:@"_wordLineVertexArrayObject"];
	_labelVertexArrayObject = [coder decodeObjectForKey:@"_labelVertexArrayObject"];
	_bigBoxLidVertexArrayObject = [coder decodeObjectForKey:@"_bigBoxLidVertexArrayObject"];
	_bigBoxVertexArrayObject = [coder decodeObjectForKey:@"_bigBoxVertexArrayObject"];
	_smallBoxLidVertexArrayObject = [coder decodeObjectForKey:@"_smallBoxLidVertexArrayObject"];
	_smallBoxVertexArrayObject = [coder decodeObjectForKey:@"_smallBoxVertexArrayObject"];
	_letterBlockFrontVertexArrayObject = [coder decodeObjectForKey:@"_letterBlockFrontVertexArrayObject"];
	_letterBlockBackVertexArrayObject = [coder decodeObjectForKey:@"_letterBlockBackVertexArrayObject"];
}

-(void)applicationFinishedRestoringState {
	[self loadWithLoadGameTableFlag:NO];
}

-(void)registerChildObjectsForStateRestoration {
	[super registerChildObjectsForStateRestoration];

	[self registerChildObject:_camera withRestorationIdentifier:@"_camera"];
	[self registerChildObject:_light withRestorationIdentifier:@"_light"];
	[self registerChildObject:_gameTableVertexArrayObject withRestorationIdentifier:@"_gameTableVertexArrayObject"];
	[self registerChildObject:_wordLineVertexArrayObject withRestorationIdentifier:@"_wordLineVertexArrayObject"];
	[self registerChildObject:_labelVertexArrayObject withRestorationIdentifier:@"_labelVertexArrayObject"];
	[self registerChildObject:_bigBoxLidVertexArrayObject withRestorationIdentifier:@"_bigBoxLidVertexArrayObject"];
	[self registerChildObject:_bigBoxVertexArrayObject withRestorationIdentifier:@"_bigBoxVertexArrayObject"];
	[self registerChildObject:_smallBoxLidVertexArrayObject withRestorationIdentifier:@"_smallBoxLidVertexArrayObject"];
	[self registerChildObject:_smallBoxVertexArrayObject withRestorationIdentifier:@"_smallBoxVertexArrayObject"];
	[self registerChildObject:_letterBlockFrontVertexArrayObject withRestorationIdentifier:@"_letterBlockFrontVertexArrayObject"];
	[self registerChildObject:_letterBlockBackVertexArrayObject withRestorationIdentifier:@"_letterBlockBackVertexArrayObject"];
	[self registerChildObject:_gameTable withRestorationIdentifier:@"_gameTable"];
}

-(NSTimeInterval)getTimeSinceLastUpdate {
	return _currentUpdateTimeStamp-_lastUpdateTimeStamp;
}

-(BOOL)isPaused {
	return _paused;
}

-(void)setPaused:(BOOL)paused {
	if (!paused) {
		_currentUpdateTimeStamp = self.timestamp;
		_lastUpdateTimeStamp = _currentUpdateTimeStamp;
	}
	_paused = paused;
}

-(void)update {
	_currentUpdateTimeStamp = self.timestamp;
	[NezAnimator updateWithTimeSinceLastUpdate:self.timeSinceLastUpdate];
	[self updateEmitterVertexArrayData];
	[self updateVertexArrayData];
	_lastUpdateTimeStamp = _currentUpdateTimeStamp;
}

-(void)updateEmitterVertexArrayData {
	for (NezVertexArrayObjectParticleEmitter *emitter in _emitterList) {
		if (!emitter.isDead) {
			emitter.time += self.timeSinceLastUpdate;
		}
	}
}

-(void)updateVertexArrayData {
	for (NezInstanceVertexArrayObject *vao in _vertexArrayList) {
		[vao.instanceAttributeBufferObject fillInstanceData];
	}
}

-(CGRect)getViewport {
	return _viewport;
}

-(void)setViewport:(CGRect)viewport {
	_viewport = viewport;
	_viewportChanged = YES;
	[_camera setDefaultPerspectiveProjectionWithViewport:viewport];
	[_light setDefaultPerspectiveProjectionWithViewport:viewport];
}

-(void)draw {
	if (_viewportChanged) {
		CGRect viewport = CGRectApplyAffineTransform(_viewport, CGAffineTransformMakeScale(_app.scaleFactor, _app.scaleFactor));
		glViewport(viewport.origin.x, viewport.origin.y, viewport.size.width, viewport.size.height);
		_viewportChanged = NO;
	}
	glClearColor(0.65f, 0.65f, 0.65f, 1.0f);
	glClear(GL_COLOR_BUFFER_BIT | GL_DEPTH_BUFFER_BIT);
	if (_loadingComplete) {
		for (NezVertexArrayObject *vertexArray in _vertexArrayList) {
			if (vertexArray.depthTest != _depthTest) {
				_depthTest = vertexArray.depthTest;
				if (_depthTest) {
					glEnable(GL_DEPTH_TEST);
				} else {
					glDisable(GL_DEPTH_TEST);
				}
			}
			[vertexArray drawWithGraphics:self];
		}
		_depthTest = YES;
		glEnable(GL_DEPTH_TEST);
		glDepthMask(GL_FALSE);
		for (NezVertexArrayObjectParticleEmitter *emitter in _emitterList) {
			if (!emitter.isDead) {
				[emitter drawWithGraphics:self];
			}
		}
		glDepthMask(GL_TRUE);
	}
}

-(void)load {
	@synchronized (self) {
		if (!_loadingStarted) {
			[self loadWithLoadGameTableFlag:YES];
		}
	}
}

-(void)loadWithLoadGameTableFlag:(BOOL)needsToLoadTable {
	if (!_loadingStarted) {
		_loadingStarted = YES;
		
		[self loadCompilers];
		[self loadTextures];

		if (needsToLoadTable) {
			[self loadGameTableWithPlayerCount:NEZ_ALETTERATION_MAX_PLAYER_COUNT];
			[self registerChildObjectsForStateRestoration];
		}
		[self addVertexArraysToDrawList];
		[self deleteCompilers];
		
		_loadingComplete = YES;
	}
}

-(NezGLCamera*)getDrawingViewCamera {
	return _drawingViewCamera;
}

-(void)setDrawingViewCamera:(NezGLCamera*)camera {
	if (camera == nil) {
		_drawingViewCamera = _camera;
	} else {
		_drawingViewCamera = camera;
	}
}

-(NezGLCamera*)getCamera {
	return _camera;
}

-(NezGLCamera*)getLight {
	return _light;
}

-(GLKVector4)getLightDirection {
	return GLKVector4MakeWithVector3(GLKVector3Negate(_light.direction), 0.0f);
}

-(NezGLSLProgram*)loadProgramWithShader:(NSString*)shaderName {
	return [self loadProgramWithVertexShader:shaderName andFragmentShader:shaderName];
}

-(NezGLSLProgram*)loadProgramWithVertexShader:(NSString*)vertexShaderName andFragmentShader:(NSString*)fragmentShaderName {
	NezGLSLCompiler *vertexShader = _vertexShaderDict[vertexShaderName];
	NezGLSLCompiler *fragmentShader = _vertexShaderDict[fragmentShaderName];
	if (vertexShader && fragmentShader) {
		return [[NezGLSLProgram alloc] initWithVertexShaderCompiler:vertexShader andFragmentShaderCompiler:fragmentShader];
	} else {
		return nil;
	}
}

-(void)loadCompilers {
	_vertexShaderDict = @{
		@"Texture":[[NezGLSLCompiler alloc] initWithVertexShader:@"Texture"],
		@"ColorTexture":[[NezGLSLCompiler alloc] initWithVertexShader:@"ColorTexture"],
		@"TransparentColor":[[NezGLSLCompiler alloc] initWithVertexShader:@"TransparentColor"],
		@"LitColorPerPixel":[[NezGLSLCompiler alloc] initWithVertexShader:@"LitColorPerPixel"],
		@"LitColorTexturePerPixel":[[NezGLSLCompiler alloc] initWithVertexShader:@"LitColorTexturePerPixel"],
		@"LitColorTintTexturePerPixel":[[NezGLSLCompiler alloc] initWithVertexShader:@"LitColorTintTexturePerPixel"],
		@"LitTextureColorPerPixel":[[NezGLSLCompiler alloc] initWithVertexShader:@"LitTextureColorPerPixel"],
		@"LitTexturePerPixel":[[NezGLSLCompiler alloc] initWithVertexShader:@"LitTexturePerPixel"],
		@"FullScreenQuad":[[NezGLSLCompiler alloc] initWithVertexShader:@"FullScreenQuad"],
		@"Color":[[NezGLSLCompiler alloc] initWithVertexShader:@"Color"],
		@"PointSpriteEmitter":[[NezGLSLCompiler alloc] initWithVertexShader:@"PointSpriteEmitter"],
		@"PointLineEmitter":[[NezGLSLCompiler alloc] initWithVertexShader:@"PointLineEmitter"],
		@"GeometryEmitter":[[NezGLSLCompiler alloc] initWithVertexShader:@"GeometryEmitter"],
		@"GeometryEmitterTextured":[[NezGLSLCompiler alloc] initWithVertexShader:@"GeometryEmitterTextured"],
	};

	_fragmentShaderDict = @{
		@"Texture":[[NezGLSLCompiler alloc] initWithFragmentShader:@"Texture"],
		@"ColorTexture":[[NezGLSLCompiler alloc] initWithFragmentShader:@"ColorTexture"],
		@"TransparentColor":[[NezGLSLCompiler alloc] initWithFragmentShader:@"TransparentColor"],
		@"LitColorPerPixel":[[NezGLSLCompiler alloc] initWithFragmentShader:@"LitColorPerPixel"],
		@"LitColorTexturePerPixel":[[NezGLSLCompiler alloc] initWithFragmentShader:@"LitColorTexturePerPixel"],
		@"LitColorTintTexturePerPixel":[[NezGLSLCompiler alloc] initWithFragmentShader:@"LitColorTintTexturePerPixel"],
		@"LitTextureColorPerPixel":[[NezGLSLCompiler alloc] initWithFragmentShader:@"LitTextureColorPerPixel"],
		@"LitTexturePerPixel":[[NezGLSLCompiler alloc] initWithFragmentShader:@"LitTexturePerPixel"],
		@"BlurVertical":[[NezGLSLCompiler alloc] initWithFragmentShader:@"BlurVertical"],
		@"BlurHorizontal":[[NezGLSLCompiler alloc] initWithFragmentShader:@"BlurHorizontal"],
		@"BlendAdditive":[[NezGLSLCompiler alloc] initWithFragmentShader:@"BlendAdditive"],
		@"BlendScreen":[[NezGLSLCompiler alloc] initWithFragmentShader:@"BlendScreen"],
		@"BlitTexture":[[NezGLSLCompiler alloc] initWithFragmentShader:@"BlitTexture"],
		@"Color":[[NezGLSLCompiler alloc] initWithFragmentShader:@"Color"],
		@"PointSpriteEmitter":[[NezGLSLCompiler alloc] initWithFragmentShader:@"PointSpriteEmitter"],
		@"PointLineEmitter":[[NezGLSLCompiler alloc] initWithFragmentShader:@"PointLineEmitter"],
		@"GeometryEmitter":[[NezGLSLCompiler alloc] initWithFragmentShader:@"GeometryEmitter"],
		@"GeometryEmitterTextured":[[NezGLSLCompiler alloc] initWithFragmentShader:@"GeometryEmitterTextured"],
	};
}

-(void)deleteCompilers {
	_vertexShaderDict = nil;
	_fragmentShaderDict = nil;
}

-(void)loadTextures {
	_textureInfoDict = @{
		@"Box":     [self loadTexture:@"Box"],
		@"Congratulations": [self loadTexture:@"Congratulations"],
		@"Letters": [self loadTexture:@"Letters"],
		@"Numbers": [self loadTexture:@"Numbers"],
		@"BigBox": [self loadTexture:@"BigBox"],
		@"Star": [self loadTexture:@"PointSprites/Star"],
		@"Radial": [self loadTexture:@"PointSprites/Radial"],
	};
}

-(GLKTextureInfo*)loadTexture:(NSString*)textureDirectory {
	NSError *error = nil;   // stores the error message if we mess up
	NSDictionary *options = @{GLKTextureLoaderGenerateMipmaps: @YES};
	
	NSString *bundlepath = [[NSBundle mainBundle] pathForResource:@"00" ofType:@"png" inDirectory:[NSString stringWithFormat:@"Textures/%@", textureDirectory]];
	GLKTextureInfo *textureInfo = [GLKTextureLoader textureWithContentsOfFile:bundlepath options:options error:&error];
	if (error) {
		NSLog(@"%@", error.localizedDescription);
	}
	return textureInfo;
}

-(void)addVertexArraysToDrawList {
	if (_gameTableVertexArrayObject) {
		_gameTableVertexArrayObject.program = [[NezGLSLProgram alloc] initWithVertexShaderCompiler:_vertexShaderDict[@"LitColorTexturePerPixel"] andFragmentShaderCompiler:_fragmentShaderDict[@"LitColorTexturePerPixel"]];
		_gameTableVertexArrayObject.depthTest = NO;
		[_vertexArrayList addObject:_gameTableVertexArrayObject];
	}
	if (_wordLineVertexArrayObject) {
		_wordLineVertexArrayObject.program = [[NezGLSLProgram alloc] initWithVertexShaderCompiler:_vertexShaderDict[@"TransparentColor"] andFragmentShaderCompiler:_fragmentShaderDict[@"TransparentColor"]];
		_wordLineVertexArrayObject.depthTest = NO;
		[_vertexArrayList addObject:_wordLineVertexArrayObject];
	}
	if (_labelVertexArrayObject) {
		_labelVertexArrayObject.program = [[NezGLSLProgram alloc] initWithVertexShaderCompiler:_vertexShaderDict[@"ColorTexture"] andFragmentShaderCompiler:_fragmentShaderDict[@"ColorTexture"]];
		_labelVertexArrayObject.textureInfo = _textureInfoDict[@"Numbers"];
		_labelVertexArrayObject.depthTest = NO;
		[_vertexArrayList addObject:_labelVertexArrayObject];
	}
	if (_bigBoxLidVertexArrayObject) {
		_bigBoxLidVertexArrayObject.program = [[NezGLSLProgram alloc] initWithVertexShaderCompiler:_vertexShaderDict[@"LitTexturePerPixel"] andFragmentShaderCompiler:_fragmentShaderDict[@"LitTexturePerPixel"]];
		_bigBoxLidVertexArrayObject.material = [NezMaterials materialForName:@"BigBoxLid"];
		_bigBoxLidVertexArrayObject.textureInfo = _textureInfoDict[@"BigBox"];
		_bigBoxLidVertexArrayObject.depthTest = YES;
		[_vertexArrayList addObject:_bigBoxLidVertexArrayObject];
	}
	if (_bigBoxVertexArrayObject) {
		_bigBoxVertexArrayObject.program = [[NezGLSLProgram alloc] initWithVertexShaderCompiler:_vertexShaderDict[@"LitColorPerPixel"] andFragmentShaderCompiler:_fragmentShaderDict[@"LitColorPerPixel"]];
		_bigBoxVertexArrayObject.material = [NezMaterials materialForName:@"BigBox"];
		_bigBoxVertexArrayObject.depthTest = YES;
		[_vertexArrayList addObject:_bigBoxVertexArrayObject];
	}
	if (_smallBoxLidVertexArrayObject) {
		_smallBoxLidVertexArrayObject.program = [[NezGLSLProgram alloc] initWithVertexShaderCompiler:_vertexShaderDict[@"LitTextureColorPerPixel"] andFragmentShaderCompiler:_fragmentShaderDict[@"LitTextureColorPerPixel"]];
		_smallBoxLidVertexArrayObject.material = [NezMaterials materialForName:@"SmallBoxLid"];
		_smallBoxLidVertexArrayObject.textureInfo = _textureInfoDict[@"Box"];
		_smallBoxLidVertexArrayObject.depthTest = YES;
		[_vertexArrayList addObject:_smallBoxLidVertexArrayObject];
	}
	if (_smallBoxVertexArrayObject) {
		_smallBoxVertexArrayObject.program = [[NezGLSLProgram alloc] initWithVertexShaderCompiler:_vertexShaderDict[@"LitTextureColorPerPixel"] andFragmentShaderCompiler:_fragmentShaderDict[@"LitTextureColorPerPixel"]];
		_smallBoxVertexArrayObject.material = [NezMaterials materialForName:@"SmallBox"];
		_smallBoxVertexArrayObject.textureInfo = _textureInfoDict[@"Box"];
		_smallBoxVertexArrayObject.depthTest = YES;
		[_vertexArrayList addObject:_smallBoxVertexArrayObject];
	}
	if (_letterBlockFrontVertexArrayObject) {
		_letterBlockFrontVertexArrayObject.program = [[NezGLSLProgram alloc] initWithVertexShaderCompiler:_vertexShaderDict[@"LitColorTintTexturePerPixel"] andFragmentShaderCompiler:_fragmentShaderDict[@"LitColorTintTexturePerPixel"]];
		_letterBlockFrontVertexArrayObject.material = [NezMaterials materialForName:@"LetterBlock"];
		_letterBlockFrontVertexArrayObject.textureInfo = _textureInfoDict[@"Letters"];
		_letterBlockFrontVertexArrayObject.depthTest = YES;
		[_vertexArrayList addObject:_letterBlockFrontVertexArrayObject];
	}
	if (_letterBlockBackVertexArrayObject) {
		_letterBlockBackVertexArrayObject.program = [[NezGLSLProgram alloc] initWithVertexShaderCompiler:_vertexShaderDict[@"LitColorPerPixel"] andFragmentShaderCompiler:_fragmentShaderDict[@"LitColorPerPixel"]];
		_letterBlockBackVertexArrayObject.material = [NezMaterials materialForName:@"LetterBlock"];
		_letterBlockBackVertexArrayObject.depthTest = YES;
		[_vertexArrayList addObject:_letterBlockBackVertexArrayObject];
	}
	if (_starEmitterList) {
		for (NezVertexArrayObjectAcceleratingParticleEmitter *emitter in _starEmitterList) {
			emitter.program = [[NezGLSLProgram alloc] initWithVertexShaderCompiler:_vertexShaderDict[@"PointSpriteEmitter"] andFragmentShaderCompiler:_fragmentShaderDict[@"PointSpriteEmitter"]];
			emitter.textureInfo = _textureInfoDict[@"Star"];
			emitter.depthTest = YES;
			[_emitterList addObject:emitter];
		}
	}
	if (_pointLineEmitterList) {
		for (NezVertexArrayObjectParticleEmitter *emitter in _pointLineEmitterList) {
			emitter.program = [[NezGLSLProgram alloc] initWithVertexShaderCompiler:_vertexShaderDict[@"PointLineEmitter"] andFragmentShaderCompiler:_fragmentShaderDict[@"PointLineEmitter"]];
			emitter.textureInfo = _textureInfoDict[@"Radial"];
			emitter.depthTest = YES;
			[_emitterList addObject:emitter];
		}
	}
	if (_geometryStarEmitterList) {
		for (NezVertexArrayObjectGeometryEmitter *emitter in _geometryStarEmitterList) {
			emitter.program = [[NezGLSLProgram alloc] initWithVertexShaderCompiler:_vertexShaderDict[@"GeometryEmitter"] andFragmentShaderCompiler:_fragmentShaderDict[@"GeometryEmitter"]];
			emitter.depthTest = YES;
			[_emitterList addObject:emitter];
		}
	}
	if (_scoreRaysEmitterList) {
		for (NezVertexArrayObjectTexturedGeometryEmitter *emitter in _scoreRaysEmitterList) {
			emitter.program = [[NezGLSLProgram alloc] initWithVertexShaderCompiler:_vertexShaderDict[@"GeometryEmitterTextured"] andFragmentShaderCompiler:_fragmentShaderDict[@"GeometryEmitterTextured"]];
			emitter.textureInfo = _textureInfoDict[@"Radial"];
			emitter.depthTest = YES;
			[_emitterList addObject:emitter];
		}
	}
	if (_congratulationWordsVertexArrayObject) {
//		_congratulationWordsVertexArrayObject.program = [[NezGLSLProgram alloc] initWithVertexShaderCompiler:_vertexShaderDict[@"Texture"] andFragmentShaderCompiler:_fragmentShaderDict[@"Texture"]];
//		_congratulationWordsVertexArrayObject.textureInfo = _textureInfoDict[@"Congratulations"];
//		_congratulationWordsVertexArrayObject.depthTest = NO;
//		[_vertexArrayList addObject:_congratulationWordsVertexArrayObject];
	}
}

-(void)loadGameTableWithPlayerCount:(int)playerCount {
	NSMutableArray *gameBoardList = [self loadGameBoardWithPlayerCount:playerCount];
	
	if (!_gameTableVertexArrayObject) {
		NezSimpleObjLoader *unitSquare = [[NezSimpleObjLoader alloc] initWithFile:@"unitSquare" Type:@"obj" Dir:@"Models"];
		[unitSquare scaleVertices:GLKMatrix3MakeScale(500.0f, 500.0f, 1.0f)];
		
		NezVertexBufferObjectLitVertex *tableVertexBufferObject = [[NezVertexBufferObjectLitVertex alloc] initWithObjVertexArray:unitSquare.vertexArray];
		NezInstanceAttributeBufferObjectColor *tableInstanceAttributeBufferObject = [[NezInstanceAttributeBufferObjectColor alloc] initWithInstanceCount:1];
		_gameTableVertexArrayObject = [[NezInstanceVertexArrayObjectLitColor alloc] initWithVertexBufferObject:tableVertexBufferObject andInstanceAttributeBufferObject:tableInstanceAttributeBufferObject];
		_gameTableVertexArrayObject.vertexBufferObject.dimensions = unitSquare.size;
	}
	NezAletterationBox *bigBox = [self loadBigBox];
	_gameTable = [[NezAletterationGameTable alloc] initWithGameBoardList:gameBoardList instanceVao:_gameTableVertexArrayObject andBox:bigBox];
	_gameTable.color = GLKVector4Make(1.0f, 0.0f, 0.0f, 1.0f);
		
	_gameTable.modelMatrix = GLKMatrix4Identity;
	
	[self loadCongratulationWords];
	[self loadParticleEmitters];
}

-(NSMutableArray*)loadGameBoardWithPlayerCount:(int)playerCount {
	NSMutableArray *letterBlockList = [self loadLetterBlocksWithPlayerCount:playerCount];
	NSMutableArray *letterBoxList = [self loadLetterBoxesWithPlayerCount:playerCount];
	NSMutableArray *stackLabelList = [self loadStackLabelsWithPlayerCount:playerCount];
	NSMutableArray *wordLineList = [self loadWordLinesWithPlayerCount:playerCount];
	
	int letterCount = [NezAletterationGameState letterCount];
	NSMutableArray *gameBoardList = [NSMutableArray arrayWithCapacity:playerCount];
	for (int i=0; i<playerCount; i++) {
		NSArray *letterList =[letterBlockList subarrayWithRange:NSMakeRange(i*letterCount, letterCount)];
		NSArray *lineList =[wordLineList subarrayWithRange:NSMakeRange(i*NEZ_ALETTERATION_LINE_COUNT, NEZ_ALETTERATION_LINE_COUNT)];
		NSArray *labelList =[stackLabelList subarrayWithRange:NSMakeRange(i*NEZ_ALETTERATION_ALPHABET_COUNT, NEZ_ALETTERATION_ALPHABET_COUNT)];
		NezAletterationGameBoard *gameboard = [[NezAletterationGameBoard alloc] initWithLetterBox:letterBoxList[i] blockList:letterList lineList:lineList andLabelList:labelList];
		[gameBoardList addObject:gameboard];
	}
	return gameBoardList;
}

-(NezAletterationBox*)loadBigBox {
	NezSimpleObjLoader *bigBoxObj = [[NezSimpleObjLoader alloc] initWithFile:@"bigbox" Type:@"obj" Dir:@"Models"];

	if (!_bigBoxVertexArrayObject) {
		NezSimpleObjLoader *boxObj = [bigBoxObj makeObjLoaderForGroupNameList:@[@"BigBox"]];
		[boxObj scaleVerticesWithUniformScaleFactor:1.025];
		NezVertexBufferObjectLitVertex *boxVertexBufferObject = [[NezVertexBufferObjectLitVertex alloc] initWithObjVertexArray:boxObj.vertexArray];
		NezInstanceAttributeBufferObjectColor *boxInstanceAttributeBufferObject = [[NezInstanceAttributeBufferObjectColor alloc] initWithInstanceCount:1];
		_bigBoxVertexArrayObject = [[NezInstanceVertexArrayObjectLitColor alloc] initWithVertexBufferObject:boxVertexBufferObject andInstanceAttributeBufferObject:boxInstanceAttributeBufferObject];
		_bigBoxVertexArrayObject.vertexBufferObject.dimensions = boxObj.size;
	}
	if (!_bigBoxLidVertexArrayObject) {
		NezSimpleObjLoader *lidObj = [bigBoxObj makeObjLoaderForGroupNameList:@[@"BigBoxLid"]];
		NezVertexBufferObjectLitTextureVertex *lidVertexBufferObject = [[NezVertexBufferObjectLitTextureVertex alloc] initWithObjVertexArray:lidObj.vertexArray];
		NezInstanceAttributeBufferObjectColor *lidInstanceAttributeBufferObject = [[NezInstanceAttributeBufferObjectColor alloc] initWithInstanceCount:1];
		_bigBoxLidVertexArrayObject = [[NezInstanceVertexArrayObjectLitTextureColor alloc] initWithVertexBufferObject:lidVertexBufferObject andInstanceAttributeBufferObject:lidInstanceAttributeBufferObject];
		_bigBoxLidVertexArrayObject.vertexBufferObject.dimensions = lidObj.size;
	}
	NezAletterationLid *lid = [[NezAletterationLid alloc] initWithInstanceAbo:_bigBoxLidVertexArrayObject.instanceAttributeBufferObject index:0 andDimensions:_bigBoxLidVertexArrayObject.vertexBufferObject.dimensions];
	NezAletterationBox *box = [[NezAletterationBox alloc] initWithLid:lid instanceAbo:_bigBoxVertexArrayObject.instanceAttributeBufferObject index:0 andDimensions:_bigBoxVertexArrayObject.vertexBufferObject.dimensions];
	box.color = GLKVector4Make(0.75f, 0.75f, 0.75f, 0.75f);
	return box;
}

-(NSMutableArray*)loadLetterBoxesWithPlayerCount:(int)playerCount {
	if (!_smallBoxVertexArrayObject) {
		NezSimpleObjLoader *boxObj = [[NezSimpleObjLoader alloc] initWithFile:@"box" Type:@"obj" Dir:@"Models"];
		NezVertexBufferObjectLitTextureVertex *boxVertexBufferObject = [[NezVertexBufferObjectLitTextureVertex alloc] initWithObjVertexArray:boxObj.vertexArray];
		NezInstanceAttributeBufferObjectColor *boxInstanceAttributeBufferObject = [[NezInstanceAttributeBufferObjectColor alloc] initWithInstanceCount:playerCount];
		_smallBoxVertexArrayObject = [[NezInstanceVertexArrayObjectLitTextureColor alloc] initWithVertexBufferObject:boxVertexBufferObject andInstanceAttributeBufferObject:boxInstanceAttributeBufferObject];
		_smallBoxVertexArrayObject.vertexBufferObject.dimensions = boxObj.size;
	}
	if (!_smallBoxLidVertexArrayObject) {
		NezSimpleObjLoader *lidObj = [[NezSimpleObjLoader alloc] initWithFile:@"lid" Type:@"obj" Dir:@"Models"];
		NezVertexBufferObjectLitTextureVertex *lidVertexBufferObject = [[NezVertexBufferObjectLitTextureVertex alloc] initWithObjVertexArray:lidObj.vertexArray];
		NezInstanceAttributeBufferObjectColor *lidInstanceAttributeBufferObject = [[NezInstanceAttributeBufferObjectColor alloc] initWithInstanceCount:playerCount];
		_smallBoxLidVertexArrayObject = [[NezInstanceVertexArrayObjectLitTextureColor alloc] initWithVertexBufferObject:lidVertexBufferObject andInstanceAttributeBufferObject:lidInstanceAttributeBufferObject];
		_smallBoxLidVertexArrayObject.vertexBufferObject.dimensions = lidObj.size;
	}
	NSMutableArray *letterBoxList = [NSMutableArray arrayWithCapacity:playerCount];

	for (NSInteger i=0; i<playerCount; i++) {
		NezAletterationLid *lid = [[NezAletterationLid alloc] initWithInstanceAbo:_smallBoxLidVertexArrayObject.instanceAttributeBufferObject index:i andDimensions:_smallBoxLidVertexArrayObject.vertexBufferObject.dimensions];
		NezAletterationBox *box = [[NezAletterationLetterBox alloc] initWithLid:lid instanceAbo:_smallBoxVertexArrayObject.instanceAttributeBufferObject index:i andDimensions:_smallBoxVertexArrayObject.vertexBufferObject.dimensions];
		box.color = GLKVector4Make(1.0f, 0.0f, 0.0f, 1.0f);
		
		[letterBoxList addObject:box];
	}
	return letterBoxList;
}

-(NSMutableArray*)loadLetterBlocksWithPlayerCount:(int)playerCount {
	int totalLetterBlockCount = [NezAletterationGameState letterCount]*playerCount;
	
	if (!_letterBlockFrontVertexArrayObject && !_letterBlockBackVertexArrayObject) {
		NezSimpleObjLoader *letterBlock = [[NezSimpleObjLoader alloc] initWithFile:@"block" Type:@"obj" Dir:@"Models"];
		_letterBlockDimensions = letterBlock.size;
		
		NezModelVertexArray *frontVertexArray = [letterBlock makeVertexArrayForGroupNameList:@[@"Front"]];
		NezVertexBufferObjectLitInstanceTextureVertex *frontVertexBufferObject = [[NezVertexBufferObjectLitInstanceTextureVertex alloc] initWithObjVertexArray:frontVertexArray];
		NezInstanceAttributeBufferObjectColorTintTexture *frontInstanceAttributeBufferObject = [[NezInstanceAttributeBufferObjectColorTintTexture alloc] initWithInstanceCount:totalLetterBlockCount];
		_letterBlockFrontVertexArrayObject = [[NezInstanceVertexArrayObjectLitColorTintTexture alloc] initWithVertexBufferObject:frontVertexBufferObject andInstanceAttributeBufferObject:frontInstanceAttributeBufferObject];

		NezModelVertexArray *backVertexArray = [letterBlock makeVertexArrayForGroupNameList:@[@"Back1", @"Back2"]];
		NezVertexBufferObjectLitVertex *backVertexBufferObject = [[NezVertexBufferObjectLitVertex alloc] initWithObjVertexArray:backVertexArray];
		NezInstanceAttributeBufferObjectColor *backInstanceAttributeBufferObject = [[NezInstanceAttributeBufferObjectColor alloc] initWithInstanceCount:totalLetterBlockCount];
		_letterBlockBackVertexArrayObject = [[NezInstanceVertexArrayObjectLitColor alloc] initWithVertexBufferObject:backVertexBufferObject andInstanceAttributeBufferObject:backInstanceAttributeBufferObject];
		_letterBlockBackVertexArrayObject.vertexBufferObject.dimensions = _letterBlockDimensions;
	}
	NSMutableArray *letterBlockList = [NSMutableArray arrayWithCapacity:totalLetterBlockCount];
	for (int i=0; i<totalLetterBlockCount; i++) {
		NezAletterationLetterBlock *letterBlock = [[NezAletterationLetterBlock alloc] initWithBlockVao:_letterBlockBackVertexArrayObject blockAttributeIndex:i letterVao:_letterBlockFrontVertexArrayObject letterAttributeIndex:i];
		[letterBlockList addObject:letterBlock];
	}
	NezAletterationLetterBag letterBag = [NezAletterationGameState fullLetterBag];
	int index = 0;
	for (int i=0;i<playerCount;i++) {
		for (int letterIndex=0;letterIndex<NEZ_ALETTERATION_ALPHABET_COUNT;letterIndex++) {
			for (int j=0; j<letterBag.count[letterIndex]; j++) {
				NezAletterationLetterBlock *letterBlock = letterBlockList[index++];
				letterBlock.letter = 'a'+letterIndex;
			}
		}
	}
	return letterBlockList;
}

-(NSMutableArray*)loadWordLinesWithPlayerCount:(int)playerCount {
	int totalLineCount = playerCount*NEZ_ALETTERATION_LINE_COUNT;
	
	if (!_wordLineVertexArrayObject) {
		NezSimpleObjLoader *unitSquare = [[NezSimpleObjLoader alloc] initWithFile:@"unitSquare" Type:@"obj" Dir:@"Models"];
		[unitSquare scaleVertices:GLKMatrix3MakeScale(_letterBlockDimensions.x*17.5f, _letterBlockDimensions.y, 1.0f)];
		_wordLineDimensions = unitSquare.size;
		
		NezVertexBufferObjectVertex *wordLineVertexBufferObject = [[NezVertexBufferObjectVertex alloc] initWithObjVertexArray:unitSquare.vertexArray];
		NezInstanceAttributeBufferObjectColor *wordLineInstanceAttributeBufferObject = [[NezInstanceAttributeBufferObjectColor alloc] initWithInstanceCount:totalLineCount];
		_wordLineVertexArrayObject = [[NezInstanceVertexArrayObjectColor alloc] initWithVertexBufferObject:wordLineVertexBufferObject andInstanceAttributeBufferObject:wordLineInstanceAttributeBufferObject];
		_wordLineVertexArrayObject.vertexBufferObject.dimensions = _wordLineDimensions;
	}
	NSMutableArray *wordLineList = [NSMutableArray arrayWithCapacity:totalLineCount];
	for (NSInteger i=0;i<totalLineCount;i++) {
		NezAletterationWordLine *line = [[NezAletterationWordLine alloc] initWithLineVao:_wordLineVertexArrayObject lineAttributeIndex:i];
		line.lineIndex = i%NEZ_ALETTERATION_LINE_COUNT;
		[wordLineList addObject:line];
	}
	return wordLineList;
}

-(NSMutableArray*)loadStackLabelsWithPlayerCount:(int)playerCount {
	int totalLabelCount = playerCount*NEZ_ALETTERATION_ALPHABET_COUNT;
	
	if (!_labelVertexArrayObject) {
		NezSimpleObjLoader *unitSquare = [[NezSimpleObjLoader alloc] initWithFile:@"unitSquare" Type:@"obj" Dir:@"Models"];
		[unitSquare scaleVertices:GLKMatrix3MakeScale(0.5f, 0.5f, 1.0f)];
		
		NezVertexBufferObjectInstanceTextureVertex *labelVertexBufferObject = [[NezVertexBufferObjectInstanceTextureVertex alloc] initWithObjVertexArray:unitSquare.vertexArray];
		NezInstanceAttributeBufferObjectColorTexture *labelInstanceAttributeBufferObject = [[NezInstanceAttributeBufferObjectColorTexture alloc] initWithInstanceCount:totalLabelCount];
		_labelVertexArrayObject = [[NezInstanceVertexArrayObjectColorTexture alloc] initWithVertexBufferObject:labelVertexBufferObject andInstanceAttributeBufferObject:labelInstanceAttributeBufferObject];
		_labelVertexArrayObject.vertexBufferObject.dimensions = unitSquare.size;
	}
	NSMutableArray *stackLabelList = [NSMutableArray arrayWithCapacity:totalLabelCount];
	for (NSInteger i=0;i<totalLabelCount;i++) {
		NezAletterationLetterStackLabel *label = [[NezAletterationLetterStackLabel alloc] initWithLabelVao:_labelVertexArrayObject labelAttributeIndex:i];
		label.color = GLKVector4Make(0.0, 0.0, 1.0, 1.0);
		[stackLabelList addObject:label];
	}
	return stackLabelList;
}

-(void)loadCongratulationWords {
	if (!_congratulationWordsVertexArrayObject) {
		NezSimpleObjLoader *square = [[NezSimpleObjLoader alloc] initWithFile:@"unitSquare" Type:@"obj" Dir:@"Models"];
		[square scaleVertices:GLKMatrix3MakeScale(8.0f, 1.0f, 1.0f)];
		
		NezVertexBufferObjectTextureVertex *vbo = [[NezVertexBufferObjectTextureVertex alloc] initWithObjVertexArray:square.vertexArray];
		_congratulationWordsVertexArrayObject = [[NezVertexArrayObjectTexture alloc] initWithVertexBufferObject:vbo];
		_congratulationWordsVertexArrayObject.vertexBufferObject.dimensions = square.size;
	}
	
	_congratulationWordTextureBlock = [[NezAletterationTextureBlock alloc] initWithVao:_congratulationWordsVertexArrayObject];
	_congratulationWordTextureBlock.modelMatrix = GLKMatrix4MakeTranslation(-100000.0f, -100000.0f, -100000.0f);
}

-(NezAletterationTextureBlock*)getCongratulationWord {
	return _congratulationWordTextureBlock;
}

-(void)loadParticleEmitters {
	_emitterList = [NSMutableArray array];
	
	[self loadStarParticleEmitters];
	[self loadPointLineEmitters];
	[self loadGeometryStarEmitters];
	[self loadScoreRayGeometryEmitter];
}

-(void)loadStarParticleEmitters {
	int totalEmitterCount = 64;
	int particleCount = 64;

	NezModelVertexArray *starVextexArray = [[NezModelVertexArray alloc] initWithVertexCount:particleCount andIndexCount:particleCount];
	
	_starEmitterList = [NSMutableArray arrayWithCapacity:totalEmitterCount];
	for (int i=0; i<totalEmitterCount; i++) {
		NezVertexBufferObjectParticleVertex *vbo = [[NezVertexBufferObjectParticleVertex alloc] initWithObjVertexArray:starVextexArray];
		NezVertexArrayObjectAcceleratingParticleEmitter *vao = [[NezVertexArrayObjectAcceleratingParticleEmitter alloc] initWithVertexBufferObject:vbo];
		[_starEmitterList addObject:vao];
	}
}

-(NezVertexArrayObjectAcceleratingParticleEmitter*)getNextStarEmitter {
	_currentStarEmitterIndex++;
	return _starEmitterList[(_currentStarEmitterIndex)%_starEmitterList.count];
}

-(void)loadPointLineEmitters {
	int totalEmitterCount = 16;
	int particleCount = 256;
	
	NezModelVertexArray *vextexArray = [[NezModelVertexArray alloc] initWithVertexCount:particleCount andIndexCount:particleCount];
	
	_pointLineEmitterList = [NSMutableArray arrayWithCapacity:totalEmitterCount];
	for (int i=0; i<totalEmitterCount; i++) {
		NezVertexBufferObjectParticleVertex *vbo = [[NezVertexBufferObjectParticleVertex alloc] initWithObjVertexArray:vextexArray];
		NezVertexArrayObjectParticleEmitter *vao = [[NezVertexArrayObjectParticleEmitter alloc] initWithVertexBufferObject:vbo];
		[_pointLineEmitterList addObject:vao];
	}
}

-(NezVertexArrayObjectParticleEmitter*)getNextPointLineEmitter {
	_currentPointLineEmitterIndex++;
	return _pointLineEmitterList[(_currentPointLineEmitterIndex)%_pointLineEmitterList.count];
}

-(void)loadGeometryStarEmitters {
	int totalEmitterCount = 32;
	int particleCount = 16;
	
	NezSimpleObjLoader *obj = [[NezSimpleObjLoader alloc] initWithFile:@"star2d" Type:@"obj" Dir:@"Models"];
	[obj scaleVertices:GLKMatrix3MakeScale(0.0005f, 0.0005f, 1.0f)];
		
	NezVertexBufferObjectLitVertex *vbo = [[NezVertexBufferObjectLitVertex alloc] initWithObjVertexArray:obj.vertexArray];
	_geometryStarEmitterList = [NSMutableArray arrayWithCapacity:totalEmitterCount];
	for (int i=0; i<totalEmitterCount; i++) {
		NezInstanceAttributeBufferObjectGeometryParticle *abo = [[NezInstanceAttributeBufferObjectGeometryParticle alloc] initWithInstanceCount:particleCount];
		NezVertexArrayObjectGeometryEmitter *vao = [[NezVertexArrayObjectGeometryEmitter alloc] initWithVertexBufferObject:vbo andInstanceAttributeBufferObject:abo];
		[_geometryStarEmitterList addObject:vao];
	}
}

-(NezVertexArrayObjectParticleEmitter*)getNextGeometryStarEmitter {
	_currentGeometryStarEmitterIndex++;
	return _geometryStarEmitterList[(_currentGeometryStarEmitterIndex)%_geometryStarEmitterList.count];
}

-(void)loadScoreRayGeometryEmitter {
	int totalEmitterCount = 16;
	int particleCount = 4;
	
	NezSimpleObjLoader *obj = [[NezSimpleObjLoader alloc] initWithFile:@"unitSquare" Type:@"obj" Dir:@"Models"];
	NezVertexBufferObjectLitTextureVertex *vbo = [[NezVertexBufferObjectLitTextureVertex alloc] initWithObjVertexArray:obj.vertexArray];
	
	_scoreRaysEmitterList = [NSMutableArray arrayWithCapacity:totalEmitterCount];
	for (int i=0; i<totalEmitterCount; i++) {
		NezInstanceAttributeBufferObjectGeometryParticle *abo = [[NezInstanceAttributeBufferObjectGeometryParticle alloc] initWithInstanceCount:particleCount];
		NezVertexArrayObjectTexturedGeometryEmitter *vao = [[NezVertexArrayObjectTexturedGeometryEmitter alloc] initWithVertexBufferObject:vbo andInstanceAttributeBufferObject:abo];
		[_scoreRaysEmitterList addObject:vao];
		
		NezInstanceAttributeGeometryParticle *instanceAttributeList = abo.instanceAttributeList;
		for (int i=0; i<particleCount; i++) {
			float angle = (2*M_PI)*((float)i/(float)particleCount);
			NezInstanceAttributeGeometryParticle *particle = instanceAttributeList+i;
			particle->scale = GLKVector3Make(2.0, 7.5, 1.0);
			particle->offset = GLKVector3Make(0.0, 0.0, 0.0);
			particle->color0 = GLKVector4Make(randomFloatInRange(0.15, 0.15), randomFloatInRange(0.15, 0.15), randomFloatInRange(0.15, 0.15), 1.0);
			particle->color1 = GLKVector4Make(0.0, 0.0, 0.0, 0.0);
			particle->orientation = GLKQuaternionMakeWithAngleAndAxis(angle, 0.0, 0.0, 1.0);
			particle->angularVelocity = GLKQuaternionMake(randomFloatInRange(-1.0, 2.0), randomFloatInRange(-1.0, 2.0), randomFloatInRange(-1.0, 2.0), 0.0);
			particle->uvScale = GLKVector2Make(1.0, 1.0);
		}
	}
}

-(NezVertexArrayObjectTexturedGeometryEmitter*)getNextScoreRaysEmitter {
	_currentScoreRaysEmitterIndex++;
	return _scoreRaysEmitterList[(_currentScoreRaysEmitterIndex)%_scoreRaysEmitterList.count];
}

@end








