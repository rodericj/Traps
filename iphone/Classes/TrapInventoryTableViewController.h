//
//  TrapInventoryTableViewController.h
//  BoobyTrap3
//
//  Created by Roderic Campbell on 11/13/09.
//  Copyright 2009 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface TrapInventoryTableViewController : UITableViewController <UITableViewDelegate, UITableViewDataSource>{
	NSOperationQueue *queue;
}

- (void)doDropTrap:(NSString *)trap;
- (void)didDropTrap:(NSDictionary *) results;

@end
