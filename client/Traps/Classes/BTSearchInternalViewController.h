//
//  BTSearchInternalViewController.h
//  Traps
//
//  Created by Roderic Campbell on 3/14/10.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "BTConstants.h"

#import "MyCLController.h"

@interface BTSearchInternalViewController : UITableViewController <MyCLControllerDelegate, UITableViewDataSource, UITableViewDelegate>{
	MyCLController *locationController;
	NSDictionary *foundVenues;
	VenueDetailView *VenueDetailView;
}

@property (nonatomic, retain) NSDictionary *foundVenues;
@property (nonatomic, retain) VenueDetailView *venueDetailView;
- (void)didGetNearbyLocations;
- (void)getNearbyLocations:(CLLocation *)location;
- (void)locationUpdate:(CLLocation *)location; 
- (void)locationError:(NSError *)error;

@end
