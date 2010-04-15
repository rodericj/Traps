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

@synthesize venueDetailView;
@synthesize venues;

#pragma mark -
#pragma mark Initialization

- (id)init {
    if ((self = [super initWithStyle:UITableViewStylePlain]) == nil) {
		return nil;
    }
	
	//self.title = kSearchTitle;
	
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
	//self.title = @"Locations";
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
	if(venues == nil){
		return 0;
	}
    return [venues count];
}


- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
	
	NSInteger row = [indexPath row];
	if(venueDetailView != nil){
		[venueDetailView release];
	}
	BTVenueDetailView *aVenueDetail = [[BTVenueDetailView alloc] init];
	venueDetailView = aVenueDetail;
	
	NSDictionary *venue = [venues objectAtIndex:row];
	NSLog(@"selected %d", [indexPath row]);
	//venueDetailView.title = [venue objectForKey:@"name"];
	
	NSLog(@"loading each row %@", venueDetailView.title);
	
	
	[venueDetailView updateVenueDetails:venue];
	
	[self.navigationController pushViewController:venueDetailView animated:TRUE];
	//BoobyTrap3AppDelegate *delegate = [[UIApplication sharedApplication] delegate];
	//[delegate.dropTrapsNavController pushViewController:venueDetailView animated:YES];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
	NSString *reuseId = [NSString stringWithFormat:@"venue%d", [indexPath row]];
	UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:reuseId];

	if(cell == nil){
		cell = [self getVenueCell:reuseId venue:[venues objectAtIndex:[indexPath row]]];
	}
	
	NSDictionary *currentVenue = [venues objectAtIndex:[indexPath row]];
	
	[cell setText:[currentVenue objectForKey:@"name"]];
    return cell;
}

- (UITableViewCell *) getVenueCell:(NSString *)cellIdentifier venue:(NSDictionary *)venue{
	UITableViewCell *cell = [[[UITableViewCell alloc] initWithFrame:CGRectMake(90, 15, 120, 25) 
													reuseIdentifier:cellIdentifier] autorelease];

	return cell;
}
#pragma mark -
#pragma mark Location

- (void)locationUpdate:(CLLocation *)location {

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
		NSArray *chunks = [latlong componentsSeparatedByString:@" "];
		NSString *lat =[chunks objectAtIndex:0];
		NSString *lon = [chunks objectAtIndex:1];
		
		
		
		//Call to foursquare's location api
		[[BTNetwork sharedNetwork] performHttpOperationWithResponseObject:self
														  methodSignature:NSStringFromSelector(@selector(didGetNearbyLocations:))
																   method:@"GET"
																   domain:foursquareApi
															  relativeURL:@"v1/venues"
																   params:[NSDictionary dictionaryWithObjectsAndKeys:
																		   lat, @"geolat",
																		   lon, @"geolong", 
																		   nil] 
																  headers:nil];
	}
	
}
- (void)didGetNearbyLocations:(id)responseString{
	NSLog(@"did get nearby locations %@", responseString);

	
	if ([responseString isKindOfClass:[NSError class]]) {
		NSLog(@"code %d, domain %@", [responseString code], [responseString domain]);
//		if ([responseString code] == 400) {
		if (FALSE) {
			NSLog(@"We've got a rate limiting situation. Let's show the modular view");
			if (foursquareLoginView == nil) {
				foursquareLoginView = [[BTFoursquareLoginViewController alloc] init];
			}
			[foursquareLoginView setViewDescription:foursquareratelimitexceeded];
			[self presentModalViewController:foursquareLoginView animated:YES];
			return;
		}
		else{
		NSLog(@"default to jackson street because there was an error");
		responseString = @"{\"groups\":[{\"type\":\"Nearby\",\"venues\":[{\"id\":86638,\"name\":\"Joe Greenstein's\",\"address\":\"1740 Jackson St.\",\"city\":\"San Francisco\",\"state\":\"CA\",\"geolat\":37.7938,\"geolong\":-122.424,\"stats\":{\"herenow\":\"0\"},\"distance\":31},{\"id\":1235744,\"name\":\"1800 Washington Street\",\"address\":\"1800 Washington Street\",\"city\":\"San Francisco\",\"state\":\"CA\",\"geolat\":37.793433,\"geolong\":-122.423426,\"stats\":{\"herenow\":\"0\"},\"distance\":36}]}]}";
		}
	}
	SBJSON *parser = [SBJSON new];
	NSDictionary* webRequestResults = [parser objectWithString:responseString error:NULL];
	NSArray *groups = [webRequestResults objectForKey:@"groups"];
			  
	NSDictionary *venueDict = [groups objectAtIndex:0];
	venues = [[venueDict objectForKey:@"venues"] copy];

	[self.tableView reloadData];
	//NSLog(@"venueArray is: %@", venueArray);
	//UserProfile *userProfile = [UserProfile sharedSingleton];
//	[userProfile setLocations:venueArray];
	
	self.navigationItem.rightBarButtonItem = nil;
	//[self didGetNearbyLocations];
}



@end
