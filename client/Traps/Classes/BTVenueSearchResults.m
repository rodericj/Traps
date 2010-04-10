//
//  BTVenueSearchResults.m
//  Traps
//
//  Created by Roderic Campbell on 4/4/10.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import "BTVenueSearchResults.h"
#import "BTConstants.h"
#import "BTUserProfile.h"
#import "BTNetwork.h"

#import <JSON/JSON.h>

@implementation BTVenueSearchResults

@synthesize searchResults;
@synthesize mapView;
@synthesize venueInfo;	
@synthesize inventoryView;

- (void)didReceiveMemoryWarning {
	// Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
	
	// Release any cached data, images, etc that aren't in use.
}
- (void)viewDidAppear:(BOOL)animated{
	int trap = [[BTUserProfile sharedBTUserProfile] selectedTrap];

	[[BTUserProfile sharedBTUserProfile] setSelectedTrap:-1];
	
	if(trap != -1){
		NSString *vid = [NSString stringWithFormat:@"%@", [venueInfo objectForKey:@"id"]];
		NSLog(@"this is the searchResults %@", searchResults);
		NSDictionary *profile = [searchResults objectForKey:@"profile"];
		NSArray *inventory = [profile objectForKey:@"inventory"];
		NSDictionary *inventoryItem = [inventory objectAtIndex:trap];
		NSString *iid = [NSString stringWithFormat:@"%@", [inventoryItem objectForKey:@"id"]];
		NSLog(@"venueId: %@, iid %@, inventory %@, and the inventoryItem %@", vid, iid, inventory, inventoryItem);
		//Send the trap set request on trap
		[[BTNetwork sharedNetwork] performHttpOperationWithResponseObject:self
														  methodSignature:NSStringFromSelector(@selector(didDropTrap:))
																   method:@"POST"
																   domain:kHTTPHost
															  relativeURL:@"SetTrap/"
																   params:[NSDictionary dictionaryWithObjectsAndKeys:
																		   vid, @"vid",
																		   iid, @"iid",
																		@"1234", @"deviceToken",
																		   nil]];

	}
	
	[super viewDidAppear:animated];

}

-(void)didDropTrap:(id)returnData{
	NSString *responseString = [[NSString alloc] initWithData:returnData encoding:NSUTF8StringEncoding];
	
	SBJSON *parser = [SBJSON new];
	NSDictionary* responseAsDictionary = [parser objectWithString:responseString error:NULL];
	NSLog(@"response from dropping trap is %@", responseAsDictionary);
	
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
    return 2;
}

-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
	int height;
	switch ([indexPath row]) {
		case 0:
			height = venuerowheight;
			break;		
		case 1:
			//not sure why I need that last 20 pixels
			height = iphonescreenheight - venuerowheight -(navbarheight*2)-20; 
			break;
		default:
			break;
	}
	return height;
}

// Customize the appearance of table view cells.
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
	int row = [indexPath row];
	NSString *CellIdentifier = [NSString stringWithFormat:@"venuedetail%d", row];
    
	UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
	
	if (cell == nil){
		switch (row) {
			case 0:
				cell = [self getTitleCell:CellIdentifier];
				break;
			case 1:
				cell = [self getMapCell:CellIdentifier];
				break;
				
			default:
				cell = [[[UITableViewCell alloc] initWithFrame:CGRectZero reuseIdentifier:@"HomeCell"] autorelease];
				[cell setBackgroundColor:[UIColor redColor]];
				[cell setText:@"cool"];
				break;
		}
	}
    
    // Set up the cell...
	//[cell setText:@"test"];
    return cell;
}

- (UITableViewCell *) getMapCell:(NSString *)cellIdentifier{
	CGRect mapFrame = CGRectMake(0, 0, 
								 iphonescreenwidth, 
								 iphonescreenheight - venuerowheight - navbarheight - 69);
	
	UITableViewCell *cell = [[[UITableViewCell alloc] initWithFrame:mapFrame 
													reuseIdentifier:cellIdentifier] autorelease];
	
	//Handle Map things:
	MKCoordinateRegion region;
	MKCoordinateSpan span;
	span.latitudeDelta=0.0025;
	span.longitudeDelta=0.0025;
	
	CLLocationCoordinate2D location;
	location.longitude = [[venueInfo objectForKey:@"geolong"] doubleValue];
	location.latitude = [[venueInfo objectForKey:@"geolat"] doubleValue];
	
	region.center = location;
	region.span = span;
	if(mapView == nil){
		mapView = [[MKMapView alloc] initWithFrame:mapFrame];
	}
	[mapView setRegion:region animated:TRUE];
	[mapView regionThatFits:region];
	[cell.contentView addSubview:mapView];
	return cell;
}

- (UITableViewCell *) getTitleCell:(NSString *)cellIdentifier{
	NSLog(@"Search Results and Venue Detail: %@, \n\n\n\%@", searchResults, venueInfo);
	CGRect titleHalfCellFrame = CGRectMake(0, 0, iphonescreenwidth, venuerowheight/2);
	CGRect titleCellFrame = CGRectMake(0, 0, iphonescreenwidth, venuerowheight);
	CGRect titleTextFrame = CGRectMake(25, 3, iphonescreenwidth, venuerowheight/4);
	CGRect addressTextFrame = CGRectMake(25, venuerowheight/4 - 7, iphonescreenwidth, venuerowheight/4);
	CGRect alertStatmentFrame = CGRectMake(0, venuerowheight/2, iphonescreenwidth, venuerowheight/2);
	CGRect dropTrapsButtonFrame = CGRectMake(iphonescreenwidth/4*3, venuerowheight/2, iphonescreenwidth/4, venuerowheight/2);
	
	UITableViewCell *cell = [[[UITableViewCell alloc] initWithFrame:titleCellFrame 
													reuseIdentifier:cellIdentifier] autorelease];
	NSString *venueName = [venueInfo objectForKey:@"name"];
	NSString *venueAddress = [venueInfo objectForKey:@"address"];
	
	[cell setBackgroundColor:[UIColor blackColor]];
	
	UIImageView *ProfileBarTmp;
	ProfileBarTmp = [[UIImageView alloc] initWithFrame:titleHalfCellFrame];
	ProfileBarTmp.tag = 0;
	
	UIImage *BarImage = [UIImage imageNamed:@"profilebar.png"];
	[ProfileBarTmp setImage:BarImage];
	[cell.contentView addSubview:ProfileBarTmp];
	
	
	UILabel *lblTemp;
	lblTemp = [[UILabel alloc] initWithFrame:titleTextFrame];
	lblTemp.tag = 1;
	[lblTemp setBackgroundColor:[UIColor clearColor]];
	[lblTemp setText:venueName];
	[lblTemp setTextColor:[UIColor blackColor]];
	[cell.contentView addSubview:lblTemp];
	[lblTemp release];
	
	lblTemp = [[UILabel alloc] initWithFrame:addressTextFrame];
	lblTemp.tag = 2;
	[lblTemp setBackgroundColor:[UIColor clearColor]];
	[lblTemp setText:venueAddress];
	[lblTemp setAdjustsFontSizeToFitWidth:TRUE];
	[lblTemp setTextColor:[UIColor grayColor]];
	[cell.contentView addSubview:lblTemp];
	[lblTemp release];
	
	lblTemp = [[UILabel alloc] initWithFrame:alertStatmentFrame];
	lblTemp.tag = 3;
	[lblTemp setBackgroundColor:[UIColor clearColor]];
	[lblTemp setText:[searchResults objectForKey:@"alertStatement"]];
	[lblTemp setAdjustsFontSizeToFitWidth:TRUE];
	[lblTemp setTextColor:[UIColor grayColor]];
	[cell.contentView addSubview:lblTemp];
	[lblTemp release];
	
	UIButton *dropTrapsButton = [UIButton buttonWithType:UIButtonTypeRoundedRect];
	[dropTrapsButton setFrame:dropTrapsButtonFrame];
	[dropTrapsButton setTitle:@"drop" forState:UIControlStateNormal];
	NSLog(@"%@", [[searchResults objectForKey:@"hasTraps"] class]);
	if([searchResults objectForKey:@"hasTraps"]){
		[cell.contentView addSubview:dropTrapsButton];
		//listen for clicks
		[dropTrapsButton addTarget:self action:@selector(dropTrapButtonPushed) 
			   forControlEvents:UIControlEventTouchUpInside];
		
	}
	return cell;
}

- (void)dropTrapButtonPushed{
	if(inventoryView == nil){
		inventoryView = [[BTUserInventoryTableView alloc] init];
	}
	[inventoryView setUserInventory:[searchResults objectForKey:@"inventory"]];
	[self.navigationController pushViewController:inventoryView animated:TRUE];
	//[inventoryView release];
}

- (void)dealloc {
	[mapView release];
	[inventoryView release];
    [super dealloc];
}


@end

