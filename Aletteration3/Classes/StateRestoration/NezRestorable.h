//
//  NezRestorable.h
//  Aletteration3
//
//  Created by David Nesbitt on 2013/11/05.
//  Copyright (c) 2013 David Nesbitt. All rights reserved.
//

@protocol NezRestorable <NSObject, UIStateRestoring, UIObjectRestoration>

@property (nonatomic, weak) id<NezRestorable> restorationParent;
@property (nonatomic, weak) Class<NezRestorable> objectRestorationClass;

-(void)encodeRestorableStateWithCoder:(NSCoder*)coder;
-(void)decodeRestorableStateWithCoder:(NSCoder*)coder;

-(void)registerChildObject:(id<NezRestorable>)restorableObject withRestorationIdentifier:(NSString*)restorationIdentifier;
-(void)registerChildObjectsForStateRestoration;

@end
