    //
//  BTTabBarController.m
//  Traps
//
//  Created by Kelvin Kakugawa on 3/14/10.
//  Copyright 2010 Apple Inc. All rights reserved.
//

#import "BTTabBarController.h"

static BTTabBarController *sharedBTTabBarController = nil;

@implementation BTTabBarController

#pragma mark -
#pragma mark Singleton

+ (id)sharedTabBarController {
	@synchronized(self) {
		if (sharedBTTabBarController == nil) {
			[[self alloc] init]; // assignment not done here
		}
	}
	
	return sharedBTTabBarController;
}

+ (id)allocWithZone:(NSZone *)zone {
	@synchronized(self) {
		if (sharedBTTabBarController == nil) {
			sharedBTTabBarController = [super allocWithZone:zone];
			
			return sharedBTTabBarController; // assignment and return on first allocation
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
#pragma mark PBTabBarController

@end
