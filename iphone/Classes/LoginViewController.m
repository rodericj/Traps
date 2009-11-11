//
//  LoginViewController.m
//  BoobyTrap3
//
//  Created by Roderic Campbell on 10/13/09.
//  Copyright 2009 Slide. All rights reserved.
//

#import "LoginViewController.h"
#import "JSON.h"

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
		
	//call to the web service to see if we can log in
	NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:[NSURL URLWithString:@"http://localhost:8000/IPhoneLogin/"]
										 cachePolicy:NSURLRequestReloadIgnoringLocalCacheData
									 timeoutInterval:60.0];
    [request setHTTPMethod:@"POST"];
    [request setHTTPBody:[[NSString stringWithFormat:@"uname=%@&password=%@&uid=%@", usernameTextField.text, passwordTextField.text,
                           [[UIDevice currentDevice] uniqueIdentifier]] dataUsingEncoding:NSUTF8StringEncoding]];
    [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:YES];
	NSURLResponse *response;
	NSError *error;

	NSData *urlData = [NSURLConnection sendSynchronousRequest:request
									returningResponse:&response
												error:&error];
	NSString *results = [[NSString alloc] initWithData:urlData encoding:NSUTF8StringEncoding];
	NSLog(results);	
	NSLog(@"make it json");

	NSDictionary *resultsDict = [results JSONValue];
	NSLog(@"about to write to file");
	
	[resultsDict writeToFile:@"Profile.plist" atomically:TRUE];
	
	NSLog(@"wrote to file");	


	//NSLog([resultsDict objectsForKey:@"username"]);

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
