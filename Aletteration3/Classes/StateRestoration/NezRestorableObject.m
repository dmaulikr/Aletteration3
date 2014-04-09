//
//  NezRestorableObject.m
//  Aletteration3
//
//  Created by David Nesbitt on 2013/11/03.
//  Copyright (c) 2013 David Nesbitt. All rights reserved.
//

#import "NezRestorableObject.h"

@implementation NezRestorableObject

+(NSObject<UIStateRestoring>*)objectWithRestorationIdentifierPath:(NSArray*)identifierComponents coder:(NSCoder*)coder {
	NSLog(@"%@ objectWithRestorationIdentifierPath:%@", NSStringFromClass([self class]), identifierComponents);
	return [[[self class] alloc] init];
}

-(instancetype)init {
	if (([super init])) {
		self.objectRestorationClass = [self class];
	}
	return self;
}

-(void)encodeRestorableStateWithCoder:(NSCoder*)coder {
}

-(void)decodeRestorableStateWithCoder:(NSCoder*)coder {
}

-(void)registerChildObject:(id<NezRestorable>)restorableObject withRestorationIdentifier:(NSString*)restorationIdentifier {
	restorableObject.restorationParent = self;
	restorableObject.objectRestorationClass = self.objectRestorationClass;
	[UIApplication registerObjectForStateRestoration:restorableObject restorationIdentifier:restorationIdentifier];
	[restorableObject registerChildObjectsForStateRestoration];
}

-(void)registerChildObjectsForStateRestoration {
}

@end
