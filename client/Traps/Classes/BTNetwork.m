//
//  BTNetwork.m
//  Traps
//
//  Created by Roderic Campbell on 3/14/10.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import "BTNetwork.h"

#import "BTInvocationMaker.h"
#import "BTNetworkHttp.h"

static BTNetwork *sharedBTNetwork = nil;

@implementation BTNetwork

#pragma mark -
#pragma mark Singleton

+ (id)sharedNetwork {
	@synchronized(self) {
		if (sharedBTNetwork == nil) {
			[[self alloc] init]; // assignment not done here
		}
	}
	return sharedBTNetwork;
}


+ (id)allocWithZone:(NSZone *)zone {
	@synchronized(self) {
		if (sharedBTNetwork == nil) {
			sharedBTNetwork = [super allocWithZone:zone];
			
			return sharedBTNetwork; // assignment and return on first allocation
		}
	}
	
	return nil; // on subsequent allocation attempts, return nil
}

- (id)copyWithZone:(NSZone *)zone {
	return self;
}

- (id)retain {
	return self;
}

- (unsigned)retainCount {
	return UINT_MAX; // denotes an object that cannot be released
}

- (void)release {
	// do nothing
}

- (id)autorelease {
	return self;
}

#pragma mark -
#pragma mark Initialization

-(id) init{
	if ((self=[super init]) == nil) {
		return nil;
	}
	
	//setting up http operation queue
	httpOperationQueue = [[NSOperationQueue alloc] init];
	[httpOperationQueue setMaxConcurrentOperationCount:2];
	
	return self;
}

#pragma mark -
#pragma mark Network

- (oneway void)performHttpOperationWithResponseObject:(id)responseObject
									  methodSignature:(NSString *)methodSignature
											   method:(NSString *)method
											   domain:(NSString *)domain
										  relativeURL:(NSString *)relativeURL
											   params:(NSDictionary *)params
											  headers:(NSArray *)headers{
	// Create an invocation for the operation queue
	BTNetworkHttp *networkHTTP = [BTNetworkHttp networkHttpWithResponseObject:responseObject
															  methodSignature:methodSignature];
	BTInvocationMaker *makeNetworkHTTP = [[BTInvocationMaker alloc]
										  initWithTarget:networkHTTP];
	
	// Setup the invocation
	[(BTNetworkHttp *)makeNetworkHTTP performHTTPRequestWithMethod:method
														hostDomain:domain
													   relativeURL:relativeURL
															params:params
														   headers:headers];
	
	// Add the invocation onto the operation queue
	NSInvocationOperation *httpOperation = [[NSInvocationOperation alloc]
											initWithInvocation:makeNetworkHTTP.invocation];
	NSLog(@"adding operation %@", relativeURL);
	[httpOperationQueue addOperation:httpOperation];
	[httpOperation release];
	
	[makeNetworkHTTP release];
}

@end
