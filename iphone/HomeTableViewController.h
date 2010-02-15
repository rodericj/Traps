//
//  HomeTableViewController.h
//  BoobyTrap3
//
//  Created by Roderic Campbell on 10/11/09.
//  Copyright 2009 Slide. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "FBConnect/FBConnect.h"

@class ProfileViewController;
@class DropTrapsNavController;
@class NearbyPlacesTableView;
@class FBSessionDelegate;
@class UserProfile;

@interface HomeTableViewController : UITableViewController <FBRequestDelegate, FBDialogDelegate, FBSessionDelegate, UITableViewDelegate, UITableViewDataSource>{
	IBOutlet UITableView *homeTableView;
	NSMutableArray *menuArray;
	ProfileViewController *profileViewController;
	DropTrapsNavController *dropTrapsNavController;
	//NearbyPlacesTableView *nearbyPlacesTableViewController;
	IBOutlet UILabel *userName;
	IBOutlet UILabel *userLevel;
	IBOutlet UILabel *userCoinCount;
	IBOutlet UILabel *userTrapsSet;
	IBOutlet UILabel *userHitPoints;
	IBOutlet UILabel *userKillCount;
	IBOutlet UIImageView *userImage;
	
	BOOL hasAppeared;

	NSOperationQueue *queue;
	FBSession *mySession;
}
- (void)updateMiniProfile:(UserProfile *)profile;
- (void)pageLoaded:(NSDictionary*)webRequestResults;
- (IBAction)dropTrapButtonPushed;

@property (nonatomic, retain) NSMutableArray *menuArray;
@property (nonatomic, retain) ProfileViewController *profileViewController;
@property (nonatomic, retain) DropTrapsNavController *dropTrapsNavController;
//@property (nonatomic, retain) NearbyPlacesTableView *nearbyPlacesTableViewController;
@property (nonatomic, retain) UILabel *userName;
@property (nonatomic, retain) UILabel *userLevel;
@property (nonatomic, retain) UILabel *userCoinCount;
@property (nonatomic, retain) UILabel *userTrapsSet;
@property (nonatomic, retain) UILabel *userHitPoints;
@property (nonatomic, retain) UILabel *userKillCount;
@property (nonatomic, retain) UIImageView *userImage;
@end
