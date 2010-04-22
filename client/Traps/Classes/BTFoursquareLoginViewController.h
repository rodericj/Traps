//
//  BTFoursquareLoginViewController.h
//  Traps
//
//  Created by Roderic Campbell on 4/12/10.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>


@interface BTFoursquareLoginViewController : UITableViewController {
	UIButton *loginButton;
	UITextField *unameTextField;
	UITextField *passwordTextField;
	NSString *viewDescription;
}
-(void)foursquareCallback:(id)results;
@property (nonatomic, retain) NSString *viewDescription;
@end
