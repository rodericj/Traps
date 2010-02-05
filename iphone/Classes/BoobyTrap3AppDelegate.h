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

#define CURRENT_DATA_VERSION	0

#define HOST_IS_PROD		0
#define HOST_IS_DEV			1
#define HOST_IS_STAGING		2

#define FB_VIRAL_ON		0

#if defined(TARGET_IPHONE_SIMULATOR) 

#if(CURRENT_DATA_VERSION == HOST_IS_DEV)
#define REMOTE_SERVER  @"http://localhost:8000"
#endif

#if(CURRENT_DATA_VERSION == HOST_IS_STAGING)
#define REMOTE_SERVER  @"http://192.168.1.101:8000"
#endif

#if(CURRENT_DATA_VERSION == HOST_IS_PROD)
#define REMOTE_SERVER  @"http://rodericj.webfactional.com"
#endif

#else
#define REMOTE_SERVER  @"http://rodericj.webfactional.com"
#endif

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

