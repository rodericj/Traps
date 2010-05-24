//
//  BTFoursquareLoginViewController.h
//  Traps
//
//  Created by Roderic Campbell on 4/12/10.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "MPOAuthAPI.h"

@interface BTFoursquareLoginViewController : UITableViewController {
	UIButton *loginButton;
	UITextField *unameTextField;
	UITextField *passwordTextField;
	NSString *viewDescription;
	MPOAuthAPI *_oauthAPI;
}

-(void) cancelButtonPushed;
-(void)foursquareCallback:(id)results;
@property (nonatomic, retain) NSString *viewDescription;
@end
