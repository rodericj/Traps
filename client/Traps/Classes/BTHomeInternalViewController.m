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
#import "BTUserProfile.h"
#import "BTConstants.h"

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
}

- (void)dialogDidCancel:(FBDialog *)dialog{
	NSLog(@"we  cancelled. show the cancel flow");
	FBDialog *newdialog = [[[FBLoginDialog alloc] initWithSession:mySession] autorelease];
	newdialog.delegate = self;
	[newdialog show];
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
	NSLog(@"the user returned was %@", user);
	
	BTUserProfile *profile = [BTUserProfile sharedBTUserProfile];
	[profile setLastName:(NSString *)[user objectForKey:@"last_name"]];
	[profile setFirstName:(NSString *)[user objectForKey:@"first_name"]];
	
	//This doesn't seem like the best way to do this, but what is returned from 
	//   fb is a NSNull object. So I'm comparing it's class type to an NSNull's class type
	if(![[user objectForKey:@"pic_square"] isKindOfClass:[NSNull class]] ){
		NSURL *photoUrl = [NSURL URLWithString:[user objectForKey:@"pic_square"]];
		//TODO Very bad, need to thread this. The issue is that it's not going to khttphost
		NSData *photoData = [NSData dataWithContentsOfURL:photoUrl];
		UIImage *profileImage =	[UIImage imageWithData:photoData];
		[profile setUserImage:profileImage];
	}
	
	[self loadView];

	[[BTNetwork sharedNetwork] performHttpOperationWithResponseObject:self
								methodSignature:NSStringFromSelector(@selector(ProfileLoaded:))
								method:@"POST"
								domain:kHTTPHost
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

-(void)viewDidAppear:(BOOL)animated{
	if([mySession resume] == YES){
		NSLog(@"session resumed");
	}
	else{
		NSLog(@"should show fb dialog?");
		FBDialog *dialog = [[[FBLoginDialog alloc] initWithSession:mySession] autorelease];
		dialog.delegate = self;
		[dialog show];
	}
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
	if ([indexPath row] == 1 || [indexPath row] == 2) {
		return profilestatusheight;
	}

	return iphonescreenheight - navbarheight - iphonetabbarheight - fbprofileinforowheight -(profilestatusheight*2);
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
	NSString *CellIdentifier = [NSString stringWithFormat:@"home%d", row];
	[cell setText:[NSString stringWithFormat:@"%d", row]];

	if (cell == nil){
		switch (row) {
			case 0:
				cell = [self getFBUserInfoCell:CellIdentifier];
				break;
			case 1:
				cell = [self getUserProfileCell:CellIdentifier leftSide:@"trapsSetCount" rightSide:@"coinCount"];
				break;
			case 2:
				cell = [self getUserProfileCell:CellIdentifier leftSide:@"hitPoints" rightSide:@"killCount"];
				break;
			case 3:
				cell = [self getButtonCell:CellIdentifier];
				break;
			default:
				cell = [[[UITableViewCell alloc] initWithFrame:CGRectZero reuseIdentifier:@"HomeCell"] autorelease];
				break;
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
	BTUserProfile *profile = [BTUserProfile sharedBTUserProfile];
	
	CGRect CellFrame = CGRectMake(0, 0, iphonescreenwidth, 110);
	UITableViewCell *cell = [[[UITableViewCell alloc] initWithFrame:CellFrame 
													reuseIdentifier:cellIdentifier] autorelease];
	NSString *leftText;
	NSString *rightText;
	
	if(right == @"coinCount"){
		rightText = [NSString stringWithFormat:@"%d", [profile coinCount]];
	}	

	if(right == @"killCount"){
		rightText = [NSString stringWithFormat:@"%d", [profile damageCaused]];
	}		

	if(right == @"trapsSetCount"){
		rightText = [NSString stringWithFormat:@"%d", [profile numTrapsSet]];
	}		

	if(right == @"hitPoints"){
		rightText = [NSString stringWithFormat:@"%d", [profile hitPoints]];
	}	

	if(left == @"coinCount"){
		leftText = [NSString stringWithFormat:@"%d", [profile coinCount]];
	}		

	if(left == @"killCount"){
		leftText = [NSString stringWithFormat:@"%d", [profile damageCaused]];
	}		

	if(left == @"trapsSetCount"){
		leftText = [NSString stringWithFormat:@"%d", [profile numTrapsSet]];
	}		

	if(left == @"hitPoints"){
		leftText = [NSString stringWithFormat:@"%d", [profile hitPoints]];
	}	

	//Make it black
	UIView* backgroundView = [[[UIView alloc]initWithFrame:CGRectZero] autorelease];
	backgroundView.backgroundColor = [ UIColor blackColor ];
	cell.backgroundView = backgroundView;
	
	//Set up the frames for the individual columns
	CGRect LeftPicFrame = CGRectMake(0, 0, 160, 110);
	CGRect RightPicFrame = CGRectMake(160, 0, 160, 110);
	
	CGRect LeftLabelFrame = CGRectMake(100, 15, 64, 53);
	CGRect RightLabelFrame = CGRectMake(260, 15, 64, 53);

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
	
	//NSLog(@"left %@", [kvPair objectForKey:left] );
	//if([kvPair objectForKey:left]!=nil){
//		//NSLog(@"went in %@", [kvPair objectForKey:left] );
//		
	[lblTemp setText:leftText];
//	}
	//NSLog(@"got past left %@", [kvPair objectForKey:left] );

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
	
	[lblTemp setText:leftText];
	
	[lblTemp setFont:[UIFont fontWithName:@"Helvetica" size:28]];
	[lblTemp setTextColor:[UIColor whiteColor]];
	[cell.contentView addSubview:lblTemp];
	[lblTemp release];
	
	return cell;
}
- (UITableViewCell *) getFBUserInfoCell:(NSString *)cellIdentifier{

	//Get the user's profile
	BTUserProfile *profile = [BTUserProfile sharedBTUserProfile];
	
	//name
	NSString *lastName = [profile lastName];
	NSString *firstName = [profile firstName];
	UIImage *userImage = [profile userImage];
	
	if(lastName == nil){
		lastName = @"_";
	}
	if(firstName == nil){
		firstName =@"_";
	}
	if(userImage == nil){
		userImage = [UIImage imageNamed:@"user.png"];
	}
	
	
	int buttonTopLeft = (fbprofileinforowheight - fblogoutbuttonheight)/2;
	CGRect CellFrame = CGRectMake(0, 0, iphonescreenwidth, fbprofileinforowheight);
	UITableViewCell *cell = [[[UITableViewCell alloc] initWithFrame:CellFrame 
													reuseIdentifier:cellIdentifier] autorelease];
	CGRect FirstNameLabelFrame = CGRectMake(90, 15, 120, 25);
	CGRect LastNameLabelFrame = CGRectMake(90, 35, 120, 25);
	int picTopLeft = (fbprofileinforowheight - 50)/2;
	CGRect ProfilePicFrame = CGRectMake(30, picTopLeft, 50, 50);
	CGRect ProfileBarFrame = CGRectMake(0, 0, iphonescreenwidth, fbprofileinforowheight);
	
	//int buttonTopLeft = (fbprofileinforowheight - fblogoutbuttonheight)/2;
	CGRect LogoutButtonFrame = CGRectMake(200, buttonTopLeft, fblogoutbuttonwidth, fblogoutbuttonheight);
	
	UIImageView *ProfileBarTmp;
	ProfileBarTmp = [[UIImageView alloc] initWithFrame:ProfileBarFrame];
	ProfileBarTmp.tag = 3;
	
	UIImage *BarImage = [UIImage imageNamed:@"profilebar.png"];
	[ProfileBarTmp setImage:BarImage];
	[cell.contentView addSubview:ProfileBarTmp];
	
	UILabel *lblTemp;
	lblTemp = [[UILabel alloc] initWithFrame:FirstNameLabelFrame];
	lblTemp.tag = 1;
	[lblTemp setBackgroundColor:[UIColor clearColor]];
	[lblTemp setText:firstName];
	[lblTemp setTextColor:[UIColor whiteColor]];
	[cell.contentView addSubview:lblTemp];
	[lblTemp release];

	lblTemp = [[UILabel alloc] initWithFrame:LastNameLabelFrame];
	lblTemp.tag = 2;
	[lblTemp setBackgroundColor:[UIColor clearColor]];
	[lblTemp setText:lastName];
	[lblTemp setTextColor:[UIColor whiteColor]];
	[cell.contentView addSubview:lblTemp];
	
	[lblTemp release];
	
	UIImageView *picTemp;
	picTemp = [[UIImageView alloc] initWithFrame:ProfilePicFrame];
	picTemp.tag = 3;
	
	//UIImage *UserImage = [UIImage imageNamed:@"user.png"];
	[picTemp setImage:userImage];
	[cell.contentView addSubview:picTemp];
	[picTemp release];

	FBLoginButton *button = [[[FBLoginButton alloc] init] autorelease];
	[button setFrame:LogoutButtonFrame];
	[cell.contentView addSubview:button];
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
	
	BTUserProfile *profile = [BTUserProfile sharedBTUserProfile];
	 [profile setCoinCount:[[responseAsDictionary objectForKey:@"coinCount"] intValue]];
	[profile setHitPoints:[[responseAsDictionary objectForKey:@"hitPoints"] intValue]];
	[profile setDamageCaused:[[responseAsDictionary objectForKey:@"killCount"] intValue]];
	[profile setNumTrapsSet:[[responseAsDictionary objectForKey:@"trapsSetCount"] intValue]];

	[responseString release];
	[parser release];
	
	[self loadView];
}


-(void)session:(FBSession *)session willLogout:(FBUID)uid{
	//Clear profile
	//update image and name on cell
	//call logout
	
	[[BTNetwork sharedNetwork] performHttpOperationWithResponseObject:self
													  methodSignature:NSStringFromSelector(@selector(ProfileLoaded:))
															   method:@"POST"
															   domain:kHTTPHost
														  relativeURL:@"Logout/"
															   params:nil];
	
		
	FBDialog *dialog = [[[FBLoginDialog alloc] initWithSession:session] autorelease];
	dialog.delegate = self;
	[dialog show];
}

@end

