//
//  BTVenueAnnotationView.h
//  Traps
//
//  Created by Roderic Campbell on 4/11/10.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import <MapKit/MapKit.h>

@interface BTVenueAnnotationView : MKAnnotationView {
	NSString *venueName;
	NSString *dudeIcon;
}

@property (nonatomic, retain) NSString *dudeIcon; 
@property (nonatomic, retain) NSString *venueName; 
@end
