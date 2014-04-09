//
//  NezVertexBufferObjectLitVertex.h
//  Aletteration3
//
//  Created by David Nesbitt on 2013/12/07.
//  Copyright (c) 2013 David Nesbitt. All rights reserved.
//

#import "NezVertexBufferObject.h"

@interface NezVertexBufferObjectLitVertex : NezVertexBufferObject

@property (readonly, getter = getVertexList) NezLitVertex *vertexList;

@end

