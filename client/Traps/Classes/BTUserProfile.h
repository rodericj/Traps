//
//  BTUserProfile.h
//  Traps
//
//  Created by Roderic Campbell on 3/14/10.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

//TODO: This gives me an error. Possibly missing a framework? Do I need this framework? Seems like no. Kelvin? #import <Cocoa/Cocoa.h>
#import <UIKit/UIKit.h>

@interface BTUserProfile : NSObject {

	NSString *firstName;
	NSString *lastName;

	int coinCount;
	int hitPoints;
	int damageCaused;  //formerly kill Count
	int numTrapsSet;
	int numTrapsTriggered;
	
	UIImage *userImage;
	
}

@property (nonatomic, retain) NSString *firstName;
@property (nonatomic, retain) NSString *lastName;
@property (nonatomic, retain) UIImage *userImage;

@property (nonatomic) int coinCount;
@property (nonatomic) int hitPoints;
@property (nonatomic) int damageCaused;
@property (nonatomic) int numTrapsSet;
@property (nonatomic) int numTrapsTriggered;



+ (id)sharedBTUserProfile;

@end
