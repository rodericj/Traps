//
//  SegmentedTableViewController.h
//  BoobyTrap3
//
//  Created by Roderic Campbell on 2/18/10.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>


@interface SegmentedTableViewController : UITableViewController {
	int selectedSegment;
	NSOperationQueue *queue;
	NSArray *currentData;

}

@end
