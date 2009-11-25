//
//  BoobyTrap3AppDelegate.m
//  BoobyTrap3
//
//  Created by Roderic Campbell on 10/11/09.
//  Copyright Slide 2009. All rights reserved.
//

#import "BoobyTrap3AppDelegate.h"
#import "HomeNavController.h"
#import "DropTrapsNavController.h"

@implementation BoobyTrap3AppDelegate

@synthesize dropTrapsNavController;
@synthesize window;
@synthesize rootController;
@synthesize homeNavController;
@synthesize loginViewController;
@synthesize session;
- (void)applicationDidFinishLaunching:(UIApplication *)application {    
    // Override point for customization after application launch
	[window addSubview:rootController.view];
	//[window addSubview:loginViewController.view];
	[window makeKeyAndVisible];
}



- (void)dealloc {
    [window release];
	[rootController release];
	[dropTrapsNavController release];
	[homeNavController release];
    [super dealloc];
}


@end
