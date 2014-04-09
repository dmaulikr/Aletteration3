//
//  NezAletterationSplashViewController.m
//  Aletteration3
//
//  Created by David Nesbitt on 2013-09-25.
//  Copyright (c) 2013 David Nesbitt. All rights reserved.
//

#import "NezAletterationSplashViewController.h"
#import "NezAletterationAppDelegate.h"
#import "NezAletterationGraphics.h"
#import "NezAletterationPlayerPrefs.h"
#import "NezAletterationStoreKit.h"
#import "NezStoreKitProduct.h"

@interface NezAletterationSplashViewController () {
	__weak NezAletterationGraphics *_graphics;
}
@end

@implementation NezAletterationSplashViewController

-(void)viewDidAppear:(BOOL)animated {
	[self loadObjects];
	[self performSegueWithIdentifier:@"SplashToMainSegue" sender:self];
}

-(void)loadObjects {
	_graphics = [NezAletterationAppDelegate sharedAppDelegate].graphics;
	[_graphics load];
	
	[[NezAletterationStoreKit sharedInstance] requestProductsWithCompletionHandler:^(BOOL success, NSArray *products) {
		for (NezStoreKitProduct *product in products) {
			NSLog(@"%@", product.localizedPrice);
		}
	}];
}

-(void)encodeRestorableStateWithCoder:(NSCoder*)coder {
	[super encodeRestorableStateWithCoder:coder];
	NSLog(@"NezAletterationSplashViewController encodeRestorableStateWithCoder %@", coder);
	[coder encodeObject:_graphics forKey:@"_graphics"];
	[[NezAletterationAppDelegate sharedAppDelegate] saveLocalPlayerPrefs];
}

-(void)decodeRestorableStateWithCoder:(NSCoder*)coder {
	[super decodeRestorableStateWithCoder:coder];
	NSLog(@"NezAletterationSplashViewController decodeRestorableStateWithCoder %@", coder);
	_graphics = [coder decodeObjectForKey:@"_graphics"];
}

@end
