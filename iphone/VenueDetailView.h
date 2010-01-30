//
//  VenueDetailView.h
//  BoobyTrap3
//
//  Created by Roderic Campbell on 11/1/09.
//  Copyright 2009 Slide. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <MapKit/MapKit.h>
#import "AddressAnnotation.h"
@class TrapInventoryTableViewController;
@interface VenueDetailView : UIViewController <MKMapViewDelegate>{
	NSOperationQueue *queue;
	NSDictionary *venueInfo;
	AddressAnnotation *addAnnotation;

	IBOutlet UILabel *venueName;
	IBOutlet UILabel *latitude;
	IBOutlet UILabel *longitude;
	IBOutlet UILabel *phone;
	IBOutlet UILabel *streetName;
	IBOutlet MKMapView *mapView;
	TrapInventoryTableViewController *trapInventoryTableViewController;
}
@property (nonatomic, retain) NSDictionary *venueInfo;
@property (nonatomic, retain) TrapInventoryTableViewController *trapInventoryTableViewController;
@property (nonatomic, retain) AddressAnnotation *addAnnotation;
- (void)updateVenueDetails:(NSDictionary *)venue;
- (IBAction) searchVenue;
- (void)doSearchVenue;

@end
