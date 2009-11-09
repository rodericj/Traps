//
//  VenueDetailView.h
//  BoobyTrap3
//
//  Created by Roderic Campbell on 11/1/09.
//  Copyright 2009 Slide. All rights reserved.
//

#import <UIKit/UIKit.h>


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
}
@property (nonatomic, retain) NSDictionary *venueInfo;
- (void)updateVenueDetails:(NSDictionary *)venue;

@end
