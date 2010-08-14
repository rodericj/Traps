//
//  NetworkErrorHandler.m
//  Traps
//
//  Created by Roderic Campbell on 8/12/10.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

//#import "NetworkErrorHandler.h"
#import "UITableViewController+NetworkErrorHandler.h"


@implementation UITableViewController (NetworkErrorHandler)
- (void)handleError{
	NSLog(@"the error handler will take it from here");
	UIAlertView *alert;
	alert = [[UIAlertView alloc] initWithTitle:@"Network Issue" message:@"Looks like we are having some network issues" delegate:self cancelButtonTitle:@"Ok" otherButtonTitles:nil]; 
	[alert show];
	[alert release];
}

@end
