//
//  NezAletterationRestorableGeometry.h
//  Aletteration3
//
//  Created by David Nesbitt on 2013/11/03.
//  Copyright (c) 2013 David Nesbitt. All rights reserved.
//

#import "NezGeometry.h"
#import "NezRestorable.h"

@interface NezAletterationRestorableGeometry : NezGeometry<NezRestorable>

@property (nonatomic, weak) id<NezRestorable> restorationParent;
@property (nonatomic, weak) Class<NezRestorable> objectRestorationClass;

-(instancetype)initWithDimensions:(GLKVector3)dimensions;

@end
