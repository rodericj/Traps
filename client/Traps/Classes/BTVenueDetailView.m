//
//  BTVenueDetailView.m
//  Traps
//
//  Created by Roderic Campbell on 4/3/10.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import "BTVenueDetailView.h"
#import "BTConstants.h"
#import "BTNetwork.h"
#import "BTVenueAnnotationView.h"

#import <JSON/JSON.h>

@implementation BTVenueDetailView

@synthesize venueInfo;	
@synthesize mapView;
@synthesize searchResultsView;

- (void)updateVenueDetails:(NSDictionary *)venue{
	venueInfo = venue;
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
	NSLog(@"%d", [indexPath row]);
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
- (void) mapViewDidFinishLoadingMap:(MKMapView *)amapView{
	NSLog(@"mapviewdidfinishloadingmap");
	CLLocationCoordinate2D location;
	location.latitude = [[venueInfo objectForKey:@"geolat"] doubleValue];
	location.longitude = [[venueInfo objectForKey:@"geolong"] doubleValue];
					
	pin = [[BTVenueAnnotation alloc] initWithCoordinate:location];
	[amapView addAnnotation:pin];
}

- (MKAnnotationView *) mapView:(MKMapView *)mapView viewForAnnotation:(id <MKAnnotation>) annotation{
	
	BTVenueAnnotationView *annView = [[BTVenueAnnotationView alloc] initWithAnnotation:annotation reuseIdentifier:@"currentloc"];
	
	annView.canShowCallout = YES;
	annView.calloutOffset = CGPointMake(-5, 5);
	[annView setVenueName:[venueInfo objectForKey:@"name"]];
	[annView setChanceOfDrop:@"10%"];
	[annView setDudeIcon:@"neutralDude.png"];
	
	UIButton *rightButton = [UIButton buttonWithType:UIButtonTypeDetailDisclosure];
	[rightButton addTarget:self
					action:@selector(searchVenue)
		  forControlEvents:UIControlEventTouchUpInside];
	
	[annView setRightCalloutAccessoryView:rightButton];
    return annView;
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
	
	//CLLocationCoordinate2D locationOffset;
//	locationOffset.longitude = [[venueInfo objectForKey:@"geolong"] doubleValue]+.0020;
//	locationOffset.latitude = [[venueInfo objectForKey:@"geolat"] doubleValue]-.0010;
	
	region.center = location;
	region.span = span;
	if(mapView == nil){
		mapView = [[MKMapView alloc] initWithFrame:mapFrame];
	}
	[mapView setRegion:region animated:TRUE];
	[mapView regionThatFits:region];
	[mapView setDelegate:self];
	[cell.contentView addSubview:mapView];
	return cell;
}
	
	
- (UITableViewCell *) getTitleCell:(NSString *)cellIdentifier{
	
	CGRect titleCellFrame = CGRectMake(0, 0, iphonescreenwidth, venuerowheight);
	CGRect titleTextFrame = CGRectMake(25, 10, iphonescreenwidth, venuerowheight/4);
	CGRect addressTextFrame = CGRectMake(25, venuerowheight/4, iphonescreenwidth, venuerowheight/4);
	
	UITableViewCell *cell = [[[UITableViewCell alloc] initWithFrame:titleCellFrame 
													reuseIdentifier:cellIdentifier] autorelease];
	NSString *venueName = [venueInfo objectForKey:@"name"];
	NSString *venueAddress = [venueInfo objectForKey:@"address"];

	[cell setBackgroundColor:[UIColor blackColor]];
	
	UIButton *searchButton = [UIButton buttonWithType:UIButtonTypeRoundedRect];
	[searchButton setBackgroundImage:[UIImage imageNamed:@"searchvenuebar.png"] forState:UIControlStateNormal];
	searchButton.frame = titleCellFrame;
	[searchButton setBackgroundColor:[UIColor clearColor]];

	//listen for clicks
	[searchButton addTarget:self action:@selector(searchVenue) 
		   forControlEvents:UIControlEventTouchUpInside];	
	
	//put button on View
	[cell.contentView addSubview:searchButton];
	
	UILabel *lblTemp;
	lblTemp = [[UILabel alloc] initWithFrame:titleTextFrame];
	lblTemp.tag = 1;
	[lblTemp setBackgroundColor:[UIColor clearColor]];
	[lblTemp setText:venueName];
	[lblTemp setTextColor:[UIColor whiteColor]];
	[lblTemp setShadowOffset:CGSizeMake(1, 0)]; 
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
	
	return cell;
}

-(void)searchVenue{

	//TODO start the loading scroller thing
	NSString *vid = [NSString stringWithFormat:@"%@", [venueInfo objectForKey:@"id"]];
	[[BTNetwork sharedNetwork] performHttpOperationWithResponseObject:self
													  methodSignature:NSStringFromSelector(@selector(didSearchVenue:))
															   method:@"POST"
															   domain:kHTTPHost
														  relativeURL:django_search_venue
															   params:[NSDictionary dictionaryWithObjectsAndKeys:
																	   vid, @"vid",
																	   nil] 
															  headers:nil];
}

- (void)didSearchVenue:(id)returnData{
	//TODO stop the loading scroller thing
	//TODO the button is pushable 2x. boooo
	NSString *responseString = [[NSString alloc] initWithData:returnData encoding:NSUTF8StringEncoding];

	SBJSON *parser = [SBJSON new];
	NSDictionary* responseAsDictionary = [parser objectWithString:responseString error:NULL];

	if(searchResultsView == nil){
		BTVenueSearchResults *aResultsView = [[BTVenueSearchResults alloc] init];
		searchResultsView = aResultsView;
	}

	//set the values of the view
	[searchResultsView setSearchResults:responseAsDictionary];
	[searchResultsView setVenueInfo:venueInfo];

	//push the view controller
	[self.navigationController pushViewController:searchResultsView animated:TRUE];

}

- (void)dealloc {
	[mapView release];
	[searchResultsView release];

    [super dealloc];
}


@end

