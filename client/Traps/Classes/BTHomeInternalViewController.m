//
//  BTHomeInternalViewController.m
//  Traps
//
//  Created by Kelvin Kakugawa on 3/14/10.
//  Copyright 2010 Apple Inc. All rights reserved.
//

#import "BTHomeInternalViewController.h"
#import "TrapsAppDelegate.h"
#import "BTNetwork.h"
#import "FBConnect/FBConnect.h"

//From: from http://iphonedevelopertips.com/cocoa/json-framework-for-iphone-part-2.html
//#import "SBJSON.h"   //Included in ~/Library/SDKs 
#import <JSON/JSON.h>

@implementation BTHomeInternalViewController

#pragma mark -
#pragma mark Initialization

- (id)init {
    if ((self = [super initWithStyle:UITableViewStylePlain]) == nil) {
		return nil;
    }
	
	self.title = @"";//kHomeTitle;
														
	mySession = [[FBSession sessionForApplication:fbAppId
										   secret:fbSecret
										 delegate:self] retain];
	
    return self;
}

#pragma mark -
#pragma mark Cleanup

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
	
	//XXX: purge unnecessary data structures
}

- (void)dealloc {	
    [super dealloc];
}

#pragma mark -
#pragma mark UIViewController

- (void)viewDidLoad {
    [super viewDidLoad];
	//#TODO put the fb back in
	//FBLoginDialog* dialog = [[[FBLoginDialog alloc] initWithSession:mySession] autorelease];
//    [dialog show];
	
	//XXX: add code here
}
- (void)session:(FBSession *)session didLogin:(FBUID)uid{

	NSString *fql = [NSString stringWithFormat:
				 @"select uid, first_name, last_name, name, pic_square from user where uid= %lld", 
				 [session uid]];
	NSDictionary *params = [NSDictionary dictionaryWithObject:fql forKey:@"query"];
	[[FBRequest requestWithDelegate:self] call:@"facebook.fql.query" params:params];
}


- (void) request:(FBRequest *)request didLoad:(id)result {
	NSArray *users = result;
	NSDictionary *user = [users objectAtIndex:0];
	NSLog(@"the user returned was %@", [user objectForKey:@"last_name"]);
	
	[[BTNetwork sharedNetwork] performHttpOperationWithResponseObject:self
								methodSignature:NSStringFromSelector(@selector(ProfileLoaded:))
								method:@"POST"
								relativeURL:@"IPhoneLogin/"
								params:[NSDictionary dictionaryWithObjectsAndKeys:
								(NSString *)[user objectForKey:@"uid"], @"uname",
								(NSString *)[user objectForKey:@"uid"], @"password", 
								(NSString *)[user objectForKey:@"last_name"], @"last_name", 
								(NSString *)[user objectForKey:@"first_name"], @"first_name", 
								@"1", @"tutorial",
								nil]];
	
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
	
	//XXX: add code here
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
	//TODO There is no way this is the most appropriate place to put this. C'mon!!
	[tableView setSeparatorColor:[UIColor blackColor]];
	[tableView setScrollEnabled:NO];
    return 1;
}

-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
	if ([indexPath row] == 0) {
		return fbprofileinforowheight;
	}
	NSLog(@"our row heights: %d", (iphonescreenheight - (navbarheight*2) - fbprofileinforowheight)/3);

	return (iphonescreenheight - (navbarheight*2) - fbprofileinforowheight)/3;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
	//Game Banner
	//User Identification and logout
	//1/2 of the 2x2 of the user stats
	//the other 1/2 of the 2x2 of the user stats
	return 4;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
	UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"default"];

	NSInteger row = [indexPath row];
	NSString *reuseId = [NSString stringWithFormat:@"home%d", row];
	[cell setText:[NSString stringWithFormat:@"%d", row]];

	if (row == 3) {
		//cell = [self getBannerCell:reuseId tableView:tableView];
		if (cell == nil) {
			cell = [self getButtonCell:reuseId];
		}
	}else if (row == 2) {
		//cell = [self getBannerCell:reuseId tableView:tableView];
		if (cell == nil) {
			cell = [self getUserProfileCell:reuseId leftSide:@"health" rightSide:@"kills"];
		}
	}else if (row == 1) {
		//cell = [self getBannerCell:reuseId tableView:tableView];
		if (cell == nil) {
			cell = [self getUserProfileCell:reuseId leftSide:@"traps" rightSide:@"value"];
		}
	}else if (row == 0) {
		if (cell == nil){
			cell = [self getFBUserInfoCell:reuseId];
		}
	}else {
		//[self getUserProfileCell:reuseId tableView];
		if (cell == nil) {
			cell = [[[UITableViewCell alloc] initWithFrame:CGRectZero reuseIdentifier:@"HomeCell"] autorelease];
		}
	}
	
	//disable clicks
	cell.selectionStyle = UITableViewCellSelectionStyleNone;

    return cell;
}

- (UITableViewCell *) getButtonCell:(NSString *)cellIdentifier {
	CGRect CellFrame = CGRectMake(0, 0, iphonescreenwidth, 110);
	CGRect ButtonFrame = CGRectMake(110, 30, 120, 40);

	UITableViewCell	*cell = [[[UITableViewCell alloc] initWithFrame:CellFrame 
														reuseIdentifier:cellIdentifier] autorelease];
	//Make it black
	UIView* backgroundView = [ [ [ UIView alloc ] initWithFrame:CGRectZero ] autorelease ];
	backgroundView.backgroundColor = [ UIColor blackColor ];
	cell.backgroundView = backgroundView;
	
	//UIButton
	UIButton *searchButton = [UIButton buttonWithType:UIButtonTypeRoundedRect];
	
	searchButton.frame = ButtonFrame;

	//Set Background image
	[searchButton setBackgroundImage:[UIImage imageNamed:@"searchnow.png"] forState:UIControlStateNormal];
	
	//listen for clicks
	[searchButton addTarget:self action:@selector(dropTrapButtonPushed) 
	 forControlEvents:UIControlEventTouchUpInside];	
	
	//put button on View
	[cell.contentView addSubview:searchButton];
	return cell;
}
- (void)dropTrapButtonPushed{
	//TrapsAppDelegate *delegate = [[UIApplication sharedApplication] delegate];
//	delegate.BTTabBarCrontroller.selectedIndex = 1;
	NSLog(@"Need to switch views at this point");
}

- (UITableViewCell *) getUserProfileCell:(NSString *)cellIdentifier leftSide:(NSString *)left rightSide:(NSString *)right{
	CGRect CellFrame = CGRectMake(0, 0, iphonescreenwidth, 110);
	UITableViewCell *cell = [[[UITableViewCell alloc] initWithFrame:CellFrame 
													reuseIdentifier:cellIdentifier] autorelease];
	
	//Make it black
	UIView* backgroundView = [ [ [ UIView alloc ] initWithFrame:CGRectZero ] autorelease ];
	backgroundView.backgroundColor = [ UIColor blackColor ];
	cell.backgroundView = backgroundView;
	
	
	//Set up the frames for the individual columns
	CGRect LeftPicFrame = CGRectMake(64, 0, 64, 53);
	CGRect RightPicFrame = CGRectMake(192, 0, 64, 53);
	
	CGRect LeftLabelFrame = CGRectMake(90, 50, 64, 53);
	CGRect RightLabelFrame = CGRectMake(220, 50, 64, 53);

	//Left
	UIImageView *LeftPicTmp;
	LeftPicTmp = [[UIImageView alloc] initWithFrame:LeftPicFrame];
	LeftPicTmp.tag = 3;
	
	UIImage *LeftBarImage = [UIImage imageNamed:[NSString stringWithFormat:@"%@.png", left]];
	[LeftPicTmp setImage:LeftBarImage];
	[cell.contentView addSubview:LeftPicTmp];
	[LeftPicTmp release];
	
	//Set up the actual score
	UILabel *lblTemp;
	lblTemp = [[UILabel alloc] initWithFrame:LeftLabelFrame];
	lblTemp.tag = 1;
	[lblTemp setBackgroundColor:[UIColor clearColor]];
	[lblTemp setText:@"0"];
	[lblTemp setFont:[UIFont fontWithName:@"Helvetica" size:28]];
	[lblTemp setTextColor:[UIColor whiteColor]];
	[cell.contentView addSubview:lblTemp];
	[lblTemp release];
	
	
	//Right
	UIImageView *RightPicTmp;
	RightPicTmp = [[UIImageView alloc] initWithFrame:RightPicFrame];
	RightPicTmp.tag = 4;
	
	UIImage *RightBarImage = [UIImage imageNamed:[NSString stringWithFormat:@"%@.png", right]];
	[RightPicTmp setImage:RightBarImage];
	[cell.contentView addSubview:RightPicTmp];
	[RightPicTmp release];
	
	//Set up the actual score
	lblTemp = [[UILabel alloc] initWithFrame:RightLabelFrame];
	lblTemp.tag = 1;
	[lblTemp setBackgroundColor:[UIColor clearColor]];
	[lblTemp setText:@"0"];
	[lblTemp setFont:[UIFont fontWithName:@"Helvetica" size:28]];
	[lblTemp setTextColor:[UIColor whiteColor]];
	[cell.contentView addSubview:lblTemp];
	[lblTemp release];
	
	return cell;
}
- (UITableViewCell *) getFBUserInfoCell:(NSString *)cellIdentifier{
	//UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier];
	
	CGRect CellFrame = CGRectMake(0, 0, iphonescreenwidth, fbprofileinforowheight);
	UITableViewCell *cell = [[[UITableViewCell alloc] initWithFrame:CellFrame 
													reuseIdentifier:cellIdentifier] autorelease];
	CGRect NameLabelFrame = CGRectMake(90, 20, 290, 25);
	int picTopLeft = (fbprofileinforowheight - 50)/2;
	CGRect ProfilePicFrame = CGRectMake(30, picTopLeft, 50, 50);
	CGRect ProfileBarFrame = CGRectMake(0, 0, iphonescreenwidth, fbprofileinforowheight);
	
	int buttonTopLeft = (fbprofileinforowheight - fblogoutbuttonheight)/2;
	CGRect LogoutButtonFrame = CGRectMake(200, buttonTopLeft, fblogoutbuttonwidth, fblogoutbuttonheight);
	
	UIImageView *ProfileBarTmp;
	ProfileBarTmp = [[UIImageView alloc] initWithFrame:ProfileBarFrame];
	ProfileBarTmp.tag = 3;
	
	UIImage *BarImage = [UIImage imageNamed:@"profilebar.png"];
	[ProfileBarTmp setImage:BarImage];
	[cell.contentView addSubview:ProfileBarTmp];
	
	UILabel *lblTemp;
	lblTemp = [[UILabel alloc] initWithFrame:NameLabelFrame];
	lblTemp.tag = 1;
	[lblTemp setBackgroundColor:[UIColor clearColor]];
	[lblTemp setText:@"Joey Boots"];
	[lblTemp setTextColor:[UIColor whiteColor]];
	[cell.contentView addSubview:lblTemp];
	[lblTemp release];
	
	UIImageView *picTemp;
	picTemp = [[UIImageView alloc] initWithFrame:ProfilePicFrame];
	picTemp.tag = 2;
	
	UIImage *UserImage = [UIImage imageNamed:@"user.png"];
	[picTemp setImage:UserImage];
	[cell.contentView addSubview:picTemp];
	[picTemp release];

	FBLoginButton *button = [[[FBLoginButton alloc] init] autorelease];
	[button setFrame:LogoutButtonFrame];
	[ProfileBarTmp addSubview:button];
	[ProfileBarTmp release];

	return cell;
}

#pragma mark -
#pragma mark BTHomeInternalViewController
- (void)ProfileLoaded:(id)response {
	
	if ([response isKindOfClass:[NSError class]]) {
		NSLog(@"test: response: error!!!: %@", response);		
		return;
	}
	NSString *responseString = [[NSString alloc] initWithData:response encoding:NSUTF8StringEncoding];

	SBJSON *parser = [SBJSON new];
	NSDictionary* responseAsDictionary = [parser objectWithString:responseString error:NULL];
	
	[responseString release];
	[parser release];
	
	NSLog(@"What was returned was %@", responseAsDictionary);
}

@end

