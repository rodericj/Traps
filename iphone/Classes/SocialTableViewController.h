//
//  SocialTableViewController.h
//  BoobyTrap3
//
//  Created by Roderic Campbell on 11/21/09.
//  Copyright 2009 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "FBConnect/FBConnect.h"

@interface SocialTableViewController : UITableViewController <FBSessionDelegate, FBRequestDelegate>{
	NSArray *friendsWithApp;
	FBSession *session;
	NSOperationQueue *queue;

}
@property (nonatomic, retain) NSArray *friendsWithApp;

//- (UITableViewCell *) getCellContentView:(NSString *)cellIdentifier;
@end
