//
//  BTVenueDetailView.h
//  Traps
//
//  Created by Roderic Campbell on 4/3/10.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <MapKit/MapKit.h>


@interface BTVenueDetailView : UITableViewController <MKMapViewDelegate>{
	NSDictionary *venueInfo;
	MKMapView *mapView;

}
- (void)updateVenueDetails:(NSDictionary *)venue;
- (UITableViewCell *) getTitleCell:(NSString *)cellIdentifier;
- (UITableViewCell *) getMapCell:(NSString *)cellIdentifier;

@property (nonatomic, retain) NSDictionary *venueInfo;
@property (nonatomic, retain) MKMapView *mapView;
@end
