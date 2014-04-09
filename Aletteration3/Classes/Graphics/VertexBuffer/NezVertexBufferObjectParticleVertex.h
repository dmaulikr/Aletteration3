//
//  NezVertexBufferObjectParticleVertex.h
//  Aletteration3
//
//  Created by David Nesbitt on 2013/12/07.
//  Copyright (c) 2013 David Nesbitt. All rights reserved.
//

#import "NezVertexBufferObject.h"

@interface NezVertexBufferObjectParticleVertex : NezVertexBufferObject

@property (readonly, getter = getVertexList) NezParticleVertex *vertexList;

@end

