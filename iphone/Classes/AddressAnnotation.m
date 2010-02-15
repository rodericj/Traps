//
//  AddressAnnotation.m
//  BoobyTrap3
//
//  Created by Roderic Campbell on 1/21/10.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import "AddressAnnotation.h"


@implementation AddressAnnotation

@synthesize coordinate;

- (NSString *)subtitle{
	return @"Sub Title";
}

- (NSString *)title{
	return @"Title";
}

-(id)initWithCoordinate:(CLLocationCoordinate2D) c{
	coordinate=c;
	NSLog(@"%f,%f",c.latitude,c.longitude);
	return self;
}
@end