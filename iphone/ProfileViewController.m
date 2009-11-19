//
//  ProfileViewController.m
//  BoobyTrap3
//
//  Created by Roderic Campbell on 10/11/09.
//  Copyright 2009 Slide. All rights reserved.
//

#import "ProfileViewController.h"
#import "UserProfile.h"

@implementation ProfileViewController

@synthesize usernameLabel;
@synthesize coinsLabel;
@synthesize hpLabel;
@synthesize killLabel;
@synthesize levelLabel;
@synthesize totalTrapsLabel;
@synthesize activeTrapsLabel;

#pragma mark Set all of the labels just before the view loads
- (void)viewWillAppear:(BOOL)animated {
	NSLog(@"viewWillAppear in profile. Lets add stuff here");
	//NSDictionary *profile = [NSDictionary dictionaryWithContentsOfFile:@"Profile.p list"];
	UserProfile *userProfile = [UserProfile sharedSingleton];
	
//	[usernameLabel setText:[profile objectForKey:@"username"]];
//	[levelLabel setText:[profile objectForKey:@"level"]];
//	[coinsLabel setText:[profile objectForKey:@"coinCount"]];
//	[hpLabel setText:[profile objectForKey:@"hitPoints"]];
//	[killLabel setText:[profile objectForKey:@"killCount"]];
//	[totalTrapsLabel setText:[profile objectForKey:@"trapsSetCount"]];	
	
	[usernameLabel setText:[userProfile getUserName]];
	[levelLabel setText:(NSString *)[userProfile getLevel]];
	[coinsLabel setText:(NSString *)[userProfile getCoinCount]];
	[hpLabel setText:(NSString *)[userProfile getHitPoints]];
	[killLabel setText:(NSString *)[userProfile getKillCount]];
	[totalTrapsLabel setText:(NSString *)[userProfile getTrapsSetCount]];
	//[profile release];
	
	[super viewWillAppear:animated];
}

#pragma mark initialization

// Implement viewDidLoad to do additional setup after loading the view, typically from a nib.
- (void)viewDidLoad {
	NSLog(@"ProfileViewController did load. could be a good time to update");
    [super viewDidLoad];
}



/*
// Override to allow orientations other than the default portrait orientation.
- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
    // Return YES for supported orientations
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}
*/

- (void)didReceiveMemoryWarning {
	// Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
	
	// Release any cached data, images, etc that aren't in use.
}

- (void)viewDidUnload {
	// Release any retained subviews of the main view.
	// e.g. self.myOutlet = nil;
}


- (void)dealloc {
    [super dealloc];
}


@end
