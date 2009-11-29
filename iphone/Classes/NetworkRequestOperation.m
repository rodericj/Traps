//
//  NetworkRequestOperation.m
//  BoobyTrap3
//
//  Created by Roderic Campbell on 11/25/09.
//  Copyright 2009 __MyCompanyName__. All rights reserved.
//

#import "NetworkRequestOperation.h"
#import "BoobyTrap3AppDelegate.h"
#import "JSON.H"

@implementation NetworkRequestOperation
@synthesize targetURL;
@synthesize arguments;
@synthesize callingDelegate;

-(void)dealloc {
	[targetURL release], targetURL=nil;
	[super dealloc];
}

-(void) main{
	NSLog(@"starting network comm...set up the arguments later yeah?");
	NSLog(@"Going to this URL %@", targetURL);
	BoobyTrap3AppDelegate *delegate = [[UIApplication sharedApplication] delegate];
	NSLog(@"%s", [delegate serverAddress]);
	NSString *target = [NSString stringWithFormat:@"%@/%@/", [delegate serverAddress], targetURL];
	NSLog(@"Going to this URL %s", target);

	//Set the arguments up
	NSString *argString = [[NSString alloc] initWithString:@""];
	for(NSString *argument in arguments){
		argString = [argString stringByAppendingString:[NSString stringWithFormat:@"%@=%@&", argument, [arguments objectForKey:argument]]];
	}
	argString = [argString stringByAppendingString:[NSString stringWithFormat:@"%@=%@", @"deviceID", [[UIDevice currentDevice] uniqueIdentifier]]];

	//call to the web service to see if we can log in
	NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:[NSURL URLWithString:target]
														   cachePolicy:NSURLRequestReloadIgnoringLocalCacheData
													   timeoutInterval:5.0];
    [request setHTTPMethod:@"POST"];
    [request setHTTPBody:[argString dataUsingEncoding:NSUTF8StringEncoding]];
    [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:YES];
	NSURLResponse *response;
	NSError *error;

	NSData *urlData = [NSURLConnection sendSynchronousRequest:request
											returningResponse:&response
														error:&error];

	NSString *results = [[NSString alloc] initWithData:urlData encoding:NSUTF8StringEncoding];	
	NSDictionary *resultsDict = [results JSONValue];
	[callingDelegate performSelectorOnMainThread:@selector(pageLoaded:)
                                           withObject:resultsDict
                                        waitUntilDone:YES];
}

@end
