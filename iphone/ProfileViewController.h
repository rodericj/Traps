//
//  ProfileViewController.h
//  BoobyTrap3
//
//  Created by Roderic Campbell on 10/11/09.
//  Copyright 2009 Slide. All rights reserved.
//

#import <UIKit/UIKit.h>


@interface ProfileViewController : UIViewController {
	IBOutlet UILabel *usernameLabel;
	IBOutlet UILabel *coinsLabel;
	IBOutlet UILabel *hpLabel;
	IBOutlet UILabel *killLabel;	
	IBOutlet UILabel *levelLabel;
	IBOutlet UILabel *totalTrapsLabel;
	IBOutlet UILabel *activeTrapsLabel;
	IBOutlet UIImageView *userImage;

}
@property (nonatomic, retain) UILabel *usernameLabel;
@property (nonatomic, retain) UILabel *coinsLabel;
@property (nonatomic, retain) UILabel *hpLabel;
@property (nonatomic, retain) UILabel *killLabel;
@property (nonatomic, retain) UILabel *levelLabel;
@property (nonatomic, retain) UILabel *totalTrapsLabel;
@property (nonatomic, retain) UILabel *activeTrapsLabel;
@property (nonatomic, retain) UIImageView *userImage;


@end
