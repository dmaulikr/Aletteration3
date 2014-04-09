//
//  NezVertexArrayObjectEmitter.h
//  Aletteration3
//
//  Created by David Nesbitt on 2013/12/06.
//  Copyright (c) 2013 David Nesbitt. All rights reserved.
//

#import "NezInstanceVertexArrayObject.h"
#import "NezGCD.h"

@interface NezVertexArrayObjectEmitter : NezInstanceVertexArrayObject {
	float _life;
	BOOL _isDead;
	float _time;
	GLKVector4 _color0;
	GLKVector4 _color1;
	float _growth;
	float _decay;
}

@property float life;
@property (readonly, getter = isDead) BOOL isDead;
@property (getter = time, setter = setTime:) float time;
@property GLKVector4 color0;
@property GLKVector4 color1;
@property float growth;
@property float decay;

-(void)start;
-(void)startWithCompletionHandler:(NezCompletionHandler)completionHandler;

@end
