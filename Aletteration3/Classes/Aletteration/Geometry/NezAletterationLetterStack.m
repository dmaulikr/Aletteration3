//
//  NezAletterationLetterStack.m
//  Aletteration3
//
//  Created by David Nesbitt on 2013-09-22.
//  Copyright (c) 2013 David Nesbitt. All rights reserved.
//

#import "NezAletterationLetterStack.h"
#import "NezAletterationLetterStackLabel.h"
#import "NezAletterationLetterBlock.h"
#import "NezAletterationGraphics.h"

@implementation NezAletterationLetterStack

-(instancetype)initWithLetter:(char)letter andLabel:(NezAletterationLetterStackLabel*)stackLabel {
	if ((self=[super initWithLetter:letter])) {
		_stackLabel = stackLabel;
	}
	return self;
}

-(void)encodeRestorableStateWithCoder:(NSCoder*)coder {
	[super encodeRestorableStateWithCoder:coder];
	
	[coder encodeObject:_stackLabel forKey:@"_stackLabel"];
}

-(void)decodeRestorableStateWithCoder:(NSCoder*)coder {
	[super decodeRestorableStateWithCoder:coder];
	
	_stackLabel = [coder decodeObjectForKey:@"_stackLabel"];
}

-(void)registerChildObjectsForStateRestoration {
	[super registerChildObjectsForStateRestoration];
	
	[self registerChildObject:_stackLabel withRestorationIdentifier:@"_stackLabel"];
}

-(NezAletterationLetterBlock*)pop {
	if (self.count > 0) {
		_stackLabel.count = self.count-1;
		return [super pop];
	}
	return nil;
}

-(void)push:(NezAletterationLetterBlock*)letterBlock {
	[_letterBlockList addObject:letterBlock];
	_stackLabel.count = self.count;
}

-(void)setModelMatrix:(GLKMatrix4)modelMatrix {
	[super setModelMatrix:modelMatrix];
	_stackLabel.modelMatrix = GLKMatrix4Translate(modelMatrix, 0.0f, -(_dimensions.y*0.9f), 0.0f);
}

-(void)removeAllLetterBlocks {
	[super removeAllLetterBlocks];
	_stackLabel.count = 0;
}
@end
