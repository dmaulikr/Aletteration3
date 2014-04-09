//
//  NezAletterationGraphics.h
//  Aletteration3
//
//  Created by David Nesbitt on 2013-09-21.
//  Copyright (c) 2013 David Nesbitt. All rights reserved.
//

#include <GLKit/GLKit.h>
#import "NezRestorableObject.h"

@class NezGLCamera;
@class NezAletterationLetterBlock;
@class NezVertexArrayInstancedAbstract;
@class NezVertexArrayInstancedTextured;
@class NezAletterationGameTable;
@class NezAletterationGameBoard;
@class NezVertexArrayObjectParticleEmitter;
@class NezVertexArrayObjectAcceleratingParticleEmitter;
@class NezVertexArrayObjectGeometryEmitter;
@class NezVertexArrayObjectTexturedGeometryEmitter;
@class NezAletterationTextureBlock;

@interface NezAletterationGraphics : NezRestorableObject

@property (readonly, getter = getTimeSinceLastUpdate) NSTimeInterval timeSinceLastUpdate;
@property (readonly, getter = getLightDirection) GLKVector4 lightDirection;
@property (getter = getDrawingViewCamera, setter = setDrawingViewCamera:) NezGLCamera *drawingViewCamera;
@property (readonly, getter = getCamera) NezGLCamera *camera;
@property (readonly, getter = getLight) NezGLCamera *light;
@property (readonly) GLKVector3 letterBlockDimensions;
@property (readonly) GLKVector3 wordLineDimensions;
@property (readonly) NezAletterationGameTable *gameTable;
@property (getter = getViewport, setter = setViewport:) CGRect viewport;
@property (getter = isPaused, setter = setPaused:) BOOL paused;
@property (readonly, getter = getNextStarEmitter) NezVertexArrayObjectAcceleratingParticleEmitter *nextStarEmitter;
@property (readonly, getter = getNextPointLineEmitter) NezVertexArrayObjectParticleEmitter *nextPointLineEmitter;
@property (readonly, getter = getNextGeometryStarEmitter) NezVertexArrayObjectGeometryEmitter *nextGeometryStarEmitter;
@property (readonly, getter = getNextScoreRaysEmitter) NezVertexArrayObjectTexturedGeometryEmitter *nextScoreRaysEmitter;
@property (readonly, getter = getCongratulationWord) NezAletterationTextureBlock *congratulationWord;

+(float)getLuma:(GLKVector4)color;

//Update vertex arrays and animate
-(void)update;
-(void)updateVertexArrayData;

//Draw all vertex arrays.
-(void)draw;

//Load all game objects, textures...
-(void)load;

@end
