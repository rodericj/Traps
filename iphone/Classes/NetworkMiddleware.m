//
//  NetworkMiddleware.m
//  BoobyTrap3
//
//  Created by Roderic Campbell on 11/2/09.
//  Copyright 2009 Slide. All rights reserved.
//

#import "NetworkMiddleware.h"


@implementation NetworkMiddleware
@synthesize viewName;
@synthesize postData;

-(NSData *) makeRequest{

	NSString *url = [NSString stringWithFormat:@"http://localhost:8000/%@", viewName];
	NSLog(url);
	NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:[NSURL URLWithString:@"http://localhost:8000/FindNearby/"]
														   cachePolicy:NSURLRequestReloadIgnoringLocalCacheData
													   timeoutInterval:60.0];
    [request setHTTPMethod:@"POST"];
    [request setHTTPBody:[[NSString stringWithFormat:@"ld=%@&uid=%@", postData] dataUsingEncoding:NSUTF8StringEncoding]];
    [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:YES];
	NSURLResponse *response;
	NSError *error;
	NSData *urlData = [NSURLConnection sendSynchronousRequest:request
											returningResponse:&response
														error:&error];
	NSLog(@"get the url");
	NSString *results = [[NSString alloc] initWithData:urlData encoding:NSUTF8StringEncoding];
	
}

@end
