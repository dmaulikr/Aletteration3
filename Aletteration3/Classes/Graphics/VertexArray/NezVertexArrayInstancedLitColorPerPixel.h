//
//  NezVertexArrayInstancedLitAmbientSpecularPerPixel.h
//  Aletteration3
//
//  Created by David Nesbitt on 2013-09-24.
//  Copyright (c) 2013 David Nesbitt. All rights reserved.
//

#import "NezVertexArrayInstancedAbstract.h"

@interface NezVertexArrayInstancedLitColorPerPixel : NezVertexArrayInstancedAbstract

@property (readonly, getter = getVertexList) NezLitVertex *vertexList;
@property (readonly, getter = getInstanceAttributeList) NezInstanceAttributeColor *instanceAttributeList;

-(instancetype)initWithObjVertexArray:(NezModelVertexArray*)vertexArray andInstanceCount:(GLsizei)instanceCount;

@end
