//
//  BTNetwork.m
//  Traps
//
//  Created by Roderic Campbell on 3/14/10.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import "BTNetwork.h"

static BTNetwork *sharedBTNetwork = nil;

@implementation BTNetwork
#pragma mark -
#pragma mark Singleton

+ (id)sharedBTNetwork {
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
#pragma mark initialization
-(id) init{
	if ((self=[super init]) == nil) {
		return nil;
	}
	
	//setting up http operation queue
	httpOperationQueue = [[NSOperationQueue alloc] init];
	[httpOperationQueue setMaxConcurrentOperationCount:2];
	
	return self;
}


@end
