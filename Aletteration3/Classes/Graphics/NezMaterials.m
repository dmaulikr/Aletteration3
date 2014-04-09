//
//  NezMaterials.m
//  Aletteration3
//
//  Created by David Nesbitt on 2013-09-24.
//  Copyright (c) 2013 David Nesbitt. All rights reserved.
//

#import "NezMaterials.h"

@implementation NezMaterial

+(NezMaterial*)material {
	NezMaterial *material = [[NezMaterial alloc] init];
	return material;
}

+(NezMaterial*)materialWithDiffuse:(GLKVector4)diffuse ambient:(GLKVector4)ambient specular:(GLKVector4)specular emissive:(GLKVector4)emissive andShininess:(float)shininess {
	NezMaterial *material = [[NezMaterial alloc] initWithDiffuse:diffuse ambient:ambient specular:specular emissive:emissive andShininess:shininess];
	return material;
}

-(instancetype)init {
	if ((self = [super init])) {
		_diffuse = GLKVector4Make(0.0f, 0.0f, 0.0f, 1.0f);
		_ambient = GLKVector4Make(0.0f, 0.0f, 0.0f, 1.0f);
		_specular = GLKVector4Make(0.0f, 0.0f, 0.0f, 0.0f);
		_emissive = GLKVector4Make(0.0f, 0.0f, 0.0f, 1.0f);
		_shininess = 0.0f;
	}
	return self;
}

-(instancetype)initWithDiffuse:(GLKVector4)diffuse ambient:(GLKVector4)ambient specular:(GLKVector4)specular emissive:(GLKVector4)emissive andShininess:(float)shininess {
	if ((self = [super init])) {
		_diffuse = diffuse;
		_ambient = ambient;
		_specular = specular;
		_emissive = emissive;
		_shininess = shininess;
	}
	return self;
}

@end

static NezMaterial *gDefaultMaterial;
static NSMutableDictionary *gMaterialDictionary;

@implementation NezMaterials

+(void)initialize {
	@synchronized (self) {
		static BOOL initialized = NO;
		if(!initialized) {
			initialized = YES;
			gDefaultMaterial = [NezMaterial material];
			gMaterialDictionary = [NSMutableDictionary dictionary];
			[NezMaterials loadMaterials];
		}
	}
}

+(NSArray*)materialFilePaths {
	NSString *resourcePath = [NSString stringWithFormat:@"%@/Materials", [[NSBundle mainBundle] resourcePath]];
	NSFileManager *filemgr = [[NSFileManager alloc] init];
	NSMutableArray *fileList = [NSMutableArray array];
	
	NSArray *allFiles = [filemgr contentsOfDirectoryAtPath:resourcePath error:NULL];
	for (NSString *fileName in allFiles) {
		if ([fileName.pathExtension isEqualToString:@"mat"]) {
			[fileList addObject:[NSString stringWithFormat:@"%@/%@", resourcePath, fileName]];
		}
	}
	return fileList;
}

+(void)loadMaterials {
	NSArray *materialPathList = [NezMaterials materialFilePaths];
	for (NSString *filePath in materialPathList) {
		[NezMaterials loadMaterialFile:filePath];
	}
}

+(void)loadMaterialFile:(NSString*)filePath {
	FILE *matFile = fopen([filePath cStringUsingEncoding:NSUTF8StringEncoding], "rb");
	char line[1024];
	
	NSString *materialName = nil;
	
	NSError *error = NULL;
	NSRegularExpression *regex = [NSRegularExpression regularExpressionWithPattern:@"\\s*(\\w+)\\s*\\{" options:0 error:&error];
	NSRegularExpression *regexWord = [NSRegularExpression regularExpressionWithPattern:@"\\s*(\\w+)\\s*" options:0 error:&error];
	NSRegularExpression *regexNumber = [NSRegularExpression regularExpressionWithPattern:@"([0-9]+[.]{0,1}[0-9]*)" options:0 error:&error];

	NezMaterial *material = nil;
	while (fgets(line, 1023, matFile)) {
		NSString *string = [NSString stringWithFormat:@"%s", line];
		if (materialName == nil) {
			NSArray *matches = [regex matchesInString:string options:0 range:NSMakeRange(0, [string length])];
			
			if(matches.count == 1) {
				NSRange nameRange = [matches.firstObject rangeAtIndex:1];
				materialName = [string substringWithRange:nameRange];
				material = [NezMaterial material];
			}
		} else {
			NSCharacterSet *rightCurlySet = [NSCharacterSet characterSetWithCharactersInString:@"}"];
			NSRange range = [string rangeOfCharacterFromSet:rightCurlySet];
			if (range.location != NSNotFound) {
				gMaterialDictionary[materialName] = material;
				materialName = nil;
				material = nil;
			} else {
				NSArray *stringList = [string componentsSeparatedByString:@":"];
				if (stringList.count == 2) {
					NSArray *matches = [regexWord matchesInString:stringList[0] options:0 range:NSMakeRange(0, [stringList[0] length])];
					if (matches.count == 1) {
						NSRange nameRange = [matches.firstObject rangeAtIndex:1];
						NSString *nameString = [stringList[0] substringWithRange:nameRange];
						matches = [regexNumber matchesInString:stringList[1] options:0 range:NSMakeRange(0, [stringList[1] length])];
						
						if ([nameString isEqualToString:@"diffuse"]) {
							material.diffuse = [NezMaterials loadVec4From:stringList[1] andMatches:matches];
						} else if ([nameString isEqualToString:@"ambient"]) {
							material.ambient = [NezMaterials loadVec4From:stringList[1] andMatches:matches];
						} else if ([nameString isEqualToString:@"specular"]) {
							material.specular = [NezMaterials loadVec4From:stringList[1] andMatches:matches];
						} else if ([nameString isEqualToString:@"emissive"]) {
							material.emissive = [NezMaterials loadVec4From:stringList[1] andMatches:matches];
						} else if ([nameString isEqualToString:@"shininess"]) {
							material.shininess = [NezMaterials loadFloatFrom:stringList[1] andMatches:matches];
						}
					}
				}
			}
		}
	}
	fclose(matFile);
}

+(float)loadFloatFrom:(NSString*)string andMatches:(NSArray*)matches {
	if (matches.count == 1) {
		NSString *floatString = [string substringWithRange:[matches.firstObject rangeAtIndex:1]];
		return [floatString floatValue];
	}
	return 0.0f;
}

+(GLKVector3)loadVec3From:(NSString*)string andMatches:(NSArray*)matches {
	if (matches.count == 3) {
		__block GLKVector3 value;
		[matches enumerateObjectsUsingBlock:^(NSTextCheckingResult *match, NSUInteger idx, BOOL *stop) {
			NSString *floatString = [string substringWithRange:[match rangeAtIndex:1]];
			value.v[idx] = [floatString floatValue];
		}];
		return value;
	}
	return GLKVector3Make(0.0f, 0.0f, 0.0f);
}

+(GLKVector4)loadVec4From:(NSString*)string andMatches:(NSArray*)matches {
	if (matches.count == 4) {
		__block GLKVector4 value;
		[matches enumerateObjectsUsingBlock:^(NSTextCheckingResult *match, NSUInteger idx, BOOL *stop) {
			NSString *floatString = [string substringWithRange:[match rangeAtIndex:1]];
			value.v[idx] = [floatString floatValue];
		}];
		return value;
	}
	return GLKVector4Make(0.0f, 0.0f, 0.0f, 0.0f);
}

+(NezMaterial*)materialForName:(NSString*)materialName {
	NezMaterial *material = gMaterialDictionary[materialName];
	if (material) {
		return material;
	} else {
		return gDefaultMaterial;
	}
}

@end
