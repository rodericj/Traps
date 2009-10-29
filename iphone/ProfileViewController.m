//
//  ProfileViewController.m
//  BoobyTrap3
//
//  Created by Roderic Campbell on 10/11/09.
//  Copyright 2009 Slide. All rights reserved.
//

#import "ProfileViewController.h"


@implementation ProfileViewController

@synthesize usernameLabel;
@synthesize coinsLabel;
@synthesize hpLabel;
@synthesize killLabel;
@synthesize levelLabel;
@synthesize totalTrapsLabel;
@synthesize activeTrapsLabel;

/*
 // The designated initializer.  Override if you create the controller programmatically and want to perform customization that is not appropriate for viewDidLoad.
- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil {
    if (self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil]) {
        // Custom initialization
    }
    return self;
}
*/

/*
// Implement loadView to create a view hierarchy programmatically, without using a nib.
- (void)loadView {
}
*/


// Implement viewDidLoad to do additional setup after loading the view, typically from a nib.
- (void)viewDidLoad {
	NSLog(@"ProfileViewController did load. could be a good time to update");
    [super viewDidLoad];
}

- (void)viewWillAppear:(BOOL)animated {
	NSLog(@"viewWillAppear in profile. Lets add stuff here");
	NSDictionary *profile = [NSDictionary dictionaryWithContentsOfFile:@"Profile.plist"];

	[usernameLabel setText:[profile objectForKey:@"username"]];
	[levelLabel setText:[profile objectForKey:@"level"]];
	[coinsLabel setText:[profile objectForKey:@"coinCount"]];
	[hpLabel setText:[profile objectForKey:@"hitPoints"]];
	[killLabel setText:[profile objectForKey:@"killCount"]];
	[totalTrapsLabel setText:[profile objectForKey:@"trapsSetCount"]];
	[profile release];
	
	[super viewWillAppear:animated];
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
