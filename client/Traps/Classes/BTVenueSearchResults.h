//
//  BTVenueSearchResults.h
//  Traps
//
//  Created by Roderic Campbell on 4/4/10.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <MapKit/MapKit.h>
#import "UITableViewController+NetworkErrorHandler.h"
#import "BTUserInventoryTableView.h"
#import "BTVenueAnnotation.h"


@interface BTVenueSearchResults : UITableViewController <MKMapViewDelegate>{
	NSDictionary *venueInfo;
	NSDictionary *searchResults;
	MKMapView *mapView;
	BTUserInventoryTableView *inventoryView;
	BTVenueAnnotation *pin;
	UIButton *dropTrapsButton;
}

@property (nonatomic, retain) BTUserInventoryTableView *inventoryView;
@property (nonatomic, retain) NSDictionary *searchResults;
@property (nonatomic, retain) MKMapView *mapView;
@property (nonatomic, retain) NSDictionary *venueInfo;

- (UITableViewCell *) getTitleCell:(NSString *)cellIdentifier;
- (UITableViewCell *) getMapCell:(NSString *)cellIdentifier;
- (void)dropTrapButtonPushed;

@end
