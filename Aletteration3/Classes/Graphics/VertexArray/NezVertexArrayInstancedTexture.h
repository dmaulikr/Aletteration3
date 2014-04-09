//
//  NezVertexArrayTexture.h
//  Aletteration3
//
//  Created by David Nesbitt on 2013-09-23.
//  Copyright (c) 2013 David Nesbitt. All rights reserved.
//

#import "NezVertexArrayInstancedAbstract.h"

@interface NezVertexArrayInstancedTexture : NezVertexArrayInstancedAbstract {
}

@property (readonly, getter = getVertexList) NezInstanceTextureVertex *vertexList;
@property (readonly, getter = getInstanceAttributeList) NezInstanceAttributeTexture *instanceAttributeList;
@property GLKTextureInfo *textureInfo;

-(instancetype)initWithObjVertexArray:(NezModelVertexArray*)vertexArray andInstanceCount:(GLsizei)instanceCount;

@end
