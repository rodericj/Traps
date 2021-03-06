//
//  BTSearchInternalViewController.m
//  Traps
//
//  Created by Roderic Campbell on 3/14/10.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import "BTSearchInternalViewController.h"
#import "BTNetwork.h"
#import "BTUserProfile.h"
#import "JSON.h"
#import "MPURLRequestParameter.h"

@implementation BTSearchInternalViewController

@synthesize venueDetailView;
@synthesize venues;

#pragma mark -
#pragma mark Initialization

- (id)init {
    if ((self = [super initWithStyle:UITableViewStylePlain]) == nil) {
		return nil;
    }
			
	//self.title = kSearchTitle;
	
    return self;
}


#pragma mark -
#pragma mark Cleanup

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
	
	//XXX: purge unnecessary data structures
}

- (void)dealloc {	
	if(foursquareLoginView){
		[foursquareLoginView release];
	}
    [super dealloc];
}

#pragma mark -
#pragma mark UIViewController

- (void)viewDidLoad {
    [super viewDidLoad];
	
	[self restartLocationGatheringIndicator];

}

-(void)restartLocationSearch{
	NSLog(@"restartLocationSearch");
	[self restartLocationGatheringIndicator];
	[self kickOffLocationManager];
}

-(void)restartLocationGatheringIndicator{
	NSLog(@"restart indicator");
	CGRect frame = CGRectMake(0.0, 0.0, 25.0, 25.0);
	UIActivityIndicatorView *loading = [[UIActivityIndicatorView alloc] initWithFrame:frame];
	[loading startAnimating];
	[loading sizeToFit];
	loading.autoresizingMask = (UIViewAutoresizingFlexibleLeftMargin |
								UIViewAutoresizingFlexibleRightMargin |
								UIViewAutoresizingFlexibleTopMargin |
								UIViewAutoresizingFlexibleBottomMargin);
	
	// initing the bar button
	UIBarButtonItem *loadingView = [[UIBarButtonItem alloc] initWithCustomView:loading];
	[loading release];
	loadingView.target = self;
	//self.title = @"Locations";
	self.navigationItem.rightBarButtonItem = loadingView;
}
- (void)kickOffLocationManager{
	NSLog(@"kickoff locatin manager");
	
	locationController = [[MyCLController alloc] init];
	locationController.delegate = self;
	locationController.locationManager.desiredAccuracy = kCLLocationAccuracyNearestTenMeters;
	[locationController.locationManager startUpdatingLocation];
}
- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
	NSLog(@"view will appear, find the location");
	[self kickOffLocationManager];
}

- (void)viewDidDisappear:(BOOL)animated {
	[super viewDidDisappear:animated];
	
	//XXX: add code here
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

#pragma mark -
#pragma mark UITableView

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
	return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
	if(venues == nil){
		return 0;
	}
    return [venues count];
}


- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
	
	NSInteger row = [indexPath row];
	
	if(venueDetailView != nil){
		venueDetailView = nil;
	}	
	
	BTVenueDetailView *aVenueDetail = [[BTVenueDetailView alloc] init];
	venueDetailView = aVenueDetail;
	
	NSDictionary *venue = [venues objectAtIndex:row];
	[venueDetailView updateVenueDetails:venue];
	
	[self.navigationController pushViewController:venueDetailView animated:TRUE];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
	NSString *reuseId = [NSString stringWithFormat:@"venue%d", [indexPath row]];
	UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:reuseId];

	if(cell == nil){
		cell = [self getVenueCell:reuseId venue:[venues objectAtIndex:[indexPath row]]];
	}
	
	NSDictionary *currentVenue = [venues objectAtIndex:[indexPath row]];
	
	[cell.textLabel setText:[currentVenue objectForKey:@"name"]];
    return cell;
}

- (UITableViewCell *) getVenueCell:(NSString *)cellIdentifier venue:(NSDictionary *)venue{
	UITableViewCell *cell = [[[UITableViewCell alloc] initWithFrame:CGRectMake(90, 15, 120, 25) 
													reuseIdentifier:cellIdentifier] autorelease];

	return cell;
}
#pragma mark -
#pragma mark Location

- (void)locationUpdate:(CLLocation *)location {

	[self getNearbyLocations:location];
	locationController = [[MyCLController alloc] init];
	locationController.delegate = self;
	//[locationController.locationManager stopUpdatingLocation];
}

- (void)getNearbyLocations:(CLLocation *)location {
	NSLog(@"getNearbyLocations Called %@. Accuracy: %d, %d", [location description], location.verticalAccuracy, location.horizontalAccuracy);
	
	if (location == NULL){
		NSLog(@"the location was null which means that the thread is doing something intersting. Lets send this back.");
	}
	else{
		//Make location string 2 separate lat/long
		NSString *latlong = [[[location description] stringByReplacingOccurrencesOfString:@"<" withString:@""] 
							 stringByReplacingOccurrencesOfString:@">" withString:@""];
		NSLog(@"the latlong is %@", latlong);
		NSArray *chunks = [latlong componentsSeparatedByString:@" "];
		NSString *lat =[[chunks objectAtIndex:0] stringByReplacingOccurrencesOfString:@"," withString:@""];
		NSString *lon = [chunks objectAtIndex:1];
		
		NSString *encoding = [[BTUserProfile sharedBTUserProfile] userBase64EncodedPassword];
		NSArray *headers = nil;
		if(encoding != nil){
			headers = [NSArray arrayWithObjects:encoding, @"Authorization", nil];
		}
		
		//Call to foursquare's location api
		MPOAuthAPI *_oauthAPI = [[BTUserProfile sharedBTUserProfile] _oauthAPI];
		if (!_oauthAPI) {
			NSLog(@"need to create an api object");
			NSDictionary *credentials = [NSDictionary dictionaryWithObjectsAndKeys:	
										 oauth_key, kMPOAuthCredentialConsumerKey,
										 oauth_secret, kMPOAuthCredentialConsumerSecret,
										 @"", kMPOAuthCredentialUsername,
										 @"", kMPOAuthCredentialPassword,
										 nil];
			_oauthAPI = [[MPOAuthAPI alloc] initWithCredentials:credentials
											  authenticationURL:[NSURL URLWithString:foursquare_auth_url]
													 andBaseURL:[NSURL URLWithString:foursquare_api_base]
													  autoStart:FALSE];
			[[BTUserProfile sharedBTUserProfile] set_oauthAPI:_oauthAPI];
		}
		//	NSMutableArray *parameters = [NSMutableArray arrayWithObject:[[[MPURLRequestParameter alloc] initWithName:@"file" 
//																										 andValue:@"vacation.jpg"] autorelease]];
		MPURLRequestParameter *latParam = [[MPURLRequestParameter alloc] init];
		MPURLRequestParameter *lonParam = [[MPURLRequestParameter alloc] init];
		[latParam setName:@"geolat"];
		[latParam setValue:lat];
		[lonParam setName:@"geolong"];
		[lonParam setValue:lon];
		NSMutableArray *params = [[NSMutableArray alloc ] init];
		[params addObject:latParam];
		[params addObject:lonParam];

		
		NSLog(@"the params are %@", params);
		NSLog(@"so we've got the api object, lets try to make a call");
	//	[_oauthAPI performMethod:foursquare_venues_endpoint atURL:_oauthAPI.baseURL withParameters:params withTarget:self andAction:@selector(didGetNearbyLocations:)];
	
		[[BTNetwork sharedNetwork] performHttpOperationWithResponseObject:self
														  methodSignature:NSStringFromSelector(@selector(didGetNearbyLocations:))
																   method:@"GET"
																   domain:foursquare_api
															  relativeURL:foursquare_venues_endpoint
																   params:[NSDictionary dictionaryWithObjectsAndKeys:
																		   lat, @"geolat",
																		   lon, @"geolong", 
																		   nil] 
																  headers:headers];
		[latParam release];
		[lonParam release];
		[params release];
	}
	
}
- (void)didGetNearbyLocations:(id)responseString{
	NSLog(@"did get nearby locations");
	NSString *res;
	if ([responseString isKindOfClass:[NSError class]]) {
		NSLog(@"code %d, domain %@", [responseString code], [responseString domain]);
		//TODO we should handle this better. Instead of showing default my house, perhaps alert the user
		if ([responseString code] == -1001) {
			NSLog(@"this is a timeout");
		}
		if ([responseString code] == 400) {
			NSLog(@"We've got a rate limiting situation. Let's show the modular view");
			if (foursquareLoginView == nil) {
				foursquareLoginView = [[BTFoursquareLoginViewController alloc] init];
			}
			[foursquareLoginView setViewDescription:foursquareratelimitexceeded];
			[self presentModalViewController:foursquareLoginView animated:YES];
			return;
		}
		else{
			NSLog(@"default to jackson street because there was an error");
			res = @"{\"groups\":[{\"type\":\"Nearby\",\"venues\":[{\"id\":86638,\"name\":\"Joe Greenstein's\",\"address\":\"1740 Jackson St.\",\"city\":\"San Francisco\",\"state\":\"CA\",\"geolat\":37.7938,\"geolong\":-122.424,\"stats\":{\"herenow\":\"0\"},\"distance\":31},{\"id\":1235744,\"name\":\"1800 Washington Street\",\"address\":\"1800 Washington Street\",\"city\":\"San Francisco\",\"state\":\"CA\",\"geolat\":37.793433,\"geolong\":-122.423426,\"stats\":{\"herenow\":\"0\"},\"distance\":36}]}]}";
		}
	}
	else{
		NSLog(@"Did get location and it was not an error");
		res = [[NSString alloc] initWithData:responseString encoding:NSUTF8StringEncoding];

	}
	SBJSON *parser = [SBJSON new];
	NSDictionary* webRequestResults = [parser objectWithString:res error:NULL];
	[res release];
	[parser release];

	NSArray *groups = [webRequestResults objectForKey:@"groups"];

	NSDictionary *venueDict = [groups objectAtIndex:0];
	venues = [[venueDict objectForKey:@"venues"] copy];

	[self.tableView reloadData];
	//NSLog(@"venueArray is: %@", venueArray);
	//UserProfile *userProfile = [UserProfile sharedSingleton];
//	[userProfile setLocations:venueArray];

	//self.navigationItem.rightBarButtonItem = nil;
	self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemRefresh 
																						   target:self 
																						   action:@selector(restartLocationSearch)];

	//[self didGetNearbyLocations];
}

- (void)locationError:(NSError *)error{
	//TODO handle this better.
	NSLog(@"An error occured while getting the location");
	
	[locationController.locationManager stopUpdatingLocation];
	
	UIAlertView *alert;
	alert = [[UIAlertView alloc] initWithTitle:@"Location Error" message:@"Having some trouble getting your location. Try again." delegate:self cancelButtonTitle:@"Ok" otherButtonTitles:nil]; 
	[alert show];
	[alert release];
	[self.tabBarController setSelectedIndex:0];	

}


@end
