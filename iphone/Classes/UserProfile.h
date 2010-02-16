//
//  UserProfile.h
//  BoobyTrap3
//
//  Created by Roderic Campbell on 11/17/09.
//  Copyright 2009 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>


@interface UserProfile : NSObject {
	NSDictionary *fbprofile;
	NSDictionary *profile;
	NSArray *locations;
	NSString *whichTrap;
	NSString *whichVenue;
	NSData *userImage;
	int tutorial;
}
@property (nonatomic, retain) NSDictionary *profile;
@property (nonatomic, retain) NSArray *locations;
@property (nonatomic, retain) NSDictionary *fbprofile;
@property (nonatomic, retain) NSData *userImage;
@property (retain) NSString *whichTrap;
@property (retain) NSString *whichVenue;
//@property int tutorial;


+(UserProfile *)sharedSingleton;

//-(void)setWhichTrap:(NSInteger *)whichTrap;
-(void)refreshFromFile;
-(void)clear;

-(void)newProfileFromDictionary:(NSDictionary *)newProfile;
-(void)newFBProfileFromDictionary:(NSDictionary *)newFBProfile;
-(void)newLocationsFromDictionary:(NSArray *)newLocations;
-(NSString *)getUserName;
-(NSInteger *)getCoinCount;
-(NSInteger *)getHitPoints;
-(NSInteger *)getKillCount;
-(NSInteger *)getLevel;
-(NSInteger *)getTrapsSetCount;
-(NSDictionary *)getInventory;
-(NSString *)getPicture;
-(int)getTutorial;
-(void)setTutorial:(int)tutorial;
-(void)printUserProfile;

@end
