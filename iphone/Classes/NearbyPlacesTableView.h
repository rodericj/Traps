//
//  NearbyPlacesTableView.h
//  BoobyTrap3
//
//  Created by Roderic Campbell on 10/28/09.
//  Copyright 2009 Slide. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "MyCLController.h"


@interface NearbyPlacesTableView : UITableViewController <MyCLControllerDelegate, UITableViewDataSource> {
	MyCLController *locationController;
	NSDictionary *foundVenues;
}

@property (nonatomic, retain) NSDictionary *foundVenues;

- (void)locationUpdate:(CLLocation *)location; 
- (void)locationError:(NSError *)error;

@end
