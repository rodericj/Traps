//
//  VenueDetailView.m
//  BoobyTrap3
//
//  Created by Roderic Campbell on 11/1/09.
//  Copyright 2009 Slide. All rights reserved.
//

#import "VenueDetailView.h"
#import "BoobyTrap3AppDelegate.h"
#import "TrapInventoryTableViewController.h"
#import "UserProfile.h"
#import "NetworkRequestOperation.h"
#import "AddressAnnotation.h"

@implementation VenueDetailView
@synthesize venueInfo;
@synthesize trapInventoryTableViewController;
@synthesize addAnnotation;
@synthesize searchButton;
#pragma mark Button clicked to initiate searching venue
- (IBAction) searchVenue{
	[searchButton setEnabled:NO];
	[self doSearchVenue];
}

- (void)doSearchVenue{
	UserProfile *profile = [UserProfile sharedSingleton];
	NetworkRequestOperation *op = [[NetworkRequestOperation alloc] init];
	[op setTargetURL:@"SearchVenue"];
	op.arguments = [[NSMutableDictionary alloc] init];
	[op.arguments setObject:[venueInfo objectForKey:@"id"] forKey:@"vid"];
	[op.arguments setObject:[[UIDevice currentDevice] uniqueIdentifier] forKey:@"uid"];
	[op.arguments setObject:[NSString stringWithFormat:@"%d", [profile getTutorial]] forKey:@"tutorial"];
	op.callingDelegate = self;
	queue = [[NSOperationQueue alloc] init];
	[queue addOperation:op];
	[op release];
	
}

- (void)pageLoaded:(NSDictionary*)webRequestResults{
	[self didSearchVenue:webRequestResults];
}

- (void)didSearchVenue:(NSDictionary *)returnData{
	NSString *alertStatement = [returnData objectForKey:@"alertStatement"];

	UserProfile *profile = [UserProfile sharedSingleton];
	[profile printUserProfile];
	NSDictionary *profileDict = [returnData objectForKey:@"profile"];
	[profile newProfileFromDictionary:profileDict];
	[profile printUserProfile];

	UIAlertView *alert;
	NSNumber *hasTraps = (NSNumber *)[returnData objectForKey:@"hasTraps"];

	if([hasTraps boolValue]== YES){
		alert = [[UIAlertView alloc] initWithTitle:@"Venue has been Searched" message:alertStatement delegate:self cancelButtonTitle:@"No" otherButtonTitles:@"Yes", nil]; 
	}
	else{
		alert = [[UIAlertView alloc] initWithTitle:@"Venue has been Searched" message:alertStatement delegate:self cancelButtonTitle:@"Ok" otherButtonTitles:nil, nil]; 
	}
	[alert show]; 
	[alert release]; 

	[searchButton setEnabled:YES];

}
- (void)alertView:(UIAlertView *)alertView  clickedButtonAtIndex:(NSInteger)buttonIndex {
	if(buttonIndex == 0){
		//Do nothing I guess
	}
	else{
		//Need to load the UITableView which shows what kind of traps we have to set
		if (self.trapInventoryTableViewController == nil){
			TrapInventoryTableViewController *titvc = [[TrapInventoryTableViewController alloc] initWithNibName:@"TrapInventoryTableView" bundle:nil];
			self.trapInventoryTableViewController = titvc;
			[titvc release];
		}

		trapInventoryTableViewController.title = @"Drop a Trap";
		
		UserProfile *profile = [UserProfile sharedSingleton];
		[profile setWhichVenue:[venueInfo objectForKey:@"id"]];
	
		///TODO - may be able to use [self.navigationController pushViewController:...]
		BoobyTrap3AppDelegate *delegate = [[UIApplication sharedApplication] delegate];
		[delegate.dropTrapsNavController pushViewController:trapInventoryTableViewController animated:YES];
	}
		
	}
- (void)updateVenueDetails:(NSDictionary *)venue{
	self.venueInfo = venue;
}

#pragma mark initialization
- (void)viewWillAppear:(BOOL)animated {
	
	//Handle Map things:
	MKCoordinateRegion region;
	MKCoordinateSpan span;
	span.latitudeDelta=0.0025;
	span.longitudeDelta=0.0025;
	
	CLLocationCoordinate2D location;
	location.longitude = [[self.venueInfo objectForKey:@"geolong"] doubleValue];
	location.latitude = [[self.venueInfo objectForKey:@"geolat"] doubleValue];
	
	region.center = location;
	region.span = span;
	
	if(self.addAnnotation != nil){
		[mapView removeAnnotation:addAnnotation];
		[addAnnotation release];
		addAnnotation = nil;
	}
	addAnnotation = [[AddressAnnotation alloc] initWithCoordinate:location];
	[mapView addAnnotation:addAnnotation];
	[mapView setRegion:region animated:TRUE];
	[mapView regionThatFits:region];
	
	[venueName setText:[self.venueInfo objectForKey:@"name"]];	
	[phone setText:[self.venueInfo objectForKey:@"phone"]];
	[streetName setText:[self.venueInfo objectForKey:@"address"]];

	[super viewWillAppear:animated];
	
	UserProfile *userProfile = [UserProfile sharedSingleton];
	
	if([userProfile getTutorial] == 3){
		UIAlertView *alert;
		NSString *alertStatement = @"So this is the place. Take a look around (Click the search button). You might find something that you like.";
		alert = [[UIAlertView alloc] initWithTitle:@"Tutorial" message:alertStatement delegate:self cancelButtonTitle:@"Ok" otherButtonTitles:nil]; 
		[alert show];
		[alert release];
		[userProfile setTutorial:4];
	}
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
	[trapInventoryTableViewController release];
    [super dealloc];
}

@end
