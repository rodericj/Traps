//
//  BoobyTrap3AppDelegate.h
//  BoobyTrap3
//
//  Created by Roderic Campbell on 10/11/09.
//  Copyright Slide 2009. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "FBConnect/FBConnect.h"

@class HomeNavController;
@class DropTrapsNavController;
@interface BoobyTrap3AppDelegate : NSObject <UIApplicationDelegate> {
    UIWindow *window;
	IBOutlet UITabBarController *rootController;
	IBOutlet HomeNavController *homeNavController;
	IBOutlet DropTrapsNavController *dropTrapsNavController;
	FBSession *session;
	NSString *serverAddress;
	NSString *deviceToken;
	NSOperationQueue *queue;

}

@property (nonatomic, retain) NSString *deviceToken;
@property (retain) FBSession *session;
@property (nonatomic, retain) NSString *serverAddress;
@property (nonatomic, retain) IBOutlet UIWindow *window;
@property (nonatomic, retain) IBOutlet UITabBarController *rootController;
@property (nonatomic, retain) IBOutlet HomeNavController *homeNavController;
@property (nonatomic, retain) IBOutlet DropTrapsNavController *dropTrapsNavController;
@end

