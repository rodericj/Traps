//
//  TrapInventoryTableViewController.h
//  BoobyTrap3
//
//  Created by Roderic Campbell on 11/13/09.
//  Copyright 2009 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "FBConnect/FBConnect.h"

@interface TrapInventoryTableViewController : UITableViewController <FBDialogDelegate, UITableViewDelegate, UITableViewDataSource>{
	NSOperationQueue *queue;
}

- (void)doDropTrap;
- (void)didDropTrap:(NSDictionary *) results;

@end
