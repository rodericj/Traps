//
//  SocialTableViewController.h
//  BoobyTrap3
//
//  Created by Roderic Campbell on 11/21/09.
//  Copyright 2009 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>


@interface SocialTableViewController : UITableViewController {
	NSArray *friendsWithApp;

}
@property (nonatomic, retain) NSArray *friendsWithApp;

- (UITableViewCell *) getCellContentView:(NSString *)cellIdentifier;
@end
