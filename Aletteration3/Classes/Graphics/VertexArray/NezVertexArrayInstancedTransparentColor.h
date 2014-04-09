//
//  NezVertexArrayInstancedTransparentColor.h
//  Aletteration3
//
//  Created by David Nesbitt on 2013-09-23.
//  Copyright (c) 2013 David Nesbitt. All rights reserved.
//

#import "NezVertexArrayInstancedAbstract.h"

@interface NezVertexArrayInstancedTransparentColor : NezVertexArrayInstancedAbstract

@property (readonly, getter = getVertexList) NezVertex *vertexList;
@property (readonly, getter = getInstanceAttributeList) NezInstanceAttributeColor *instanceAttributeList;

-(instancetype)initWithObjVertexArray:(NezModelVertexArray*)vertexArray andInstanceCount:(GLsizei)instanceCount;

@end
