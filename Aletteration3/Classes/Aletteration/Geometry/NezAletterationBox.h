//
//  NezAletterationBox.h
//  Aletteration3
//
//  Created by David Nesbitt on 2013/10/23.
//  Copyright (c) 2013 David Nesbitt. All rights reserved.
//

#import "NezAletterationLid.h"
#import "NezInstanceAttributeTypes.h"

@class NezGLCamera;

@interface NezAletterationBox : NezAletterationLid

@property (readonly) BOOL lidAttached;
@property (strong, readonly) NezAletterationLid *lid;

-(instancetype)initWithLid:(NezAletterationLid*)lid instanceAbo:(NezInstanceAttributeBufferObjectColor*)instanceAbo index:(NSInteger)instanceAttributeIndex andDimensions:(GLKVector3)dimensions;

-(void)attachLid;
-(void)detachLid;

-(GLKMatrix4)lidMatrix;
-(GLKMatrix4)lidMatrixForModelMatrix:(GLKMatrix4)modelMatrix;
-(GLKMatrix4)lidMatrixForOrientation:(GLKQuaternion)orientation andPosition:(GLKVector3)center;

@end
