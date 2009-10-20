//
//  LoginViewController.m
//  BoobyTrap3
//
//  Created by Roderic Campbell on 10/13/09.
//  Copyright 2009 Slide. All rights reserved.
//

#import "LoginViewController.h"


@implementation LoginViewController
@synthesize usernameTextField;
@synthesize passwordTextField;

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

- (IBAction) submitLoginForm{
	NSLog(@"Submit button pushed");
	NSLog(usernameTextField.text);
	NSLog(passwordTextField.text);
	
	//call to the web service to see if we can log in
	
	//if failed login, report the reason and bounce
	
	//once logged in, save this info into the property list then remove modal view
	[self dismissModalViewControllerAnimated:YES];
}

// Implement viewDidLoad to do additional setup after loading the view, typically from a nib.
- (void)viewDidLoad {
	NSLog(@"LoginViewController did load");
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
	[usernameTextField release];
	[passwordTextField release];
    [super dealloc];
}


@end
