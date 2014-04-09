//
//  NezVertexBufferObjectVertex.h
//  Aletteration3
//
//  Created by David Nesbitt on 2013/12/07.
//  Copyright (c) 2013 David Nesbitt. All rights reserved.
//

#import "NezVertexBufferObject.h"

@interface NezVertexBufferObjectVertex : NezVertexBufferObject

@property (readonly, getter = getVertexList) NezVertex *vertexList;

@end

