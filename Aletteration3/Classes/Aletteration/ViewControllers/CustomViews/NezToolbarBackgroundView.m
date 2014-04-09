//
//  NezToolbarBackgroundView.m
//  Aletteration3
//
//  Created by David Nesbitt on 2013-09-29.
//  Copyright (c) 2013 David Nesbitt. All rights reserved.
//

#import "NezToolbarBackgroundView.h"

@interface NezToolbarBackgroundView ()

@property (nonatomic, strong) UIToolbar *toolbar;

@end

@implementation NezToolbarBackgroundView

-(instancetype)initWithCoder:(NSCoder *)aDecoder {
    self = [super initWithCoder:aDecoder];
    if (self) {
        [self setup];
    }
    return self;
}

-(instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        [self setup];
    }
    return self;
}

-(instancetype)init {
    self = [super init];
    if (self) {
        [self setup];
    }
    return self;
}

-(void)setup {
	if (![self toolbar]) {
		self.backgroundColor = [UIColor clearColor];
		self.toolbar = [[UIToolbar alloc] initWithFrame:self.bounds];
		self.toolbar.barStyle = UIBarStyleBlack;
		self.toolbar.translucent = YES;
		[self.layer insertSublayer:self.toolbar.layer atIndex:0];
	}
}

-(void)setBlurTintColor:(UIColor *)blurTintColor {
    [self.toolbar setBarTintColor:blurTintColor];
}

-(void)layoutSubviews {
    [super layoutSubviews];
    [self.toolbar setFrame:[self bounds]];
}

@end