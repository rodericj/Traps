//
//  BTNetworkHttp.m
//  Traps
//
//  Created by Roderic Campbell on 3/14/10.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import "BTNetworkHttp.h"

#import "NSString+URLAdditions.h"

NSString *const kHTTPRequestError = @"HTTPRequestError";

@interface BTNetworkHttp (Internal)
- (NSString *)createKeyValuePairs:(NSDictionary *)params;

- (void)resetState;
@end

@implementation BTNetworkHttp

#pragma mark -
#pragma mark Initialization

+ (id)networkHttpWithResponseObject:(id)responseObject methodSignature:(NSString *)methodSignature {
	return [[[BTNetworkHttp alloc]
			 initWithResponseObject:responseObject methodSignature:methodSignature]
			autorelease];
}

- (id)initWithResponseObject:(id)responseObject methodSignature:(NSString *)methodSignature {
	if ((self = [super init]) == nil) {
		return nil;
	}
	
	_responseObject = [responseObject retain];
	_responseMethodSignature = [methodSignature retain];
	
	return self;
}

#pragma mark -
#pragma mark BTNetworkHttp

- (NSString *)createKeyValuePairs:(NSDictionary *)params {	
	if (!params) {
		return @"";
	}
	
	NSMutableArray *parameterArray = [[NSMutableArray alloc] initWithCapacity:[params count]];
	
	NSEnumerator *keyEnumerator = [params keyEnumerator];
	NSString *key;
	while((key = [keyEnumerator nextObject])) {
		[parameterArray addObject:[NSString stringWithFormat:@"%@=%@",
								   key,
								   [(NSString *)[params objectForKey:key] urlEncode]]];
	}
	
	NSString *keyValuePairs = [parameterArray componentsJoinedByString:@"&"];
	[parameterArray release];
	
	return keyValuePairs;
}

- (void)resetState {
	RELEASE_SAFELY(_data);
	
	RELEASE_SAFELY(_responseObject);
	RELEASE_SAFELY(_responseMethodSignature);
}

#pragma mark -
#pragma mark Network

- (void)performHTTPRequestWithMethod:(NSString *)method
						  hostDomain:(NSString *)domain
						 relativeURL:(NSString *)relativeURL
							  params:(NSDictionary *)params 
							 headers:(NSArray *)headers{
	_data		= [[NSMutableData alloc] init];
	
	NSString *keyValuePairs = [self createKeyValuePairs:params];
	NSMutableURLRequest *request;
	NSString *urlString = [NSString stringWithFormat:@"http://%@/%@", domain, relativeURL];

	if ([method compare:@"GET" options:NSCaseInsensitiveSearch] == NSOrderedSame) {
		if ([keyValuePairs length] > 0) {
			urlString = [NSString stringWithFormat:@"%@?%@", urlString, keyValuePairs];
		}
		request = [NSMutableURLRequest requestWithURL:[NSURL URLWithString:urlString]];
		[request setHTTPMethod:@"GET"];
	} else {
		request = [NSMutableURLRequest requestWithURL:[NSURL URLWithString:urlString]];
		[request setHTTPMethod:@"POST"];
		[request setHTTPBody:[keyValuePairs dataUsingEncoding:NSUTF8StringEncoding]];
	}
	
	if(headers != nil){
		int count = 0;
		while (count < headers.count){
			NSLog(@"adding %@, %@ to headers", [headers objectAtIndex:count], [headers objectAtIndex:count+1]);
			[request addValue:[headers objectAtIndex:count] forHTTPHeaderField:[headers objectAtIndex:count+1]];
			NSLog(@"we've added %@, %@ to headers", [headers objectAtIndex:count], [headers objectAtIndex:count+1]);
			
			count += 2;
		}
	}
	[request setValue:@"BoobyTraps/1.0 (iPhone)" forHTTPHeaderField:@"User-Agent"];
	[request setValue:@"gzip" forHTTPHeaderField:@"Accept-Encoding"];
	[request setCachePolicy:NSURLRequestReloadIgnoringLocalAndRemoteCacheData];
	[request setTimeoutInterval:3.0f];
	
	NSURLConnection *connection = [[NSURLConnection alloc]
								   initWithRequest:request delegate:self startImmediately:NO];
	
	[connection scheduleInRunLoop:[NSRunLoop currentRunLoop] forMode:kNetworkHTTPRunMode];
	[connection start];
	
	while(!_finished) {
		[[NSRunLoop currentRunLoop] runMode:kNetworkHTTPRunMode beforeDate:[NSDate distantFuture]];
	}
	
	//XXX: finished http request
	[connection release];
}

# pragma mark -
# pragma mark NSURLConnectionDelegate

- (void)connection:(NSURLConnection *)connection didReceiveResponse:(NSURLResponse *)response {
	if ([response respondsToSelector:@selector(statusCode)]) {
		int statusCode = [((NSHTTPURLResponse *)response) statusCode];
		if (statusCode >= 400) {
			[connection cancel];
			
			NSError *error = [NSError errorWithDomain:kHTTPRequestError
												 code:statusCode
											 userInfo:nil];
			[self connection:connection didFailWithError:error];
			
			return;
		}
	}
	
	[_data setLength:0];
}

- (NSCachedURLResponse *)connection:(NSURLConnection *)connection
				  willCacheResponse:(NSCachedURLResponse *)cachedResponse {
	return nil;
}

- (void)connection:(NSURLConnection *)connection didReceiveData:(NSData *)data {
	[_data appendData:data];
}

- (void)connection:(NSURLConnection *)connection didFailWithError:(NSError *)error {
	_finished = YES;
	
	SEL selector = NSSelectorFromString(_responseMethodSignature);
	[_responseObject performSelectorOnMainThread:selector withObject:error waitUntilDone:NO];
	
	[self resetState];
}

- (void)connectionDidFinishLoading:(NSURLConnection *)connection {
	_finished = YES;
	
	SEL selector = NSSelectorFromString(_responseMethodSignature);
	[_responseObject performSelectorOnMainThread:selector withObject:_data waitUntilDone:NO];
	
	[self resetState];
}

@end
