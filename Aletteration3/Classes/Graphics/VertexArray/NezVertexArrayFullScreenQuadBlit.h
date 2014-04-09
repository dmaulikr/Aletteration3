//
//  NezVertexArrayFullScreenQuadBlit.h
//  Aletteration3
//
//  Created by David Nesbitt on 10/6/2013.
//  Copyright (c) 2013 David Nesbitt. All rights reserved.
//

#import "NezVertexArrayInstancedAbstract.h"

@interface NezVertexArrayFullScreenQuadBlit : NezVertexArrayInstancedAbstract

@property (readonly, getter = getVertexList) NezTextureVertex *vertexList;
@property GLuint texture0;

-(instancetype)initWithObjVertexArray:(NezModelVertexArray*)vertexArray;

@end
