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
	
	
	BTHomeNavigationController *home = [[[BTHomeNavigationController alloc] init] autorelease];
	UIImage *homeImage = [UIImage imageNamed:@"homeicon.png"];
	UITabBarItem *homeItem = [[UITabBarItem alloc] initWithTitle:@"Home" image:homeImage tag:0];
	[home setTabBarItem:homeItem];
	
	BTSearchNavigationController *search = [[[BTSearchNavigationController alloc] init] autorelease];
	UIImage *searchImage = [UIImage imageNamed:@"searchicon.png"];
	UITabBarItem *searchItem = [[UITabBarItem alloc] initWithTitle:@"Search" image:searchImage tag:0];
	[search setTabBarItem:searchItem];
	
	BTProfileNavigationController *profile = [[[BTProfileNavigationController alloc] init] autorelease];
	UIImage *profileImage = [UIImage imageNamed:@"profileicon.png"];
	UITabBarItem *profileItem = [[UITabBarItem alloc] initWithTitle:@"Profile" image:profileImage tag:0];
	[profile setTabBarItem:profileItem];
	
	BTLeaderBoardNavigationController *leaderboard = [[[BTLeaderBoardNavigationController alloc] init] autorelease];
	UIImage *leaderboardImage = [UIImage imageNamed:@"leaderboardicon.png"];
	UITabBarItem *leaderboardItem = [[UITabBarItem alloc] initWithTitle:@"Leaderboard" image:leaderboardImage tag:0];
	[leaderboard setTabBarItem:leaderboardItem];
	
	// add view controllers to tab bar
	[tabBarController setViewControllers:[NSArray arrayWithObjects:
										  home,
										  search,
										  profile,
										  leaderboard,
										  nil]
								animated:NO];
	UIBarButtonItem *selfButton = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"homeicon.png"] 
																   style:UIBarButtonItemStylePlain 
																  target:self 
																  action:Nil];
	[tabBarController setToolbarItems:[NSArray arrayWithObjects:selfButton,selfButton,selfButton,selfButton,
									   nil]
													   animated:YES];
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

