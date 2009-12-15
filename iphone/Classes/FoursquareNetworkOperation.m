//
//  FoursquareNetworkOperation.m
//  BoobyTrap3
//
//  Created by Roderic Campbell on 12/8/09.
//  Copyright 2009 __MyCompanyName__. All rights reserved.
//

#import "FoursquareNetworkOperation.h"


@implementation FoursquareNetworkOperation
//@synthesize arguments;


-(void)main{
	NSString *target = [NSString stringWithFormat:@"%@/%@", @"http://api.foursquare.com/v1", targetURL];
	NSLog(@"length of arguments: %d", [arguments count]);
	NSString *argString = [[NSString alloc] initWithString:@""];
	for(NSString *argument in arguments){
		argString = [argString stringByAppendingString:[NSString stringWithFormat:@"%@=%@&", argument, [arguments objectForKey:argument]]];
	}
	//argString = [argString stringByAppendingString:[NSString stringWithFormat:@"%@=%@", @"deviceID", [[UIDevice currentDevice] uniqueIdentifier]]];
	NSLog(@"argString is: %@", argString);
	NSMutableURLRequest *request;
	NSURLResponse *response;
	NSError *error;
	NSData *urlData;
	if(isPost){
		request = [NSMutableURLRequest requestWithURL:[NSURL URLWithString:target]
															   cachePolicy:NSURLRequestReloadIgnoringLocalCacheData
														   timeoutInterval:5.0];
		[request setHTTPMethod:@"POST"];
		[request setHTTPBody:[argString dataUsingEncoding:NSUTF8StringEncoding]];
		[[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:YES];
		urlData = [NSURLConnection sendSynchronousRequest:request
												returningResponse:&response
															error:&error];
		
	}
	else{
		NSString *url = [NSString stringWithFormat:@"%@?%@", target, argString];
		NSURL *nsUrl = [NSURL URLWithString:url];
		urlData = [NSData dataWithContentsOfURL:nsUrl];
		NSLog(@"The url for the get is: %@", url);
		NSLog(@"The args are %@", argString);
		//request = [NSMutableURLRequest requestWithURL:[NSURL URLWithString:target]
//														cachePolicy:NSURLRequestReloadIgnoringLocalCacheData
//														timeoutInterval:5.0];
//		[request setHTTPMethod:@"GET"];
	}
	
	
	NSString *results = [[NSString alloc] initWithData:urlData encoding:NSUTF8StringEncoding];	
	NSDictionary *resultsDict = [results JSONValue];
	NSLog(@"returned from foursquare: %@", resultsDict);
	[callingDelegate performSelectorOnMainThread:@selector(pageLoaded:)
									  withObject:resultsDict
								   waitUntilDone:YES];
	//NSLog(@"returned the thing to the main thread");
	
}
@end