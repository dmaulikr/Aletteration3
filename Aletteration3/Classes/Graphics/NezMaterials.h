//
//  NezMaterials.h
//  Aletteration3
//
//  Created by David Nesbitt on 2013-09-24.
//  Copyright (c) 2013 David Nesbitt. All rights reserved.
//

#import <GLKit/GLKit.h>

@interface NezMaterial : NSObject

@property GLKVector4 diffuse;
@property GLKVector4 ambient;
@property GLKVector4 specular;
@property GLKVector4 emissive;
@property float shininess;

@end

@interface NezMaterials : NSObject

+(NezMaterial*)materialForName:(NSString*)materialName;

@end
