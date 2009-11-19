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
		if (!sharedSingleton)
			sharedSingleton = [[UserProfile alloc] init];
			//profile = [NSDictionary initWithContentsOfFile:@"Profile.plist"];

		return sharedSingleton;
	}
}



//@synthesize profile;
//- (id)initWithDictionary:(NSDictionary *)dict{
//	if(self = [super init]){
//		self.profile = dict;
//		[profile writeToFile:@"Profile.p list" atomically:YES];
//	}
//	return self;
//}
//-(UserProfile *)loadProfile{
//	profile = [[NSDictionary alloc] initWithContentsOfFile:@"Profile.p list"];
//	//profile = [NSDictionary dictionaryWithContentsOfFile:@"Profile.p list"];
//	return self;
//}

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
	//self.profile = newProfile;
	if(profile != newProfile){
		[profile release];
		profile = [newProfile copy];
	}
	//self.whichTrap = [NSInteger* alloc];
}

//-(void)setWhichTrap:(NSInteger *)newWhichTrap{
//	NSLog(newWhichTrap);
//	if(self.whichTrap != newWhichTrap){
//		[self.whichTrap release];
//		self.whichTrap = [newWhichTrap copy];
//	}
//}

@end
