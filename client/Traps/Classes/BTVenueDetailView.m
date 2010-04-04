//
//  BTVenueDetailView.m
//  Traps
//
//  Created by Roderic Campbell on 4/3/10.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import "BTVenueDetailView.h"
#import "BTConstants.h"

@implementation BTVenueDetailView

@synthesize venueInfo;	
@synthesize mapView;

- (void)updateVenueDetails:(NSDictionary *)venue{
	venueInfo = venue;
	NSLog(@"venueInfo is: %@", venueInfo);
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
		NSLog(@"mapview is null");
	}
	[mapView setRegion:region animated:TRUE];
	[mapView regionThatFits:region];
	[cell.contentView addSubview:mapView];
	return cell;
}
	
	
- (UITableViewCell *) getTitleCell:(NSString *)cellIdentifier{
	
	CGRect titleHalfCellFrame = CGRectMake(0, 0, iphonescreenwidth, venuerowheight/2);
	CGRect titleCellFrame = CGRectMake(0, 0, iphonescreenwidth, venuerowheight);
	CGRect titleTextFrame = CGRectMake(25, 3, iphonescreenwidth, venuerowheight/4);
	CGRect addressTextFrame = CGRectMake(25, venuerowheight/4 - 7, iphonescreenwidth, venuerowheight/4);
	CGRect checkinButtonFrame = CGRectMake(iphonescreenwidth/4, venuerowheight/2, iphonescreenwidth/2, venuerowheight/2);
	
	NSLog(@"venue here in this cell should be %@", venueInfo);
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
	
	
	UIButton *searchButton = [UIButton buttonWithType:UIButtonTypeRoundedRect];
	
	searchButton.frame = checkinButtonFrame;
	[searchButton setTitle:@"Search this Venue" forState:UIControlStateNormal];
	[searchButton setBackgroundColor:[UIColor blackColor]];
	//Set Background image
	//[searchButton setBackgroundImage:[UIImage imageNamed:@"searchnow.png"] forState:UIControlStateNormal];
	
	//listen for clicks
	//[searchButton addTarget:self action:@selector(dropTrapButtonPushed) 
//		   forControlEvents:UIControlEventTouchUpInside];	
	
	//put button on View
	[cell.contentView addSubview:searchButton];
	
	return cell;
}



- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    // Navigation logic may go here. Create and push another view controller.
	// AnotherViewController *anotherViewController = [[AnotherViewController alloc] initWithNibName:@"AnotherView" bundle:nil];
	// [self.navigationController pushViewController:anotherViewController];
	// [anotherViewController release];
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
    [super dealloc];
}


@end

