//
//  BTVenueAnnotation.h
//  Traps
//
//  Created by Roderic Campbell on 4/10/10.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <MapKit/MapKit.h>

@interface BTVenueAnnotation : NSObject <MKAnnotation>{
	CLLocationCoordinate2D coordinate;
}

@property (nonatomic, readonly) CLLocationCoordinate2D coordinate;

@end
