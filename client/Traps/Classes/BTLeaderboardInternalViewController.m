//
//  BTLeaderboardInternalViewController.m
//  Traps
//
//  Created by Roderic Campbell on 3/14/10.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import "BTLeaderboardInternalViewController.h"
#import <JSON/JSON.h>
#import "BTNetwork.h"

@implementation BTLeaderboardInternalViewController

@synthesize friendsWithApp;
#pragma mark -
#pragma mark Initialization

- (id)init {
    if ((self = [super initWithStyle:UITableViewStylePlain]) == nil) {
		return nil;
    }
	
	//self.title = kLeaderboardTitle;
	
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
	
	session = [[FBSession sessionForApplication:@"3243a6e2dd3a0d084480d05f301cba85"
															  secret:@"d8611553a286dce3531353b3de53ef2e" 
															delegate:self] retain];
}
- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
	
	//XXX: add code here
}
- (void)viewDidAppear:(BOOL)animated {
	[super viewDidAppear:animated];
	[session resume];
}
- (void)viewDidDisappear:(BOOL)animated {
	[self.friendsWithApp release];
	[super viewDidDisappear:animated];
	
	//XXX: add code here
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

#pragma mark -
#pragma mark Network Requests
- (void)didGetFriends:(id)response{
	NSString *responseString = [[NSString alloc] initWithData:response encoding:NSUTF8StringEncoding];
	
	SBJSON *parser = [SBJSON new];
	NSDictionary* webRequestResults = [parser objectWithString:responseString error:NULL];
	
	//self.friendsWithApp = [NSDictionary alloc];
	self.friendsWithApp = [webRequestResults copy];

	self.navigationItem.rightBarButtonItem = nil;
	[self loadView];
}

- (void)session:(FBSession *)localSession didLogin:(FBUID)uid{
	NSString *fql = [NSString stringWithFormat:
					 @"select uid, first_name, last_name, name, pic_square from user where uid in (select uid from user where is_app_user = 1 and uid in (SELECT uid2 FROM friend WHERE uid1= %lld))", 
					 [localSession uid]];
	NSDictionary *params = [NSDictionary dictionaryWithObject:fql forKey:@"query"];
	[[FBRequest requestWithDelegate:self] call:@"facebook.fql.query" params:params];

}

- (void) request:(FBRequest *)request didLoad:(id)result {
	NSArray *users = result;
	NSArray *friendsWithAppArray = [[NSArray alloc] initWithArray:users];
	[self loadView];
	
	SBJsonWriter *writer = [[[SBJsonWriter alloc] init] autorelease];
	NSString *friendListString = [writer stringWithObject:friendsWithAppArray];
	
	[friendsWithAppArray release];
	//NSLog(@"friendList %@ %@", friendListString, [friendListString class]);
	//Now send this list over to the server and get their rankings
	
	[[BTNetwork sharedNetwork] performHttpOperationWithResponseObject:self
													  methodSignature:NSStringFromSelector(@selector(didGetFriends:))
															   method:@"GET"
															   domain:kHTTPHost
														  relativeURL:@"GetFriends"
															   params:[NSDictionary dictionaryWithObjectsAndKeys:
																	   friendListString, @"friends",
																	   nil]];

}
	



#pragma mark -
#pragma mark UITableView

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
	[tableView setSeparatorColor:[UIColor blackColor]];
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
	if (friendsWithApp == nil) {
		return 0;
	}

	return [friendsWithApp count];

}

-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
	return (iphonescreenheight - (navbarheight*2) - fbprofileinforowheight)/4;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
	NSString *reuseId = [NSString stringWithFormat:@"home%d", [indexPath row]];
	UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:reuseId];
	NSLog(@"cell for row at %d", [indexPath row]);
	if(cell == nil){
		cell = [self getFriendCell:reuseId friend:[friendsWithApp objectAtIndex:[indexPath row]]];
	}
	
    return cell;
}

- (void) gotFriendImage:(id)data{
	NSLog(@"data %@", data);
}
							
#pragma mark -
#pragma mark Cell Description
- (UITableViewCell *) getFriendCell:(NSString *)cellIdentifier friend:(NSDictionary *)friend{
	//name
	NSString *lastName = [friend objectForKey:@"last_name"];
	NSString *firstName = [friend objectForKey:@"first_name"];
	NSString *killCount = [NSString stringWithFormat:@"Kills: %@", [friend objectForKey:@"killCount"]];

	//TODO This needs to use CoreData or some type of local storage.
	UIImage *userImage;
	userImage = [UIImage imageNamed:@"user.png"];
	

	//nil;// = [UIImage imageNamed:@"user.png"];

	UIColor *textColor = [UIColor whiteColor];

	if([friend objectForKey:@"is_self"]){
		textColor = [UIColor blueColor];
	}
	
	if(lastName == nil){
		lastName = @"_";
	}
	if(firstName == nil){
		firstName =@"_";
	}
	
		
	
	
	
	if(![friend objectForKey:@"imagedata"]){
		NSLog(@"there is no image data for %@", lastName);
	}
	
	NSLog(@"getting the friend Cell %@", lastName);
	CGRect CellFrame = CGRectMake(0, 0, iphonescreenwidth, fbprofileinforowheight);
	UITableViewCell *cell = [[[UITableViewCell alloc] initWithFrame:CellFrame 
													reuseIdentifier:cellIdentifier] autorelease];
	
	CGRect FirstNameLabelFrame = CGRectMake(90, 15, 120, 25);
	CGRect LastNameLabelFrame = CGRectMake(90, 35, 120, 25);
	int picTopLeft = (fbprofileinforowheight - 50)/2;
	CGRect ProfilePicFrame = CGRectMake(30, picTopLeft, 50, 50);
	CGRect ProfileBarFrame = CGRectMake(0, 0, iphonescreenwidth, fbprofileinforowheight);
	CGRect KillsLabelFrame = CGRectMake(200, 15, 120, 25);
	//CGRect TrapsSetLabelFrame = CGRectMake(160, fbprofileinforowheight-15, 120, 25);
//	CGRect KillsLabelFrame = CGRectMake(200, 15, 120, 25);

	
	
	UIImageView *ProfileBarTmp;
	ProfileBarTmp = [[UIImageView alloc] initWithFrame:ProfileBarFrame];
	ProfileBarTmp.tag = 3;
	
	UIImage *BarImage = [UIImage imageNamed:@"profilebar.png"];
	[ProfileBarTmp setImage:BarImage];
	[cell.contentView addSubview:ProfileBarTmp];
	[ProfileBarTmp release];

	UILabel *lblTemp;
	lblTemp = [[UILabel alloc] initWithFrame:FirstNameLabelFrame];
	lblTemp.tag = 1;

	[lblTemp setBackgroundColor:[UIColor clearColor]];
	[lblTemp setText:firstName];
	[lblTemp setTextColor:textColor];
	[cell.contentView addSubview:lblTemp];
	[lblTemp release];
	
	lblTemp = [[UILabel alloc] initWithFrame:LastNameLabelFrame];
	lblTemp.tag = 2;
	[lblTemp setBackgroundColor:[UIColor clearColor]];
	[lblTemp setText:lastName];
	[lblTemp setTextColor:textColor];
	[cell.contentView addSubview:lblTemp];
	[lblTemp release];
	
	lblTemp = [[UILabel alloc] initWithFrame:KillsLabelFrame];
	lblTemp.tag = 4;
	[lblTemp setBackgroundColor:[UIColor clearColor]];
	[lblTemp setText:killCount];
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
	
	
	return cell;
	
}

@end
