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
//#import "NetworkMiddleware.h"

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
	
	self.navigationItem.rightBarButtonItem = loadingView;
}


- (void)viewWillAppear:(BOOL)animated {
	locationController = [[MyCLController alloc] init];
	locationController.delegate = self;
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
	NSLog(@"getNearbyLocations Called");

	if (location == NULL){
		NSLog(@"the location was null which means that the thread is doing something intersting. Lets send this back.");
	}
	else{
		
		NetworkRequestOperation *op = [[NetworkRequestOperation alloc] init];
		[op setTargetURL:@"FindNearby"];
		op.arguments = [[NSMutableDictionary alloc] init];
		[op.arguments setObject:[location description] forKey:@"ld"];
		[op.arguments setObject:[[UIDevice currentDevice] uniqueIdentifier] forKey:@"uid"];
		op.callingDelegate = self;
		queue = [[NSOperationQueue alloc] init];
		[queue addOperation:op];
		[op release];
	}

}

- (void)pageLoaded:(NSDictionary*)webRequestResults{
	NSLog(@"nearby places webrequest returned %@", webRequestResults);

	UserProfile *userProfile = [UserProfile sharedSingleton];
	[userProfile newLocationsFromDictionary:webRequestResults];
	//NSLog(@"%@", [userProfile getUserName]);
	//NSLog(@"update with this username %@", [userProfile obje)
	//NSLog(@"in updateMiniProfile pageLoaded");
	//[self updateMiniProfile:userProfile];
	//NSLog(@"out of updateMiniProfile pageLoaded");
	
	
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
	cell.text = [venue objectForKey:@"name"];
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

