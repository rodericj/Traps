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

    [super viewDidLoad];

    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
    // self.navigationItem.rightBarButtonItem = self.editButtonItem;
}

- (void)locationUpdate:(CLLocation *)location {
	//locationLabel.text = [location description];
	NSLog(@"got the location");
	NSLog([location description]);
	NSLog(@"set up the url");

	//need to find the nearby locations
	//Send lat long to server
	//call to the web service to see if we can log in
	NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:[NSURL URLWithString:@"http://localhost:8000/FindNearby/"]
														   cachePolicy:NSURLRequestReloadIgnoringLocalCacheData
													   timeoutInterval:60.0];
    [request setHTTPMethod:@"POST"];
    [request setHTTPBody:[[NSString stringWithFormat:@"ld=%@&uid=%@", [location description],
								[[UIDevice currentDevice] uniqueIdentifier]] dataUsingEncoding:NSUTF8StringEncoding]];
    [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:YES];
	// NSURLConnection *connection = [[NSURLConnection alloc] initWithRequest:request delegate:self];
	NSURLResponse *response;
	NSError *error;
	NSData *urlData = [NSURLConnection sendSynchronousRequest:request
											returningResponse:&response
														error:&error];
	NSLog(@"get the url");
	NSString *results = [[NSString alloc] initWithData:urlData encoding:NSUTF8StringEncoding];
	NSLog(@"got the url");

	NSLog(results);	
	NSLog(@"make it json");
	
	foundVenues = [results JSONValue];
	[foundVenues writeToFile:@"NearbyPlaces.plist" atomically:TRUE];

	//get 
	[self.tableView reloadData];
	
	
	//NSLog([location ]);
	//[locationController.locationManager startUpdatingLocation];

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
	NSLog(@"Thats how many");
	//NSLog([foundVenues ]);
	return [places count];//[foundVenues count];
   // return 2;
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

