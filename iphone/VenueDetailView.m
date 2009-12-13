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

@implementation VenueDetailView
@synthesize venueInfo;
@synthesize trapInventoryTableViewController;

#pragma mark Button clicked to initiate searching venue
- (IBAction) searchVenue{
	[self doSearchVenue];
}

- (void)doSearchVenue{
	NSLog(@"venue that we clicked on: %@", venueInfo);
	NetworkRequestOperation *op = [[NetworkRequestOperation alloc] init];
	[op setTargetURL:@"SearchVenue"];
	op.arguments = [[NSMutableDictionary alloc] init];
	[op.arguments setObject:[venueInfo objectForKey:@"id"] forKey:@"vid"];
	[op.arguments setObject:[[UIDevice currentDevice] uniqueIdentifier] forKey:@"uid"];
	op.callingDelegate = self;
	queue = [[NSOperationQueue alloc] init];
	[queue addOperation:op];
	[op release];
	
}

- (void)pageLoaded:(NSDictionary*)webRequestResults{
	NSLog(@"venue detail webrequest returned %@", webRequestResults);
	[self didSearchVenue:webRequestResults];
}

- (void)didSearchVenue:(NSDictionary *)returnData{
	NSLog(@"we did search");
	NSString *alertStatement = [returnData objectForKey:@"alertStatement"];

	UserProfile *profile = [UserProfile sharedSingleton];
	NSDictionary *profileDict = [returnData objectForKey:@"profile"];
	[profile newProfileFromDictionary:profileDict];

	NSLog(alertStatement);
	UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"UIAlertView" message:alertStatement delegate:self cancelButtonTitle:@"No" otherButtonTitles:@"Yes", nil]; 
	[alert show]; 
	[alert release]; 

}
- (void)alertView:(UIAlertView *)alertView  clickedButtonAtIndex:(NSInteger)buttonIndex {
	if(buttonIndex == 0){
		NSLog(@"no");
		//Do nothing I guess
	}
	else{
		NSLog(@"Yes");
		//Need to load the UITableView which shows what kind of traps we have to set
		if (self.trapInventoryTableViewController == nil){
			TrapInventoryTableViewController *titvc = [[TrapInventoryTableViewController alloc] initWithNibName:@"TrapInventoryTableView" bundle:nil];
			self.trapInventoryTableViewController = titvc;
			[titvc release];
		}
		NSLog(@"We have a titvc");

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
	NSLog(@"viewWillAppear in VenueDetail");
	[venueName setText:[self.venueInfo objectForKey:@"name"]];
	[city setText:[self.venueInfo objectForKey:@"city"]];
	[coinValue setText:[self.venueInfo objectForKey:@"coinValue"]];
	[latitude setText:[self.venueInfo objectForKey:@"latitude"]];
	[longitude setText:[self.venueInfo objectForKey:@"longitude"]];
	[phone setText:[self.venueInfo objectForKey:@"phone"]];
	[state setText:[self.venueInfo objectForKey:@"state"]];
	[streetName setText:[self.venueInfo objectForKey:@"streetName"]];
	[checkinCount setText:[self.venueInfo objectForKey:@"checkinCount"]];

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
	[trapInventoryTableViewController release];
    [super dealloc];
}

@end
