//
//  BoobyTrap3AppDelegate.h
//  BoobyTrap3
//
//  Created by Roderic Campbell on 10/11/09.
//  Copyright Slide 2009. All rights reserved.
//

#import <UIKit/UIKit.h>
@class HomeNavController;
@class LoginViewController;
@class DropTrapsNavController;
@interface BoobyTrap3AppDelegate : NSObject <UIApplicationDelegate> {
    UIWindow *window;
	IBOutlet LoginViewController *loginViewController;
	IBOutlet UITabBarController *rootController;
	IBOutlet HomeNavController *homeNavController;
	IBOutlet DropTrapsNavController *dropTrapsNavController;
}
@property (nonatomic, retain) IBOutlet UIWindow *window;
@property (nonatomic, retain) IBOutlet LoginViewController *loginViewController;
@property (nonatomic, retain) IBOutlet UITabBarController *rootController;
@property (nonatomic, retain) IBOutlet HomeNavController *homeNavController;
@property (nonatomic, retain) IBOutlet DropTrapsNavController *dropTrapsNavController;
@end

