//
//  BTVenueAnnotation.m
//  Traps
//
//  Created by Roderic Campbell on 4/10/10.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import "BTVenueAnnotation.h"


@implementation BTVenueAnnotation
@synthesize coordinate;

-(NSString *)title{
	return @"Search for items here";
}
//-(NSString *)subtitle{
//	return @"test";
//}
-(id)initWithCoordinate:(CLLocationCoordinate2D) c{
	coordinate=c;
	return self;
}

@end
