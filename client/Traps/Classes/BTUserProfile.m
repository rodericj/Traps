//
//  BTUserProfile.m
//  Traps
//
//  Created by Roderic Campbell on 3/14/10.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import "BTUserProfile.h"

static BTUserProfile *sharedBTUserProfile = nil;

@implementation BTUserProfile

@synthesize firstName;
@synthesize lastName;
@synthesize userImage;

@synthesize selectedTrapProcessed;
@synthesize selectedTrap;
@synthesize coinCount;
@synthesize hitPoints;
@synthesize damageCaused;
@synthesize numTrapsSet;
@synthesize numTrapsTriggered;
@synthesize deviceToken;
@synthesize userBase64EncodedPassword;

@synthesize _oauthAPI;

#pragma mark -
#pragma mark Singleton

+ (id)sharedBTUserProfile {
	@synchronized(self) {
		if (sharedBTUserProfile == nil) {
			[[self alloc] init]; // assignment not done here
			[sharedBTUserProfile setSelectedTrap:-1];
		}
	}
	return sharedBTUserProfile;
}


+ (id)allocWithZone:(NSZone *)zone {
	@synchronized(self) {
		if (sharedBTUserProfile == nil) {
			sharedBTUserProfile = [super allocWithZone:zone];
			
			return sharedBTUserProfile; // assignment and return on first allocation
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

@end
