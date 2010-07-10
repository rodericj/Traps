//
//  BTVenueSearchResults.m
//  Traps
//
//  Created by Roderic Campbell on 4/4/10.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import "BTVenueSearchResults.h"
#import "BTSearchResultsAnnotationView.h"
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
	NSLog(@"the selected trap is %d", trap);
	[[BTUserProfile sharedBTUserProfile] setSelectedTrap:-1];
	NSString *deviceToken = [[BTUserProfile sharedBTUserProfile] deviceToken];
	
	if(trap != -1){
		NSLog(@"the trap has been selected, send to server");
		NSString *vid = [NSString stringWithFormat:@"%@", [venueInfo objectForKey:@"id"]];
		NSDictionary *profile = [searchResults objectForKey:@"profile"];
		NSArray *inventory = [profile objectForKey:@"inventory"];
		NSDictionary *inventoryItem = [inventory objectAtIndex:trap];
		NSString *iid = [NSString stringWithFormat:@"%@", [inventoryItem objectForKey:@"id"]];
		NSLog(@"the trap has been selected, send to server");
		//Send the trap set request on trap
		[[BTNetwork sharedNetwork] performHttpOperationWithResponseObject:self
														  methodSignature:NSStringFromSelector(@selector(didDropTrap:))
																   method:@"POST"
																   domain:kHTTPHost
															  relativeURL:django_set_trap
																   params:[NSDictionary dictionaryWithObjectsAndKeys:
																		   vid, @"vid",
																		   iid, @"iid",
																		deviceToken, @"deviceToken",
																		   nil] 
																  headers:nil];

	}
	
	[super viewDidAppear:animated];

}

-(void)didDropTrap:(id)returnData{
	NSLog(@"didDropTrap");
	NSString *responseString = [[NSString alloc] initWithData:returnData encoding:NSUTF8StringEncoding];
	NSLog(@"responseString %@", responseString);
	SBJSON *parser = [SBJSON new];
	NSDictionary* responseAsDictionary = [parser objectWithString:responseString error:NULL];
	[parser release];
	NSLog(@"response from dropping trap is %@", responseAsDictionary);
	[mapView removeAnnotation:pin];
	[searchResults setValue:yousetatrap forKey:@"alertStatement"];
	CLLocationCoordinate2D location;
	location.latitude = [[venueInfo objectForKey:@"geolat"] doubleValue];
	location.longitude = [[venueInfo objectForKey:@"geolong"] doubleValue];
	
	pin = [[BTVenueAnnotation alloc] initWithCoordinate:location];
	[mapView addAnnotation:pin];
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
   	[self.tableView setScrollEnabled:FALSE];
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
				[cell.textLabel setText:@"cool"];
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
	//location.longitude = [[venueInfo objectForKey:@"geolong"] doubleValue]+.0020;
//	location.latitude = [[venueInfo objectForKey:@"geolat"] doubleValue] -.0010;
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
	[mapView setDelegate:self];
	return cell;
}

- (void) mapViewDidFinishLoadingMap:(MKMapView *)amapView{
	NSLog(@"mapviewdidfinishloadingmap");
	CLLocationCoordinate2D location;
	location.latitude = [[venueInfo objectForKey:@"geolat"] doubleValue];
	location.longitude = [[venueInfo objectForKey:@"geolong"] doubleValue];
	
	pin = [[BTVenueAnnotation alloc] initWithCoordinate:location];
	[amapView addAnnotation:pin];
}

- (MKAnnotationView *) mapView:(MKMapView *)mapView viewForAnnotation:(id <MKAnnotation>) annotation{
	
	BTSearchResultsAnnotationView *annView = [[BTSearchResultsAnnotationView alloc] initWithAnnotation:annotation reuseIdentifier:@"currentloc"];
	
	annView.canShowCallout = YES;
	annView.calloutOffset = CGPointMake(-5, 5);
	
	//TODO if this is a happy dude.....
	[annView setDudeIcon:@"happyDude.png"];

	if([[BTUserProfile sharedBTUserProfile] selectedTrap] != -1){
		[annView setResultsString:@"hello"];
	}
	else{
		[annView setResultsString:[searchResults objectForKey:@"alertStatement"]];
	}
    return annView;
}

- (UITableViewCell *) getTitleCell:(NSString *)cellIdentifier{
	//NSLog(@"Search Results and Venue Detail: %@, \n\n\n\%@", searchResults, venueInfo);

	CGRect titleCellFrame = CGRectMake(0, 0, iphonescreenwidth, venuerowheight);
	CGRect titleTextFrame = CGRectMake(25, 10, iphonescreenwidth, venuerowheight/4);
	CGRect addressTextFrame = CGRectMake(25, venuerowheight/4, iphonescreenwidth, venuerowheight/4);
	//CGRect alertStatmentFrame = CGRectMake(0, venuerowheight/2, iphonescreenwidth, venuerowheight/2);
	CGRect dropTrapsButtonFrame = CGRectMake(iphonescreenwidth - 120, 35, 115*.75, 43*.75);
	
	UITableViewCell *cell = [[[UITableViewCell alloc] initWithFrame:titleCellFrame 
													reuseIdentifier:cellIdentifier] autorelease];
	NSString *venueName = [venueInfo objectForKey:@"name"];
	NSString *venueAddress = [venueInfo objectForKey:@"address"];
	
	[cell setBackgroundColor:[UIColor blackColor]];
	
	UIImageView *ProfileBarTmp;
	ProfileBarTmp = [[UIImageView alloc] initWithFrame:titleCellFrame];
	ProfileBarTmp.tag = 0;
	
	UIImage *BarImage = [UIImage imageNamed:@"profilebar.png"];
	[ProfileBarTmp setImage:BarImage];
	[cell.contentView addSubview:ProfileBarTmp];
	
	
	UILabel *lblTemp;
	lblTemp = [[UILabel alloc] initWithFrame:titleTextFrame];
	lblTemp.tag = 1;
	[lblTemp setBackgroundColor:[UIColor clearColor]];
	[lblTemp setText:venueName];
	[lblTemp setTextColor:[UIColor whiteColor]];
	[lblTemp setShadowColor:[UIColor blackColor]];
	[cell.contentView addSubview:lblTemp];
	[lblTemp release];
	
	lblTemp = [[UILabel alloc] initWithFrame:addressTextFrame];
	lblTemp.tag = 2;
	[lblTemp setBackgroundColor:[UIColor clearColor]];
	[lblTemp setText:venueAddress];
	[lblTemp setAdjustsFontSizeToFitWidth:TRUE];
	[lblTemp setTextColor:[UIColor whiteColor]];
	[cell.contentView addSubview:lblTemp];
	[lblTemp release];
		
	dropTrapsButton = [UIButton buttonWithType:UIButtonTypeCustom];
	[dropTrapsButton setFrame:dropTrapsButtonFrame];
	[dropTrapsButton setBackgroundImage:[UIImage imageNamed:@"droptrap.png"] forState:UIControlStateNormal];
	
	//If we don't have traps, don't bother showing the drop trap button.
	if([searchResults objectForKey:@"hasTraps"]){
		[cell.contentView addSubview:dropTrapsButton];
		//listen for clicks
		[dropTrapsButton addTarget:self action:@selector(dropTrapButtonPushed) 
			   forControlEvents:UIControlEventTouchUpInside];
		
	}
	return cell;
}

- (void)dropTrapButtonPushed{
	[dropTrapsButton setEnabled:FALSE];
	if(inventoryView == nil){
		inventoryView = [[BTUserInventoryTableView alloc] init];
	}
	[inventoryView setUserInventory:[searchResults objectForKey:@"inventory"]];
	[inventoryView setTrapsOnly:TRUE];
	[self.navigationController pushViewController:inventoryView animated:TRUE];
	//[inventoryView release];
}

- (void)dealloc {
	[mapView release];
	[inventoryView release];
    [super dealloc];
}


@end

