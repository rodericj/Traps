//
//  HomeNavController.m
//  BoobyTrap3
//
//  Created by Roderic Campbell on 10/11/09.
//  Copyright 2009 Slide. All rights reserved.
//

#import "HomeNavController.h"


@implementation HomeNavController
//@synthesize homeTableViewController;
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
	NSLog(@"HomeNavController did load");
	//Lets see if we have any logged in data. check the property list
	NSDictionary *prefs;
	prefs = [NSDictionary dictionaryWithContentsOfFile:@"Profile.plist"];
	
	if(prefs){
		if(homeTableViewController == nil){
			homeTableViewController = [[homeTableViewController alloc] init];
		}
		[homeTableViewController updateMiniProfile:(prefs)];
		
	}
	else{
		if(loginViewController == nil){
			loginViewController = [[LoginViewController alloc] init];
		}
		if(homeTableViewController == nil){
			homeTableViewController = [[homeTableViewController alloc] init];
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
