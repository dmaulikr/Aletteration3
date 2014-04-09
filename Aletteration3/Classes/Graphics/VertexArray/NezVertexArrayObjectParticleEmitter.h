//
//  NezVertexArrayObjectParticleEmitter.h
//  Aletteration3
//
//  Created by David Nesbitt on 2013/11/27.
//  Copyright (c) 2013 David Nesbitt. All rights reserved.
//

#import "NezVertexArrayObjectEmitter.h"
#import "NezVertexTypes.h"
#import "NezGCD.h"

@class NezVertexBufferObjectParticleVertex;

@interface NezVertexArrayObjectParticleEmitter : NezVertexArrayObjectEmitter {
	GLKTextureInfo *_textureInfo;
	float _size;
}

@property (readonly, getter = getVertexBufferObject) NezVertexBufferObjectParticleVertex *vertexBufferObject;
@property (readonly, getter = getVertexList) NezParticleVertex *vertexList;

@property GLKTextureInfo *textureInfo;
@property float size;

@end
