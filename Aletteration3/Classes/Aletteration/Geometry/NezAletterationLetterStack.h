//
//  NezAletterationLetterStack.h
//  Aletteration3
//
//  Created by David Nesbitt on 2013-09-22.
//  Copyright (c) 2013 David Nesbitt. All rights reserved.
//

#import <GLKit/GLKit.h>
#import "NezAletterationLetterGroup.h"

@class NezAletterationLetterBlock;
@class NezAletterationLetterStackLabel;

@interface NezAletterationLetterStack : NezAletterationLetterGroup

@property (readonly) NezAletterationLetterStackLabel *stackLabel;

-(instancetype)initWithLetter:(char)letter andLabel:(NezAletterationLetterStackLabel*)stackLabel;

@end
