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

	NSString *userName;
	int *coinCount;
	int *hitPoints;
	int *damageCaused;  //formerly kill Count
	int *numTrapsSet;
	int *numTrapsTriggered;
	
	UIImage *userImage;
	
}

@property (nonatomic, retain) NSString *userName;
@property (nonatomic, retain) UIImage *userImage;



+ (id)sharedBTUserProfile;

@end
