//
//  UserProfile.m
//  BoobyTrap3
//
//  Created by Roderic Campbell on 11/17/09.
//  Copyright 2009 __MyCompanyName__. All rights reserved.
//

#import "UserProfile.h"

@implementation UserProfile
@synthesize profile;
@synthesize locations;
@synthesize fbprofile;
@synthesize whichTrap;
@synthesize whichVenue;
+ (UserProfile *)sharedSingleton
{
	static UserProfile *sharedSingleton;
	
	@synchronized(self)
	{
		if (!sharedSingleton){
			sharedSingleton = [[UserProfile alloc] init];
			[sharedSingleton refreshFromFile];
		}
		return sharedSingleton;
	}
}

-(void)refreshFromFile{
	NSUserDefaults *prefs = [NSUserDefaults standardUserDefaults];
	self.fbprofile = [prefs dictionaryForKey:@"fbprofile"];
	self.profile = [prefs dictionaryForKey:@"profile"];
	self.locations = [prefs arrayForKey:@"locations"];
	//[prefs setObject:newFBProfile forKey:@"fbprofile"];
	//self.profile =  [[NSDictionary alloc] initWithContentsOfFile:@"Profile.plist"];
}
-(void)printUserProfile{
	NSLog(@"profile %@  \n fbprofile %@", profile, fbprofile);
}
-(NSString *)getUserName{
	return (NSString *)[fbprofile objectForKey:@"name"];
}
-(NSInteger *)getCoinCount{
	return (NSInteger *)[profile objectForKey:@"coinCount"];
}
-(NSInteger *)getHitPoints{
	return (NSInteger *)[profile objectForKey:@"hitPoints"];
}
-(NSInteger *)getKillCount{
	return (NSInteger *)[profile objectForKey:@"killCount"];
}
-(NSInteger *)getLevel{
	return (NSInteger *)[profile objectForKey:@"level"];
}
-(NSInteger *)getTrapsSetCount{
	return (NSInteger *)[profile objectForKey:@"trapsSetCount"];
}
-(NSDictionary *)getInventory{
	return [profile objectForKey:@"inventory"];
}
-(NSString *)getPicture{
	return [fbprofile objectForKey:@"pic_square"];
}
-(void)clear{
	//FBProfile.p list
	//Profile.p list
}

-(void)newLocationsFromDictionary:(NSArray *)newLocations{
	NSUserDefaults *prefs = [NSUserDefaults standardUserDefaults];
	[prefs setObject:newLocations forKey:@"locations"];
	self.locations = locations;
}

-(void)newFBProfileFromDictionary:(NSDictionary *)newFBProfile{
	NSUserDefaults *prefs = [NSUserDefaults standardUserDefaults];
	[prefs setObject:newFBProfile forKey:@"fbprofile"];
	self.fbprofile = newFBProfile;
	NSLog(@"writing the fbprofile to fbprofile.p list");
	//[newFBProfile writeToFile:@"FBProfile.plist" atomically:TRUE];
//	if(fbprofile != newFBProfile){
//		[fbprofile release];
//		fbprofile = [newFBProfile copy];
//	}
}

-(void)newProfileFromDictionary:(NSDictionary *)newProfile{
	NSUserDefaults *prefs = [NSUserDefaults standardUserDefaults];
	[prefs setObject:newProfile forKey:@"profile"];
	self.profile = newProfile;
	
	//[newProfile writeToFile:@"Profile.plist" atomically:TRUE];
//	if(profile != newProfile){
//		[profile release];
//		profile = [newProfile copy];
//	}
}
@end
