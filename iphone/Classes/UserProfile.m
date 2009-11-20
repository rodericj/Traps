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
	self.profile =  [[NSDictionary alloc] initWithContentsOfFile:@"Profile.plist"];
}

-(NSString *)getUserName{
	return (NSString *)[self.profile objectForKey:@"username"];
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


-(BOOL)exists{
	NSDictionary *newprofile = [[NSDictionary alloc]initWithContentsOfFile:@"Profile.plist"];
	[self newProfileFromDictionary:newprofile];
	return [profile objectForKey:@"username"] != NULL;
}

-(void)newProfileFromDictionary:(NSDictionary *)newProfile{
	[newProfile writeToFile:@"Profile.plist" atomically:TRUE];
	if(profile != newProfile){
		[profile release];
		profile = [newProfile copy];
	}
}



@end
