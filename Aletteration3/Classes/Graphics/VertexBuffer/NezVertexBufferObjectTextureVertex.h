//
//  NezVertexBufferObjectTextureVertex.h
//  Aletteration3
//
//  Created by David Nesbitt on 2013/12/07.
//  Copyright (c) 2013 David Nesbitt. All rights reserved.
//

#import "NezVertexBufferObject.h"

@interface NezVertexBufferObjectTextureVertex : NezVertexBufferObject

@property (readonly, getter = getVertexList) NezTextureVertex *vertexList;

@end

