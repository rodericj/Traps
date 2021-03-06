//
//  BTLeaderboardInternalViewController.h
//  Traps
//
//  Created by Roderic Campbell on 3/14/10.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "BTConstants.h"
#import "UITableViewController+NetworkErrorHandler.h"
#import "FBConnect/FBConnect.h"

@interface BTLeaderboardInternalViewController : UITableViewController <FBSessionDelegate, FBRequestDelegate>{
	FBSession *session;
	NSArray *friendsWithApp;
	UIActivityIndicatorView* _spinner;
	bool spinnerDead;
}

@property (nonatomic, retain) NSArray *friendsWithApp;

- (UITableViewCell *) getFriendCell:(NSString *)cellIdentifier friend:(NSDictionary *)friend;

- (void)didGetFriends:(id)responseString;
- (UITableViewCell *) getBlankCell:(NSString *)cellIdentifier;
@end
