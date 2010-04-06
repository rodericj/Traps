//
//  BTVenueSearchResults.h
//  Traps
//
//  Created by Roderic Campbell on 4/4/10.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <MapKit/MapKit.h>
#import "BTUserInventoryTableView.h"

@interface BTVenueSearchResults : UITableViewController {
	NSDictionary *venueInfo;
	NSDictionary *searchResults;
	MKMapView *mapView;
	BTUserInventoryTableView *inventoryView;
}

@property (nonatomic, retain) BTUserInventoryTableView *inventoryView;
@property (nonatomic, retain) NSDictionary *searchResults;
@property (nonatomic, retain) MKMapView *mapView;
@property (nonatomic, retain) NSDictionary *venueInfo;

- (UITableViewCell *) getTitleCell:(NSString *)cellIdentifier;
- (UITableViewCell *) getMapCell:(NSString *)cellIdentifier;
- (void)dropTrapButtonPushed;

@end
