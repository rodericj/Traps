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
#import "BTUserProfile.h"
#import "MPURLRequestParameter.h"

#import "JSON.h"

@implementation BTVenueDetailView

@synthesize venueInfo;	
@synthesize mapView;
@synthesize searchResultsView;
@synthesize pin;

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
	return 3;
}

-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
	int height;
	NSLog(@"%d", [indexPath row]);
	switch ([indexPath row]) {
		case 0:
			height = venuerowheight;
			break;		
		case 1:
			height = iphonescreenheight - venuerowheight - wantfoursquarecheckinrowheight - (navbarheight*2)-20; 
			height = detailmapviewheight;
			break;
		case 2:
			height = wantfoursquarecheckinrowheight;
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
			case 2:
				cell = [self getOptionRow:CellIdentifier whichOption:0];
				break;
			default:
				cell = [[[UITableViewCell alloc] initWithFrame:CGRectZero reuseIdentifier:@"HomeCell"] autorelease];
				[cell setBackgroundColor:[UIColor redColor]];
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
								 detailmapviewheight);
								 //iphonescreenheight - venuerowheight - navbarheight - 69);

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
	
- (UITableViewCell *) getOptionRow:(NSString *)cellIdentifier whichOption:(int)option{
	CGRect rowFrame = CGRectMake(0, 0, iphonescreenwidth, wantfoursquarecheckinrowheight);
	CGRect textFrame = CGRectMake(25, wantfoursquarecheckinrowheight/3, iphonescreenwidth, 15);
	CGRect switchFrame = CGRectMake(206, (wantfoursquarecheckinrowheight-27)/2, 94, 27);

	UITableViewCell *cell = [[[UITableViewCell alloc] initWithFrame:rowFrame 
	
													reuseIdentifier:cellIdentifier] autorelease];
	
	UIImageView *ProfileBarTmp;
	ProfileBarTmp = [[UIImageView alloc] initWithFrame:rowFrame];
	ProfileBarTmp.tag = 0;
	
	UIImage *BarImage = [UIImage imageNamed:@"profilebar.png"];
	[ProfileBarTmp setImage:BarImage];
	[cell.contentView addSubview:ProfileBarTmp];
	
	UILabel *lblTemp;
	lblTemp = [[UILabel alloc] initWithFrame:textFrame];
	lblTemp.tag = 1;
	[lblTemp setBackgroundColor:[UIColor clearColor]];
	[lblTemp setText:doyouwanttocheckin];
	[lblTemp setFont:[UIFont systemFontOfSize:14]];
	[lblTemp setTextColor:[UIColor whiteColor]];
	//[lblTemp setShadowOffset:CGSizeMake(1, 0)]; 
	//[lblTemp setShadowColor:[UIColor whiteColor]];
	[cell.contentView addSubview:lblTemp];
	
	//listen for clicks on the text there
	//[lblTemp addTarget:self action:@selector(clearCredentials) 
//			forControlEvents:UIControlEventTouchUpInside];
//	[lblTemp release];
	
	[lblTemp release];	
	
	if(checkinSwitch == nil){
		checkinSwitch = [[UISwitch alloc] initWithFrame:switchFrame];
	}
	[cell.contentView addSubview:checkinSwitch];
	
	//listen for changes
	[checkinSwitch addTarget:self action:@selector(authenticateFoursquare) 
		   forControlEvents:UIControlEventTouchUpInside];
	[checkinSwitch release];
	return cell;
	
}

- (UITableViewCell *) getTitleCell:(NSString *)cellIdentifier{
	
	CGRect titleCellFrame = CGRectMake(0, 0, iphonescreenwidth, venuerowheight);
	CGRect titleTextFrame = CGRectMake(25, 10, iphonescreenwidth, venuerowheight/4);
	CGRect addressTextFrame = CGRectMake(25, venuerowheight/4, iphonescreenwidth, venuerowheight/4);
	CGRect ButtonFrame = CGRectMake(320/4, 50, 169, 36);

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
	 
	
	searchButton = [UIButton buttonWithType:UIButtonTypeCustom];
	[searchButton setBackgroundImage:[UIImage imageNamed:@"searchnow.png"] forState:UIControlStateNormal];
	searchButton.frame = ButtonFrame;
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

#pragma mark -
#pragma mark UI Interactions
-(void)searchVenue{
	NSString *vid = [NSString stringWithFormat:@"%@", [venueInfo objectForKey:@"id"]];
	[searchButton setEnabled:FALSE];
	[searchButton setShowsTouchWhenHighlighted:FALSE];
	NSLog(@"checking into %@", vid);
	MPOAuthAPI *_oauthAPI = [[BTUserProfile sharedBTUserProfile] _oauthAPI];
	NSLog(@"The shared oauthAPI object is");
	NSLog(@"%@", _oauthAPI);
	if([_oauthAPI isAuthenticated] && [checkinSwitch isOn]){
		NSLog(@"YESSSSSSS lets do the checkin!!!!");
		NSLog(@"we are supposed to checkin");
		
		NSMutableArray *params = [[NSMutableArray alloc ] init];
		
		MPURLRequestParameter *venueParam = [[[MPURLRequestParameter alloc] init] autorelease];
		[venueParam setName:@"vid"];
		[venueParam setValue:vid];
		[params addObject:venueParam];
		[venueParam release];
		
		NSLog(@"calling perform %@", _oauthAPI);
		[_oauthAPI performPOSTMethod:foursquare_checkin_endpoint atURL:_oauthAPI.baseURL withParameters:params withTarget:self andAction:@selector(didCheckinOnFoursquare:withValue:)];
		NSLog(@"done calling perform");
		
	}
	else{
		NSLog(@"ok, we either not authenticated or not suppoesd to checkin or both");
		if([_oauthAPI isAuthenticated]){
			NSLog(@"we are authenticated....");
		}
		else{
			NSLog(@"so what is the authentication state?");
			NSLog(@"%@", [_oauthAPI authenticationState]);
		}
		if([checkinSwitch isOn]){
			NSLog(@"we are supposed to checkin");
			
			NSMutableArray *params = [[NSMutableArray alloc ] init];

			MPURLRequestParameter *venueParam = [[[MPURLRequestParameter alloc] init] autorelease];
			[venueParam setName:@"vid"];
			[venueParam setValue:vid];
			[params addObject:venueParam];
			[venueParam release];
			
			NSLog(@"calling perform %@", _oauthAPI);
			[_oauthAPI performPOSTMethod:foursquare_checkin_endpoint atURL:_oauthAPI.baseURL withParameters:params withTarget:self andAction:@selector(didCheckinOnFoursquare:withValue:)];
			NSLog(@"done calling perform");

		}
	}
	
	[UIApplication sharedApplication].networkActivityIndicatorVisible = YES;

	_spinner = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleWhiteLarge];
	[_spinner setFrame:CGRectMake(iphonescreenwidth/2-20, iphonescreenheight/2 - navbarheight - iphonetabbarheight - inventoryitemheight, 40, 40)];
	[self.view addSubview:_spinner];
	[_spinner startAnimating];
	
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

-(void) didCheckinOnFoursquare:(NSString *)methodCalled withValue:(NSString *)returned{
	NSLog(@"WOOOOOOT! we did checking on foursquare");
	NSLog(@"returned %@ %@", methodCalled, returned);
	//BOOL gotSomething = FALSE;
	//Get the JSON object from the string
	SBJSON *parser = [SBJSON new];
	NSDictionary *responseAsDict = [parser objectWithString:returned error:NULL];
	NSLog(@"Response as dict is %@", responseAsDict);
	NSDictionary *checkinDict = [responseAsDict objectForKey:@"checkin"];
	
	NSLog(@"checkinDict is %@", checkinDict);
	
	//if message != nil
	NSString *message = [checkinDict objectForKey:@"message"];
	if (message != nil) {	
		UIAlertView *alert;
		alert = [[UIAlertView alloc] initWithTitle:@"Foursquare" message:message delegate:self cancelButtonTitle:@"Ok" otherButtonTitles:nil]; 
		[alert show];
		[alert release];
	}
	
	//if message != nil
	NSString *unauthorized = [responseAsDict objectForKey:@"unauthorized"];
	NSLog(@"unauth %@", unauthorized);
	if (unauthorized != nil) {	
		UIAlertView *alert;
		alert = [[UIAlertView alloc] initWithTitle:@"Foursquare unauthorized" message:unauthorized delegate:self cancelButtonTitle:@"Ok" otherButtonTitles:nil]; 
		[alert show];
		[alert release];
	}
	
	
}

#pragma mark -
#pragma mark oauth relevant methods
- (void)clearCredentials {
	MPOAuthAPI *_oauthAPI = [[BTUserProfile sharedBTUserProfile] _oauthAPI];
	[_oauthAPI discardCredentials];
	UIAlertView *alert;
	alert = [[UIAlertView alloc] initWithTitle:@"OAuth" message:@"OAuth credentials cleared" delegate:self cancelButtonTitle:@"Ok" otherButtonTitles:nil]; 
	[alert show];
	[alert release];
}

-(void) authenticateFoursquare{
	NSLog(@"this is the switch: are there 2 of them? %@", checkinSwitch);
	@synchronized(self){
		NSLog(@"we are in the synchronized");
		if([checkinSwitch isOn]){
			NSLog(@"Switched the switch ");
			MPOAuthAPI *_oauthAPI = [[BTUserProfile sharedBTUserProfile] _oauthAPI];
			NSLog(@"the credential for access token is %@", [_oauthAPI credentialNamed:MPOAuthCredentialAccessTokenKey]);
			NSLog(@"Authentication state is more important... object: %@ %d", _oauthAPI, [_oauthAPI authenticationState]);
			//if([_oauthAPI credentialNamed:MPOAuthCredentialAccessTokenKey] != nil){
			if([_oauthAPI authenticationState] == MPOAuthAuthenticationStateAuthenticated){

				// #TODO. For some reason we are getting authenticated here. That's not right
				NSLog(@"We are authenticated, so you should be able to log in.");
				
			}
			else{
				NSLog(@"no we aren't authenticated");
				if (foursquareLoginView == nil) {
					foursquareLoginView = [[BTFoursquareLoginViewController alloc] init];
					NSLog(@"we've got the foursquare view set up");
					NSLog(@"and we've set the text");
				}
				[foursquareLoginView setViewDescription:foursquarecheckinprefered];

				[self presentModalViewController:foursquareLoginView animated:NO];

				//return;
			}
		}
	}
}

- (void)didSearchVenue:(id)returnData{ 
	[_spinner stopAnimating];
	[_spinner release];
	[UIApplication sharedApplication].networkActivityIndicatorVisible = NO;
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
	[checkinSwitch release];
    [super dealloc];
}


@end

