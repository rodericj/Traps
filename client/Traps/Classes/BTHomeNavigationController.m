//
//  BTHomeNavigationController.m
//  Traps
//
//  Created by Kelvin Kakugawa on 3/14/10.
//  Copyright 2010 Apple Inc. All rights reserved.
//

#import "BTHomeNavigationController.h"

#import "BTHomeInternalViewController.h"

@implementation BTHomeNavigationController

#pragma mark -
#pragma mark Initialization

- (id)init {
	if ((self = [super init]) == nil) {
		return nil;
	}
	
	BTHomeInternalViewController *internalViewController = [[BTHomeInternalViewController alloc] init];
	
	[self pushViewController:internalViewController animated:NO];
	
	self.tabBarItem = [[[UITabBarItem alloc] initWithTitle:@"Home"
													 image:nil
													   tag:0]
					   autorelease];
	
	internalViewController.tabBarItem = self.tabBarItem;
	
	[internalViewController release];
	
	return self;
}

#pragma mark -
#pragma mark Cleanup

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
	
	//XXX: purge unnecessary data structures
}

- (void)dealloc {
	[super dealloc];
}

@end
