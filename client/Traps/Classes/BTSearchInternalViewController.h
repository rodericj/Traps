//
//  BTSearchInternalViewController.h
//  Traps
//
//  Created by Roderic Campbell on 3/14/10.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "BTConstants.h"
#import "BTVenueDetailView.h"
#import "BTFoursquareLoginViewController.h"

#import "MyCLController.h"

@interface BTSearchInternalViewController : UITableViewController <MyCLControllerDelegate, UITableViewDataSource, UITableViewDelegate>{
	MyCLController *locationController;
	NSArray *venues;
	BTVenueDetailView *venueDetailView;
	BTFoursquareLoginViewController *foursquareLoginView;
}

@property (nonatomic, retain) BTVenueDetailView *venueDetailView;
@property (nonatomic, retain) NSArray *venues;


- (UITableViewCell *) getVenueCell:(NSString *)cellIdentifier venue:(NSDictionary *)venue;

- (void)didGetNearbyLocations:(id)responseString;

- (void)getNearbyLocations:(CLLocation *)location;
- (void)locationUpdate:(CLLocation *)location; 
- (void)locationError:(NSError *)error;

@end
