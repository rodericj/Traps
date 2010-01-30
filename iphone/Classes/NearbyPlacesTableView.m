//
//  NearbyPlacesTableView.m
//  BoobyTrap3
//
//  Created by Roderic Campbell on 10/28/09.
//  Copyright 2009 Slide. All rights reserved.
//

#import "NearbyPlacesTableView.h"
#import "VenueDetailView.h"
#import "BoobyTrap3AppDelegate.h"
#import "NetworkRequestOperation.h"
#import "UserProfile.h"
#import "FoursquareNetworkOperation.h"

@implementation NearbyPlacesTableView
@synthesize foundVenues;
@synthesize venueDetailView;

#pragma mark initialization
- (void)viewDidLoad {
	
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
	locationController = [[MyCLController alloc] init];
	locationController.delegate = self;
	locationController.locationManager.desiredAccuracy = kCLLocationAccuracyNearestTenMeters;
	[locationController.locationManager startUpdatingLocation];
	
    [super viewWillAppear:animated];
}

- (void)didReceiveMemoryWarning {
	// Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
	
	// Release any cached data, images, etc that aren't in use.
}

- (void)viewDidUnload {
	// Release any retained subviews of the main view.
	// e.g. self.myOutlet = nil;
}

- (void)dealloc {
	//[dropTrapsNavController release];
	[super dealloc];
}


#pragma mark Location handlers

- (void)getNearbyLocations:(CLLocation *)location {
	NSLog(@"getNearbyLocations Called %@", [location description]);

	if (location == NULL){
		NSLog(@"the location was null which means that the thread is doing something intersting. Lets send this back.");
	}
	else{
		//Make location string 2 separate lat/long
		NSString *latlong = [[[location description] stringByReplacingOccurrencesOfString:@"<" withString:@""] 
							 stringByReplacingOccurrencesOfString:@">" withString:@""];
		NSLog(@"new lat long %@", latlong);
		NSArray *chunks = [latlong componentsSeparatedByString:@" "];
		NSString *lat = [chunks objectAtIndex:0];
		NSString *lon = [chunks objectAtIndex:1];
		//[chunks release];
		//[latlong release];
		
		NSLog(@"now we've split them up into %@ and %@", lat, lon);
		FoursquareNetworkOperation *op = [[FoursquareNetworkOperation alloc] init];
		[op setTargetURL:@"venues.json"];
		op.arguments = [[NSMutableDictionary alloc] init];
		[op.arguments setObject:[lat stringByReplacingOccurrencesOfString:@"," withString:@""] forKey:@"geolat"];
		[op.arguments setObject:lon forKey:@"geolong"];
		op.callingDelegate = self;
		queue = [[NSOperationQueue alloc] init];
		[queue addOperation:op];
		[op release];
	
	}

}

- (void)pageLoaded:(NSDictionary*)webRequestResults{
	NSArray *groups = [webRequestResults objectForKey:@"groups"];
	NSDictionary *venues = [groups objectAtIndex:0];
	NSArray *venues1 = [venues objectForKey:@"venues"];
	NSLog(@"venues1 is: %@", venues1);
	UserProfile *userProfile = [UserProfile sharedSingleton];
	[userProfile setLocations:venues1];
	
	self.navigationItem.rightBarButtonItem = nil;
	[self didGetNearbyLocations];
}

- (void)locationUpdate:(CLLocation *)location {
	[self getNearbyLocations:location];
	locationController = [[MyCLController alloc] init];
	locationController.delegate = self;
	[locationController.locationManager stopUpdatingLocation];
}

- (void)didGetNearbyLocations{
	NSLog(@"didGetNearbyLocations: Time to reload");
	[self.tableView reloadData];
}

- (void)locationError:(NSError *)error {
	NSLog([error description]);
}


#pragma mark Table view methods

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}


// Customize the number of rows in the table view.
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
	UserProfile *userProfile = [UserProfile sharedSingleton];
	NSArray *places = [userProfile locations];
	NSLog(@"places at this point is: %@", places);
	NSLog(@"reloading the tableView for nearby places %d", [places count]);

	//NSArray *places = [NSArray arrayWithContentsOfFile:@"NearbyPlaces.plist"];
	return [places count];
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section {
	return @"Nearby Joints";
}

// Customize the appearance of table view cells.
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    static NSString *CellIdentifier = @"Cell";
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
        cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier] autorelease];
    }
    
    // Set up the cell...
	UserProfile *userProfile = [UserProfile sharedSingleton];
	NSArray *places = [userProfile locations];

	//NSArray *places = [NSArray arrayWithContentsOfFile:@"NearbyPlaces.plist"];
	NSDictionary *venue = (NSDictionary *)[places objectAtIndex:[indexPath row]];
	//cell.text = [venue objectForKey:@"name"];
	[cell.textLabel setText:[venue objectForKey:@"name"]];
	//cell.text = @"hi";
    return cell;
}


- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {

	NSInteger row = [indexPath row];
	if (self.venueDetailView == nil){
		VenueDetailView *aVenueDetail = [[VenueDetailView alloc] initWithNibName:@"VenueDetailView" bundle:nil];
		self.venueDetailView = aVenueDetail;
		[aVenueDetail release];
	}
	UserProfile *userProfile = [UserProfile sharedSingleton];
	NSArray *venues = [userProfile locations];
	//NSArray *venues = [NSArray arrayWithContentsOfFile:@"NearbyPlaces.plist"];
	NSDictionary *venue = [venues objectAtIndex:row];
	venueDetailView.title = [venue objectForKey:@"name"];

	NSLog(@"loading each row %@", venueDetailView.title);

	
	[venueDetailView updateVenueDetails:venue];

	BoobyTrap3AppDelegate *delegate = [[UIApplication sharedApplication] delegate];
	[delegate.dropTrapsNavController pushViewController:venueDetailView animated:YES];
}
@end

