//
//  NetworkRequestOperation.m
//  BoobyTrap3
//
//  Created by Roderic Campbell on 11/25/09.
//  Copyright 2009 __MyCompanyName__. All rights reserved.
//

#import "NetworkRequestOperation.h"
#import "BoobyTrap3AppDelegate.h"
#import "SBJSON.H"

@implementation NetworkRequestOperation
@synthesize targetURL;
@synthesize arguments;
@synthesize callingDelegate;

-(void)dealloc {
	[targetURL release], targetURL=nil;
	[super dealloc];
}

-(void) start{
	NSLog(@"1 Going to this target %@", targetURL);
	BoobyTrap3AppDelegate *delegate = [[UIApplication sharedApplication] delegate];
	NSLog(@"2 Going to this the server address %@", [delegate serverAddress]);
	NSString *target = [NSString stringWithFormat:@"%@/%@/", [delegate serverAddress], targetURL];
	NSLog(@"3 Now Going to this URL %@", target);

	//Set the arguments up
	NSString *argString = [[[NSString alloc] initWithString:@""] autorelease];
	for(NSString *argument in arguments){
		argString = [argString stringByAppendingString:[NSString stringWithFormat:@"%@=%@&", argument, [arguments objectForKey:argument]]];
	}
	argString = [argString stringByAppendingString:[NSString stringWithFormat:@"%@=%@", @"deviceID", [[UIDevice currentDevice] uniqueIdentifier]]];
	NSLog(@"argString is %@", argString);
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
	[[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:YES];

	NSString *results = [[[NSString alloc] initWithData:urlData encoding:NSUTF8StringEncoding] autorelease];	
	//NSDictionary *resultsDict = [results JSONValue];
	
	SBJsonParser *parser = [SBJsonParser new];
	NSDictionary* resultsDict = [parser objectWithString: results];
	[parser release];

	
	NSLog(@"results Dict from Network request %@", resultsDict);
	[[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:NO];

	[callingDelegate performSelectorOnMainThread:@selector(pageLoaded:)
                                           withObject:resultsDict
                                        waitUntilDone:NO];
}

@end
