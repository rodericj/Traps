//
//  LoginViewController.m
//  BoobyTrap3
//
//  Created by Roderic Campbell on 10/13/09.
//  Copyright 2009 Slide. All rights reserved.
//

// Key 3243a6e2dd3a0d084480d05f301cba85
// secret d8611553a286dce3531353b3de53ef2e

#import "LoginViewController.h"
#import "JSON.h"
#import "UserProfile.h"
//#import "FBConnect.h"

@implementation LoginViewController
@synthesize usernameTextField;
@synthesize passwordTextField;

#pragma mark Submit button clicked

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
	
	UserProfile *userProfile = [UserProfile sharedSingleton];
	//userProfile = [[UserProfile alloc] init];
	[userProfile newProfileFromDictionary:resultsDict];
	//[userProfile writeProfile];
	NSLog(@"wrote to file");	
	NSLog(@"username in the object is %@", [userProfile getUserName]);
	//NSLog([resultsDict objectsForKey:@"username"]);

	//if failed login, report the reason and bounce
	
	//once logged in, save this info into the property list then remove modal view
	[self dismissModalViewControllerAnimated:YES];
}

#pragma mark initialization
// Implement viewDidLoad to do additional setup after loading the view, typically from a nib.
- (void)viewDidLoad {
    [super viewDidLoad];
	NSLog(@"LoginViewController did load");
	
//	FBSession *session = [[FBSession sessionForApplication:@"3243a6e2dd3a0d084480d05f301cba85"
//										secret:@"d8611553a286dce3531353b3de53ef2e" 
//										delegate:self] retain];
//	FBLoginButton* button = [[[FBLoginButton alloc] init] autorelease];	
//	[self.view addSubview:button];
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
	[usernameTextField release];
	[passwordTextField release];
    [super dealloc];
}


@end
