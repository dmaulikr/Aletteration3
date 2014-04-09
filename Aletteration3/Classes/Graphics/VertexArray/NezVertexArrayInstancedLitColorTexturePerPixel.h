//
//  NezVertexArrayInstancedLitAmbientSpecularPerPixelTexture.h
//  Aletteration3
//
//  Created by David Nesbitt on 2013-09-24.
//  Copyright (c) 2013 David Nesbitt. All rights reserved.
//

#import "NezVertexArrayInstancedAbstract.h"

@interface NezVertexArrayInstancedLitColorTexturePerPixel : NezVertexArrayInstancedAbstract {
	GLKTextureInfo *_textureInfo;
}

@property (readonly, getter = getVertexList) NezLitInstanceTextureVertex *vertexList;
@property (readonly, getter = getInstanceAttributeList) NezInstanceAttributeColorTexture *instanceAttributeList;
@property GLKTextureInfo *textureInfo;

-(instancetype)initWithObjVertexArray:(NezModelVertexArray*)vertexArray andInstanceCount:(GLsizei)instanceCount;

@end
