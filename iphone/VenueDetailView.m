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
//	
//	[usernameLabel setText:[profile objectForKey:@"username"]];
//	[levelLabel setText:[profile objectForKey:@"level"]];
//	[coinsLabel setText:[profile objectForKey:@"coinCount"]];
//	[hpLabel setText:[profile objectForKey:@"hitPoints"]];
//	[killLabel setText:[profile objectForKey:@"killCount"]];
//	[totalTrapsLabel setText:[profile objectForKey:@"trapsSetCount"]];
//	[profile release];
//	
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
