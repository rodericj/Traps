//
//  LoginViewController.h
//  BoobyTrap3
//
//  Created by Roderic Campbell on 10/13/09.
//  Copyright 2009 Slide. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "HomeTableViewController.h"
#import "UserProfile.h"
@interface LoginViewController : UIViewController {
	IBOutlet UITextField *usernameTextField;
	IBOutlet UITextField *passwordTextField;
}
- (IBAction) submitLoginForm;

@property (nonatomic, retain) UITextField *usernameTextField;
@property (nonatomic, retain) UITextField *passwordTextField;

@end
