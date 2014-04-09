//
//  NezInstanceVertexArrayObjectTextureColor.h
//  Aletteration3
//
//  Created by David Nesbitt on 2013/10/21.
//  Copyright (c) 2013 David Nesbitt. All rights reserved.
//

#import "NezVertexArrayObject.h"
#import "NezVertexTypes.h"

@class NezVertexBufferObjectTextureVertex;

@interface NezVertexArrayObjectTexture : NezVertexArrayObject

@property (readonly, getter = getVertexBufferObject) NezVertexBufferObjectTextureVertex *vertexBufferObject;

@property (readonly, getter = getVertexList) NezTextureVertex *vertexList;
@property GLKTextureInfo *textureInfo;
@property GLKMatrix4 modelMatrix;

@end
