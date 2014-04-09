//
//  NezAletterationRoundCornerTagView.m
//  Aletteration3
//
//  Created by David Nesbitt on 2013/11/11.
//  Copyright (c) 2013 David Nesbitt. All rights reserved.
//

#import "NezAletterationRoundCornerTagView.h"

@implementation NezAletterationRoundCornerTagView

-(id)initWithFrame:(CGRect)frame {
	self = [super initWithFrame:frame];
	if (self) {
		[self setCornerRadius];
	}
	return self;
}

-(id)initWithCoder:(NSCoder *)coder {
	self = [super initWithCoder:coder];
	if (self) {
		[self setCornerRadius];
	}
	return self;
}

-(void)setCornerRadius {
	if (self.tag > 0) {
		[[self layer] setCornerRadius:self.tag];
		[[self layer] setMasksToBounds:NO];
	}
	self.layer.borderColor = [UIColor blackColor].CGColor;
	self.layer.borderWidth = 2.0;
}

@end
