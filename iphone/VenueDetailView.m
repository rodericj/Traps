//
//  VenueDetailView.m
//  BoobyTrap3
//
//  Created by Roderic Campbell on 11/1/09.
//  Copyright 2009 Slide. All rights reserved.
//

#import "VenueDetailView.h"


@implementation VenueDetailView
@synthesize venueInfo;

- (IBAction) searchVenue{
	//Spawn off a thread to go to the network. Display modal view later
	[NSThread detachNewThreadSelector:@selector(doSearchVenue) toTarget:self withObject:nil];
}

- (void)doSearchVenue{
	NSLog(@"doing the search %@", [venueInfo objectForKey:@"id"]);
	NSAutoreleasePool *pool = [[NSAutoreleasePool alloc] init];
	NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:[NSURL URLWithString:@"http://localhost:8000/SearchVenue/"]
														   cachePolicy:NSURLRequestReloadIgnoringLocalCacheData
													   timeoutInterval:60.0];
    [request setHTTPMethod:@"POST"];
    [request setHTTPBody:[[NSString stringWithFormat:@"vid=%@&uid=%@", [venueInfo objectForKey:@"id"],
						   [[UIDevice currentDevice] uniqueIdentifier]] dataUsingEncoding:NSUTF8StringEncoding]];
    [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:YES];
	NSURLResponse *response;
	NSError *error;
	NSData *urlData = [NSURLConnection sendSynchronousRequest:request
											returningResponse:&response
														error:&error];
	NSString *results = [[NSString alloc] initWithData:urlData encoding:NSUTF8StringEncoding];
	
	NSLog(results);	
	
	NSDictionary *returnData;
	returnData = [results JSONValue];
	NSLog(@"%@", returnData);
	//[returnData writeToFile:@"NearbyPlaces.plist" atomically:TRUE];
	self.navigationItem.rightBarButtonItem = nil;
	//get 
	[self performSelectorOnMainThread:@selector(didSearchVenue:) withObject:returnData waitUntilDone:NO];
	
	[pool release];
	//[self performSelectorOnMainThread:@selector(didSearchVenue) withObject:nil waitUntilDone:NO];

}

- (void)didSearchVenue:(NSDictionary *)returnData{
	NSLog(@"we did search");
	NSString *alertStatement = [returnData objectForKey:@"alertStatement"];
	
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
	}
		
	}
- (void)updateVenueDetails:(NSDictionary *)venue{
	self.venueInfo = venue;
	//NSLog(@"inside updatevenuedetail");
	//NSLog([venue objectForKey:@"name"]);
	//venueName.text = [venue objectForKey:@"name"];
	//[venueName setText:[venue objectForKey:@"name"]];
	//venueName.
}
- (void)viewWillAppear:(BOOL)animated {
	NSLog(@"viewWillAppear in VenueDetail");
	[venueName setText:[self.venueInfo objectForKey:@"name"]];
	//[checkinCount setText:[self.venueInfo objectForKey:@"checkinCount"]];
	[city setText:[self.venueInfo objectForKey:@"city"]];
	[coinValue setText:[self.venueInfo objectForKey:@"coinValue"]];
	[latitude setText:[self.venueInfo objectForKey:@"latitude"]];
	[longitude setText:[self.venueInfo objectForKey:@"longitude"]];
	[phone setText:[self.venueInfo objectForKey:@"phone"]];
	[state setText:[self.venueInfo objectForKey:@"state"]];
	[streetName setText:[self.venueInfo objectForKey:@"streetName"]];
	[checkinCount setText:[self.venueInfo objectForKey:@"checkinCount"]];
	//NSDictionary *profile = [NSDictionary dictionaryWithContentsOfFile:@"Profile.plist"];

	[super viewWillAppear:animated];
}
/*
 // The designated initializer.  Override if you create the controller programmatically and want to perform customization that is not appropriate for viewDidLoad.
- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil {
    if (self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil]) {
        // Custom initialization
    }
    return self;
}
*/

/*
// Implement viewDidLoad to do additional setup after loading the view, typically from a nib.
- (void)viewDidLoad {
    [super viewDidLoad];
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


- (void)dealloc {
    [super dealloc];
}


@end
