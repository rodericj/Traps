//
//  BTVenueDetailView.h
//  Traps
//
//  Created by Roderic Campbell on 4/3/10.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <MapKit/MapKit.h>
#import "BTVenueSearchResults.h"
#import "BTVenueAnnotation.h"
#import "BTFoursquareLoginViewController.h"

@interface BTVenueDetailView : UITableViewController <MKMapViewDelegate>{
	NSDictionary *venueInfo;
	MKMapView *mapView;
	BTVenueSearchResults *searchResultsView;
	BTVenueAnnotation *pin;
	UISwitch *checkinSwitch;
	BTFoursquareLoginViewController *foursquareLoginView;

}
- (void)updateVenueDetails:(NSDictionary *)venue;
- (UITableViewCell *) getTitleCell:(NSString *)cellIdentifier;
- (UITableViewCell *) getMapCell:(NSString *)cellIdentifier;
- (UITableViewCell *) getOptionRow:(NSString *)cellIdentifier whichOption:(int)option;
- (void)didSearchVenue:(id)returnData;
-(void)searchVenue;

@property (nonatomic, retain) BTVenueAnnotation *pin;

@property (nonatomic, retain) NSDictionary *venueInfo;
@property (nonatomic, retain) MKMapView *mapView;
@property (nonatomic, retain) BTVenueSearchResults *searchResultsView;

@end
