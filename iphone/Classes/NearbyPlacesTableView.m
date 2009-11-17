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
		NSAutoreleasePool *pool = [[NSAutoreleasePool alloc] init];
		NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:[NSURL URLWithString:@"http://localhost:8000/FindNearby/"]
														   cachePolicy:NSURLRequestReloadIgnoringLocalCacheData
													   timeoutInterval:60.0];
		[request setHTTPMethod:@"POST"];
		[request setHTTPBody:[[NSString stringWithFormat:@"ld=%@&uid=%@", [location description],
						   [[UIDevice currentDevice] uniqueIdentifier]] dataUsingEncoding:NSUTF8StringEncoding]];
		[[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:YES];
		NSURLResponse *response;
		NSError *error;
		NSData *urlData = [NSURLConnection sendSynchronousRequest:request
											returningResponse:&response
														error:&error];
	
		NSString *results = [[NSString alloc] initWithData:urlData encoding:NSUTF8StringEncoding];
		
		foundVenues = [results JSONValue];
		[foundVenues writeToFile:@"NearbyPlaces.plist" atomically:TRUE];
		self.navigationItem.rightBarButtonItem = nil;
		[pool release];
	}
	[self performSelectorOnMainThread:@selector(didGetNearbyLocations) withObject:nil waitUntilDone:NO];

}

- (void)locationUpdate:(CLLocation *)location {
	[self getNearbyLocations:location];
	[NSThread detachNewThreadSelector:@selector(getNearbyLocations:) toTarget:self withObject:nil];
}

- (void)didGetNearbyLocations{
	[self.tableView reloadData];
}

- (void)locationError:(NSError *)error {
	//locationLabel.text = [error description];
	NSLog([error description]);
}


#pragma mark Table view methods

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}


// Customize the number of rows in the table view.
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
	NSArray *places = [NSArray arrayWithContentsOfFile:@"NearbyPlaces.plist"];
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
	NSArray *places = [NSArray arrayWithContentsOfFile:@"NearbyPlaces.plist"];
	NSDictionary *venue = (NSDictionary *)[places objectAtIndex:[indexPath row]];
	cell.text = [venue objectForKey:@"name"];
	//cell.text = @"hi";
    return cell;
}


- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    // Navigation logic may go here. Create and push another view controller.
	// AnotherViewController *anotherViewController = [[AnotherViewController alloc] initWithNibName:@"AnotherView" bundle:nil];
	// [self.navigationController pushViewController:anotherViewController];
	// [anotherViewController release];
	NSInteger row = [indexPath row];
	if (self.venueDetailView == nil){
		VenueDetailView *aVenueDetail = [[VenueDetailView alloc] initWithNibName:@"VenueDetailView" bundle:nil];
		self.venueDetailView = aVenueDetail;
		[aVenueDetail release];
	}
	NSArray *venues = [NSArray arrayWithContentsOfFile:@"NearbyPlaces.plist"];
	NSDictionary *venue = [venues objectAtIndex:row];
	venueDetailView.title = [venue objectForKey:@"name"];

	[venueDetailView updateVenueDetails:venue];

	//[venueName setText:[venue objectForKey:@"name"]];
	BoobyTrap3AppDelegate *delegate = [[UIApplication sharedApplication] delegate];
	[delegate.dropTrapsNavController pushViewController:venueDetailView animated:YES];
	//[delegate release];
}
@end

