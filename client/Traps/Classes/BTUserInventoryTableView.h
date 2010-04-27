//
//  BTUserInventoryTableView.h
//  Traps
//
//  Created by Roderic Campbell on 3/29/10.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>



@interface BTUserInventoryTableView : UITableViewController {
	NSArray *userInventory;
	UIActivityIndicatorView *_spinner;
	Boolean trapsOnly;
	NSMutableArray *userTraps;
}

@property (nonatomic, retain) NSArray *userInventory;
@property Boolean trapsOnly;

- (UITableViewCell *) getInventoryItemCell:(NSString *)cellIdentifier item:(NSDictionary *)item;

	
@end
