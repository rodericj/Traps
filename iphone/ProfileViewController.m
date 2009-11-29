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
@synthesize userImage;

#pragma mark Set all of the labels just before the view loads
- (void)viewWillAppear:(BOOL)animated {
	UserProfile *userProfile = [UserProfile sharedSingleton];
	[userProfile printUserProfile];
	
	//Set the profile image
	NSURL *photoUrl = [NSURL URLWithString:[userProfile getPicture]];
	NSData *photoData = [NSData dataWithContentsOfURL:photoUrl];
	UIImage *profileImage =	[UIImage imageWithData:photoData];
	userImage.image = profileImage;
	
	NSLog(@"User has %s coins -- the whole profile is %@", [userProfile getCoinCount], userProfile);
	[usernameLabel setText:[userProfile getUserName]];
	[levelLabel setText:(NSString *)[userProfile getLevel]];
	[coinsLabel setText:(NSString *)[userProfile getCoinCount]];
	[hpLabel setText:(NSString *)[userProfile getHitPoints]];
	[killLabel setText:(NSString *)[userProfile getKillCount]];
	[totalTrapsLabel setText:(NSString *)[userProfile getTrapsSetCount]];
	
	[super viewWillAppear:animated];
}

#pragma mark initialization

// Implement viewDidLoad to do additional setup after loading the view, typically from a nib.
- (void)viewDidLoad {
    [super viewDidLoad];
}

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
