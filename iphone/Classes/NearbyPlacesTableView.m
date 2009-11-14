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

/*
- (id)initWithStyle:(UITableViewStyle)style {
    // Override initWithStyle: if you create the controller programmatically and want to perform customization that is not appropriate for viewDidLoad.
    if (self = [super initWithStyle:style]) {
    }
    return self;
}
*/

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

//- (void)viewDidLoad {
//
//    [super viewDidLoad];
//
//    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
//    // self.navigationItem.rightBarButtonItem = self.editButtonItem;
//}

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

- (void)didGetNearbyLocations{
	[self.tableView reloadData];
}

- (void)locationUpdate:(CLLocation *)location {
	//getNearbyLocations(location);
	[[location description] writeToFile:@"location.plist" atomically:TRUE];
	[self getNearbyLocations:location];
	[NSThread detachNewThreadSelector:@selector(getNearbyLocations:) toTarget:self withObject:nil];
}

- (void)locationError:(NSError *)error {
	//locationLabel.text = [error description];
	NSLog([error description]);
}


- (void)viewWillAppear:(BOOL)animated {
	locationController = [[MyCLController alloc] init];
	locationController.delegate = self;
	[locationController.locationManager startUpdatingLocation];
	
    [super viewWillAppear:animated];
}

/*
- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
}
*/
/*
- (void)viewWillDisappear:(BOOL)animated {
	[super viewWillDisappear:animated];
}
*/
/*
- (void)viewDidDisappear:(BOOL)animated {
	[super viewDidDisappear:animated];
}
*/

/*
// Override to allow orientations other than the default portrait orientation.
- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
    // Return YES for supported orientations
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}
*/

- (void)didReceiveMemoryWarning {
	// Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
	
	// Release any cached data, images, etc that aren't in use.
}

- (void)viewDidUnload {
	// Release any retained subviews of the main view.
	// e.g. self.myOutlet = nil;
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


/*
// Override to support conditional editing of the table view.
- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath {
    // Return NO if you do not want the specified item to be editable.
    return YES;
}
*/


/*
// Override to support editing the table view.
- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath {
    
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        // Delete the row from the data source
        [tableView deleteRowsAtIndexPaths:[NSArray arrayWithObject:indexPath] withRowAnimation:YES];
    }   
    else if (editingStyle == UITableViewCellEditingStyleInsert) {
        // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
    }   
}
*/


/*
// Override to support rearranging the table view.
- (void)tableView:(UITableView *)tableView moveRowAtIndexPath:(NSIndexPath *)fromIndexPath toIndexPath:(NSIndexPath *)toIndexPath {
}
*/


/*
// Override to support conditional rearranging of the table view.
- (BOOL)tableView:(UITableView *)tableView canMoveRowAtIndexPath:(NSIndexPath *)indexPath {
    // Return NO if you do not want the item to be re-orderable.
    return YES;
}
*/


- (void)dealloc {
		//[dropTrapsNavController release];
	[super dealloc];
}


@end

