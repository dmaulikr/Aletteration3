//
//  NezVertexArrayObjectEmitter.m
//  Aletteration3
//
//  Created by David Nesbitt on 2013/12/06.
//  Copyright (c) 2013 David Nesbitt. All rights reserved.
//

#import "NezVertexArrayObjectEmitter.h"

@implementation NezVertexArrayObjectEmitter {
	NezVoidBlock _completionHandler;
}

-(instancetype)initWithVertexBufferObject:(NezVertexBufferObject*)vertexBufferObject {
	if ((self = [super initWithVertexBufferObject:vertexBufferObject])) {
		_isDead = YES;
	}
	return self;
}

-(instancetype)initWithVertexBufferObject:(NezVertexBufferObject*)vertexBufferObject andInstanceAttributeBufferObject:(NezInstanceAttributeBufferObject *)instanceAttributeBufferObject {
	if ((self = [super initWithVertexBufferObject:vertexBufferObject andInstanceAttributeBufferObject:instanceAttributeBufferObject])) {
		_isDead = YES;
	}
	return self;
}

-(float)time {
	return _time;
}

-(void)setTime:(float)time {
	if (!_isDead) {
		_time = time;
		if (_time >= self.life) {
			_time = self.life;
			_isDead = YES;
			if (_completionHandler) {
				_completionHandler();
				_completionHandler = nil;
			}
		}
	}
}

-(BOOL)isDead {
	return _isDead;
}

-(float)growth {
	return _growth;
}

-(void)setGrowth:(float)growth {
	_growth = growth;
	_life = _growth+_decay;
}

-(float)decay {
	return _decay;
}

-(void)setDecay:(float)decay {
	_decay = decay;
	_life = _growth+_decay;
}

-(void)start {
	_isDead = NO;
	self.time = 0.0f;
}

-(void)startWithCompletionHandler:(NezCompletionHandler)completionHandler {
	if (self.life > 0.0) {
		if (completionHandler) {
			_completionHandler = [completionHandler copy];
		}
		[self start];
	} else if (completionHandler) {
		completionHandler(YES);
	}
}

@end
