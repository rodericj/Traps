//
//  HomeTableViewController.h
//  BoobyTrap3
//
//  Created by Roderic Campbell on 10/11/09.
//  Copyright 2009 Slide. All rights reserved.
//

#import <UIKit/UIKit.h>
@class ProfileViewController;

@interface HomeTableViewController : UITableViewController <UITableViewDelegate, UITableViewDataSource>{
	IBOutlet UITableView *homeTableView;
	NSMutableArray *menuArray;
	ProfileViewController *profileViewController;
	IBOutlet UILabel *userName;
	IBOutlet UILabel *userLevel;
	IBOutlet UILabel *userCoinCount;
}

@property (nonatomic, retain) NSMutableArray *menuArray;
@property (nonatomic, retain) ProfileViewController *profileViewController;
@property (nonatomic, retain) UILabel *userName;
@property (nonatomic, retain) UILabel *userLevel;
@property (nonatomic, retain) UILabel *userCoinCount;
@end
