//
//  BTHomeInternalViewController.h
//  Traps
//
//  Created by Kelvin Kakugawa on 3/14/10.
//  Copyright 2010 Apple Inc. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "FBConnect.h"
#import "BTConstants.h"

@interface BTHomeInternalViewController : UITableViewController <UITableViewDataSource, FBRequestDelegate, FBSessionDelegate, FBDialogDelegate> {
	FBSession *mySession;

}

#pragma mark -
#pragma mark Network Response
- (void)ProfileLoaded:(id)response;

#pragma mark -
#pragma mark Button Pushers
- (void)dropTrapButtonPushed;


//Cell Builders
- (UITableViewCell *) getButtonCell:(NSString *)cellIdentifier;
- (UITableViewCell *) getFBUserInfoCell:(NSString *)cellIdentifier;
- (UITableViewCell *) getUserProfileCell:(NSString *)cellIdentifier leftSide:(NSString *) left rightSide:(NSString *) right;


@end
