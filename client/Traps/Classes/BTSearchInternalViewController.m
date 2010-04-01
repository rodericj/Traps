//
//  BTSearchInternalViewController.m
//  Traps
//
//  Created by Roderic Campbell on 3/14/10.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import "BTSearchInternalViewController.h"
#import "BTNetwork.h"
#import <JSON/JSON.h>


@implementation BTSearchInternalViewController

#pragma mark -
#pragma mark Initialization

- (id)init {
    if ((self = [super initWithStyle:UITableViewStylePlain]) == nil) {
		return nil;
    }
	
	self.title = kSearchTitle;
	
    return self;
}

#pragma mark -
#pragma mark Cleanup

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
	
	//XXX: purge unnecessary data structures
}

- (void)dealloc {	
    [super dealloc];
}

#pragma mark -
#pragma mark UIViewController

- (void)viewDidLoad {
    [super viewDidLoad];
	
	CGRect frame = CGRectMake(0.0, 0.0, 25.0, 25.0);
	UIActivityIndicatorView *loading = [[UIActivityIndicatorView alloc] initWithFrame:frame];
	[loading startAnimating];
	[loading sizeToFit];
	loading.autoresizingMask = (UIViewAutoresizingFlexibleLeftMargin |
								UIViewAutoresizingFlexibleRightMargin |
								UIViewAutoresizingFlexibleTopMargin |
								UIViewAutoresizingFlexibleBottomMargin);
	
	// initing the bar button
	UIBarButtonItem *loadingView = [[UIBarButtonItem alloc] initWithCustomView:loading];
	[loading release];
	loadingView.target = self;
	self.title = @"Locations";
	self.navigationItem.rightBarButtonItem = loadingView;

}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
	
	locationController = [[MyCLController alloc] init];
	locationController.delegate = self;
	locationController.locationManager.desiredAccuracy = kCLLocationAccuracyNearestTenMeters;
	[locationController.locationManager startUpdatingLocation];


}



- (void)viewDidDisappear:(BOOL)animated {
	[super viewDidDisappear:animated];
	
	//XXX: add code here
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

#pragma mark -
#pragma mark UITableView

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
	return 0;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
	UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"default"];
	
    return cell;
}

#pragma mark -
#pragma mark Location

- (void)locationUpdate:(CLLocation *)location {
	NSLog(@"got a location");
	//NSLog(@"getNearbyLocations Called %@. Accuracy: %d, %d", [location description], location.verticalAccuracy, location.horizontalAccuracy);

	[self getNearbyLocations:location];
	locationController = [[MyCLController alloc] init];
	locationController.delegate = self;
	//[locationController.locationManager stopUpdatingLocation];
}

- (void)getNearbyLocations:(CLLocation *)location {
	NSLog(@"getNearbyLocations Called %@. Accuracy: %d, %d", [location description], location.verticalAccuracy, location.horizontalAccuracy);
	
	if (location == NULL){
		NSLog(@"the location was null which means that the thread is doing something intersting. Lets send this back.");
	}
	else{
		//Make location string 2 separate lat/long
		NSString *latlong = [[[location description] stringByReplacingOccurrencesOfString:@"<" withString:@""] 
							 stringByReplacingOccurrencesOfString:@">" withString:@""];
		NSLog(@"new lat long %@", latlong);
		NSArray *chunks = [latlong componentsSeparatedByString:@" "];
		NSString *lat =[chunks objectAtIndex:0];
		NSString *lon = [chunks objectAtIndex:1];
		
		NSLog(@"now we've split them up into %@ and %@", lat, lon);
		
		
		//Call to foursquare's location api
		[[BTNetwork sharedNetwork] performHttpOperationWithResponseObject:self
														  methodSignature:NSStringFromSelector(@selector(didGetNearbyLocations:))
																   method:@"GET"
																   domain:foursquareApi
															  relativeURL:@"v1/venues"
																   params:[NSDictionary dictionaryWithObjectsAndKeys:
																		   lat, @"geolat",
																		   lon, @"geolong", 
																		   nil]];
	}
	
}

- (void)didGetNearbyLocations:(id)responseString{
	NSLog(@"did get nearby locations %@", responseString);

	SBJSON *parser = [SBJSON new];
	NSDictionary* webRequestResults = [parser objectWithString:responseString error:NULL];
	
	NSArray *groups = [webRequestResults objectForKey:@"groups"];
	NSDictionary *venues = [groups objectAtIndex:0];
	NSArray *venues1 = [venues objectForKey:@"venues"];
	NSLog(@"venues1 is: %@", venues1);
	//UserProfile *userProfile = [UserProfile sharedSingleton];
//	[userProfile setLocations:venues1];
	
	self.navigationItem.rightBarButtonItem = nil;
	//[self didGetNearbyLocations];
}



@end
