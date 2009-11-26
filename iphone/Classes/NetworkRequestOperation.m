//
//  NetworkRequestOperation.m
//  BoobyTrap3
//
//  Created by Roderic Campbell on 11/25/09.
//  Copyright 2009 __MyCompanyName__. All rights reserved.
//

#import "NetworkRequestOperation.h"


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
	NSLog(@"%@", targetURL);
	
	//Set the arguments up
	NSString *argString = [[NSString alloc] initWithString:@""];
	for(NSString *argument in arguments){
		argString = [argString stringByAppendingString:[NSString stringWithFormat:@"%@=%@&", argument, [arguments objectForKey:argument]]];
		//NSLog(@"argument: %@ value: %@", argument, [arguments objectForKey:argument]);
	}
	argString = [argString stringByAppendingString:[NSString stringWithFormat:@"%@=%@", @"deviceID", [[UIDevice currentDevice] uniqueIdentifier]]];
	NSLog(argString);

	//call to the web service to see if we can log in
	NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:[NSURL URLWithString:targetURL]
														   cachePolicy:NSURLRequestReloadIgnoringLocalCacheData
													   timeoutInterval:5.0];
	NSLog(@"set up the request");
    [request setHTTPMethod:@"POST"];
    [request setHTTPBody:[argString dataUsingEncoding:NSUTF8StringEncoding]];
    [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:YES];
	NSURLResponse *response;
	NSError *error;
	NSLog(@"execute the request");

	NSData *urlData = [NSURLConnection sendSynchronousRequest:request
											returningResponse:&response
														error:&error];
	NSLog(@"get the results");

	NSString *results = [[NSString alloc] initWithData:urlData encoding:NSUTF8StringEncoding];
	//NSLog(results);	
	NSLog(@"make it json");
	
	NSDictionary *resultsDict = [results JSONValue];
	[callingDelegate performSelectorOnMainThread:@selector(pageLoaded:)
                                           withObject:resultsDict
                                        waitUntilDone:YES];
	
	
}

@end
