//
//  UIView+ExtraContraints.m
//  Aletteration3
//
//  Created by David Nesbitt on 2013/11/14.
//  Copyright (c) 2013 David Nesbitt. All rights reserved.
//

#import "UIView+ExtraContraints.h"

@implementation UIView (ExtraContraints)

-(void)addConstraintWidthEqualsHeight {
	NSLayoutConstraint *constraint = [NSLayoutConstraint
												 constraintWithItem:self
												 attribute:NSLayoutAttributeWidth
												 relatedBy:NSLayoutRelationEqual
												 toItem:self
												 attribute:NSLayoutAttributeHeight
												 multiplier:1.0
												 constant:0];
	constraint.priority = 1000;
	[self.superview addConstraint:constraint];
}

@end
