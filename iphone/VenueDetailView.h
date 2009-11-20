//
//  VenueDetailView.h
//  BoobyTrap3
//
//  Created by Roderic Campbell on 11/1/09.
//  Copyright 2009 Slide. All rights reserved.
//

#import <UIKit/UIKit.h>
@class TrapInventoryTableViewController;
@interface VenueDetailView : UIViewController {
	NSDictionary *venueInfo;
	IBOutlet UILabel *venueName;
	IBOutlet UILabel *checkinCount;
	IBOutlet UILabel *city;
	IBOutlet UILabel *coinValue;
	IBOutlet UILabel *latitude;
	IBOutlet UILabel *longitude;
	IBOutlet UILabel *phone;
	IBOutlet UILabel *state;
	IBOutlet UILabel *streetName;
	TrapInventoryTableViewController *trapInventoryTableViewController;
}
@property (nonatomic, retain) NSDictionary *venueInfo;
@property (nonatomic, retain) TrapInventoryTableViewController *trapInventoryTableViewController;

- (void)updateVenueDetails:(NSDictionary *)venue;
- (IBAction) searchVenue;
- (void)doSearchVenue;

@end