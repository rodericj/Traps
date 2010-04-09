//
//  BTNavBar+CustomImage.m
//  Traps
//
//  Created by Roderic Campbell on 4/8/10.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import "UINavigationBar+CustomImage.h"
@implementation UINavigationBar (CustomImage)

- (void)drawRect:(CGRect)rect {
	UIImage *image = [UIImage imageNamed: @"homeViewTopBanner.png"];
	[image drawInRect:CGRectMake(0, 0, self.frame.size.width, self.frame.size.height)];
}
@end
