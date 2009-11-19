//
//  HomeNavController.m
//  BoobyTrap3
//
//  Created by Roderic Campbell on 10/11/09.
//  Copyright 2009 Slide. All rights reserved.
//

#import "HomeNavController.h"


@implementation HomeNavController

#pragma mark initialization

// Implement viewDidLoad to do additional setup after loading the view, typically from a nib.
- (void)viewDidLoad {
	NSLog(@"HomeNavController did load");
	//Lets see if we have any logged in data. check the property list
	//NSDictionary *prefs;
	//prefs = [NSDictionary dictionaryWithContentsOfFile:@"Profile.p list"];
	UserProfile *profile = [UserProfile sharedSingleton];
	//if(prefs){
	if([profile exists]){
		if(homeTableViewController == nil){
			homeTableViewController = [[HomeTableViewController alloc] init];
			//homeTableViewController = [[homeTableViewController alloc] init];
		}
		//[homeTableViewController updateMiniProfile:(prefs)];
		[homeTableViewController updateMiniProfile:([profile profile])];
		
	}
	else{
		if(loginViewController == nil){
			loginViewController = [[LoginViewController alloc] init];
		}
		if(homeTableViewController == nil){
			homeTableViewController = [[HomeTableViewController alloc] init];
			//homeTableViewController = [[homeTableViewController alloc] init];
		}
		[self presentModalViewController:loginViewController animated:YES];
	}
	
    [super viewDidLoad];
}

-(IBAction) logout{
	if(loginViewController == nil){
		loginViewController = [[LoginViewController alloc] init];
	}
	[self presentModalViewController:loginViewController animated:YES];

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
