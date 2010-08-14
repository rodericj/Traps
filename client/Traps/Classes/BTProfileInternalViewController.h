//
//  BTProfileInternalViewController.h
//  Traps
//
//  Created by Roderic Campbell on 3/14/10.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "UITableViewController+NetworkErrorHandler.h"
#import "BTConstants.h"

@interface BTProfileInternalViewController : UITableViewController {
	UISegmentedControl *segmentedControl;
	NSArray *segmentViews;
}

@property (nonatomic, retain) UISegmentedControl *segmentedControl;
@property (nonatomic, retain) NSArray *segmentViews;

-(void) segmentedControlChanged;

@end
