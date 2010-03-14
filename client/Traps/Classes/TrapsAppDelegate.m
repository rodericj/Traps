//
//  TrapsAppDelegate.m
//  Traps
//
//  Created by Roderic Campbell on 3/14/10.
//  Copyright Apple Inc 2010. All rights reserved.
//

#import "TrapsAppDelegate.h"

#import "FBConnect/FBConnect.h"

#import "BTHomeNavigationController.h"
#import "BTLeaderBoardNavigationController.h"
#import "BTProfileNavigationController.h"
#import "BTSearchNavigationController.h"
#import "BTTabBarController.h"

@implementation TrapsAppDelegate

@synthesize window;

#pragma mark -
#pragma mark Application lifecycle

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
	// setup tab bar
	BTTabBarController *tabBarController = [BTTabBarController sharedTabBarController];
	[window addSubview:tabBarController.view];
	
	// add view controllers to tab bar
	[tabBarController setViewControllers:[NSArray arrayWithObjects:
										  [[[BTHomeNavigationController alloc] init] autorelease],
										  [[[BTSearchNavigationController alloc] init] autorelease],
										  [[[BTProfileNavigationController alloc] init] autorelease],
										  [[[BTLeaderBoardNavigationController alloc] init] autorelease],
										  nil]
								animated:NO];
	
	// finish window setup
    [window makeKeyAndVisible];
	
	return YES;
}


/**
 applicationWillTerminate: saves changes in the application's managed object context before the application terminates.
 */
- (void)applicationWillTerminate:(UIApplication *)application {
	
}

#pragma mark -
#pragma mark Memory management

- (void)dealloc {	
	RELEASE_SAFELY(window);
	[super dealloc];
}

@end

