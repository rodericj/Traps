//
//  NearbyPlacesTableView.h
//  BoobyTrap3
//
//  Created by Roderic Campbell on 10/28/09.
//  Copyright 2009 Slide. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "MyCLController.h"
@class VenueDetailView;

@interface NearbyPlacesTableView : UITableViewController <MyCLControllerDelegate, UITableViewDataSource, UITableViewDelegate> {
	MyCLController *locationController;
	NSDictionary *foundVenues;
	VenueDetailView *venueDetailView;
	NSOperationQueue *queue;

}

@property (nonatomic, retain) NSDictionary *foundVenues;
@property (nonatomic, retain) VenueDetailView *venueDetailView;
- (void)didGetNearbyLocations;
- (void)getNearbyLocations:(CLLocation *)location;
- (void)locationUpdate:(CLLocation *)location; 
- (void)locationError:(NSError *)error;

@end
