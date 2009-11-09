//
//  VenueViewController.h
//  BoobyTrap3
//
//  Created by Roderic Campbell on 11/1/09.
//  Copyright 2009 Slide. All rights reserved.
//

#import <UIKit/UIKit.h>


@interface VenueViewController : UIViewController {
	IBOutlet UILabel *city;
	IBOutlet UILabel *coinValue;
	IBOutlet UILabel *latitude;
	IBOutlet UILabel *longitude;
	IBOutlet UILabel *venueName;
	IBOutlet UILabel *phone;
	IBOutlet UILabel *state;
	IBOutlet UILabel *streetName;

}
@property (nonatomic, retain) UILabel *city;
@property (nonatomic, retain) UILabel *coinValue;
@property (nonatomic, retain) UILabel *latitude;
@property (nonatomic, retain) UILabel *longitude;
@property (nonatomic, retain) UILabel *venueName;
@property (nonatomic, retain) UILabel *phone;
@property (nonatomic, retain) UILabel *state;
@property (nonatomic, retain) UILabel *streetName;
@end
