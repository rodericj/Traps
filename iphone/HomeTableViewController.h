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
@class FBSessionDelegate;
@interface HomeTableViewController : UITableViewController <FBDialogDelegate, FBSessionDelegate, UITableViewDelegate, UITableViewDataSource>{
	IBOutlet UITableView *homeTableView;
	NSMutableArray *menuArray;
	ProfileViewController *profileViewController;
	IBOutlet UILabel *userName;
	IBOutlet UILabel *userLevel;
	IBOutlet UILabel *userCoinCount;
	IBOutlet UIImageView *userImage;
	
	FBSession *session;
}
-(void)updateMiniProfile:(NSDictionary *)profile;

@property (nonatomic, retain) NSMutableArray *menuArray;
@property (nonatomic, retain) ProfileViewController *profileViewController;
@property (nonatomic, retain) UILabel *userName;
@property (nonatomic, retain) UILabel *userLevel;
@property (nonatomic, retain) UILabel *userCoinCount;
@property (nonatomic, retain) UIImageView *userImage;
@end
