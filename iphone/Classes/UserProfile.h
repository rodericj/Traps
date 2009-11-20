//
//  UserProfile.h
//  BoobyTrap3
//
//  Created by Roderic Campbell on 11/17/09.
//  Copyright 2009 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>


@interface UserProfile : NSObject {
	NSInteger *coinCount;
	NSInteger *hitPoints;
	NSArray *inventory;
	NSInteger *killCount;
	NSInteger *level;
	NSInteger *trapsSetCount;
	NSString *userName;
	NSDictionary *profile;
	NSString *whichTrap;
	NSString *whichVenue;
}
@property (nonatomic) NSDictionary *profile;
@property (retain) NSString *whichTrap;
@property (retain) NSString *whichVenue;


+(UserProfile *)sharedSingleton;

//-(void)setWhichTrap:(NSInteger *)whichTrap;
-(BOOL)exists;
-(void)refreshFromFile;


-(UserProfile *)loadProfile;
-(void)newProfileFromDictionary:(NSDictionary *)newProfile;
-(NSString *)getUserName;
-(NSInteger *)getCoinCount;
-(NSInteger *)getHitPoints;
-(NSInteger *)getKillCount;
-(NSInteger *)getLevel;
-(NSInteger *)getTrapsSetCount;
-(NSDictionary *)getInventory;

@end
