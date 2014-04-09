//
//  NezVertexBufferObjectLitInstanceTextureVertex.h
//  Aletteration3
//
//  Created by David Nesbitt on 2013/12/07.
//  Copyright (c) 2013 David Nesbitt. All rights reserved.
//

#import "NezVertexBufferObject.h"

@interface NezVertexBufferObjectLitInstanceTextureVertex : NezVertexBufferObject

@property (readonly, getter = getVertexList) NezLitInstanceTextureVertex *vertexList;

@end

