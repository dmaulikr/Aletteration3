//
//  NezVertexArrayFullScreenQuadGlow.h
//  Aletteration3
//
//  Created by David Nesbitt on 2013-10-03.
//  Copyright (c) 2013 David Nesbitt. All rights reserved.
//

#import "NezVertexArrayInstancedAbstract.h"

@interface NezVertexArrayFullScreenQuadGlow : NezVertexArrayInstancedAbstract

@property (readonly, getter = getVertexList) NezTextureVertex *vertexList;
@property GLuint texture0;
@property GLuint texture1;

-(instancetype)initWithObjVertexArray:(NezModelVertexArray*)vertexArray;

@end
