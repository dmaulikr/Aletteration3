//
//  NezAletterationLetterGroup.h
//  Aletteration3
//
//  Created by David Nesbitt on 2013/10/25.
//  Copyright (c) 2013 David Nesbitt. All rights reserved.
//

#import "NezAletterationRestorableGeometry.h"

@class NezAletterationLetterBlock;

@interface NezAletterationLetterGroup : NezAletterationRestorableGeometry {
	NSMutableArray *_letterBlockList;
}

@property (readonly) char letter;
@property (readonly, getter = getCount) NSInteger count;
@property GLKVector3 offset;

-(instancetype)initWithLetter:(char)letter;

-(NezAletterationLetterBlock*)pop;
-(void)push:(NezAletterationLetterBlock*)letterBlock;
-(void)removeAllLetterBlocks;

-(GLKMatrix4)nextModelMatrix;
-(GLKMatrix4)topModelMatrix;
-(GLKMatrix4)modelMatrixForIndex:(NSInteger)index;

@end
