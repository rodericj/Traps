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
	NSString *whichTrap;
	NSString *whichVenue;
}
@property (nonatomic, retain) NSDictionary *profile;
@property (nonatomic, retain) NSDictionary *fbprofile;
@property (retain) NSString *whichTrap;
@property (retain) NSString *whichVenue;


+(UserProfile *)sharedSingleton;

//-(void)setWhichTrap:(NSInteger *)whichTrap;
-(void)refreshFromFile;
-(void)clear;

-(void)newProfileFromDictionary:(NSDictionary *)newProfile;
-(void)newFBProfileFromDictionary:(NSDictionary *)newFBProfile;
-(NSString *)getUserName;
-(NSInteger *)getCoinCount;
-(NSInteger *)getHitPoints;
-(NSInteger *)getKillCount;
-(NSInteger *)getLevel;
-(NSInteger *)getTrapsSetCount;
-(NSDictionary *)getInventory;
-(NSString *)getPicture;

@end
