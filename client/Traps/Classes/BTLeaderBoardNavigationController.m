//
//  BTLeaderBoardNavigationController.m
//  Traps
//
//  Created by Roderic Campbell on 3/14/10.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import "BTLeaderBoardNavigationController.h"


@implementation BTLeaderBoardNavigationController

#pragma mark -
#pragma mark Initialization

-(id) init{
	if((self = [super init]) == nil){
		return nil;
	}
	self.tabBarItem = [[[UITabBarItem alloc] initWithTitle:@"Leaderboard"
													 image:nil 
													   tag:0]
					   autorelease];
	return self;
}

#pragma mark -
#pragma mark Cleanup


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
	
	//XXX: purge unnecessary data structures
}

-(void)dealloc{
	[super dealloc];
}

@end
