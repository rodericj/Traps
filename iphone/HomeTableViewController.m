//
//  HomeTableViewController.m
//  BoobyTrap3
//
//  Created by Roderic Campbell on 10/11/09.
//  Copyright 2009 Slide. All rights reserved.
//

#import "HomeTableViewController.h"
#import "ProfileViewController.h"
#import "DropTrapsNavController.h"
//#import "NearbyPlacesTableView.h"
#import "BoobyTrap3AppDelegate.h"
#import "UserProfile.h"
#import "NetworkRequestOperation.h"
#import "FBConnect/FBConnect.h"
#import "Airship.h"

@implementation HomeTableViewController
@synthesize menuArray;
@synthesize profileViewController;
@synthesize userName;
@synthesize userLevel;
@synthesize userCoinCount;
@synthesize userImage;
@synthesize userTrapsSet;
@synthesize userKillCount;
@synthesize userHitPoints;
@synthesize dropTrapsNavController;

#pragma mark Initialization and setup
- (IBAction)dropTrapButtonPushed{
	BoobyTrap3AppDelegate *delegate = [[UIApplication sharedApplication] delegate];
	delegate.rootController.selectedIndex = 1;
}
-(void)updateMiniProfile:(UserProfile *)profile{
	NSLog(@"updating mini profile here %@", profile);
	[userName setText:[profile getUserName]];
	NSLog(@"updated username");
	
	NSString *level = [NSString stringWithFormat:@"%@", [profile getLevel]];
	NSString *coinCount = [NSString stringWithFormat:@"%@", [profile getCoinCount]];
	NSString *trapsSet = [NSString stringWithFormat:@"%@", [profile getTrapsSetCount]];
	NSString *killCount = [NSString stringWithFormat:@"%@", [profile getKillCount]];
	NSString *hitPoints = [NSString stringWithFormat:@"%@", [profile getHitPoints]];
	
	[userLevel setText:level];
	[userCoinCount setText:coinCount];
	[userTrapsSet setText:trapsSet];
	[userKillCount setText:killCount];
	[userHitPoints setText:hitPoints];
	
	//TODO
	//may not actually need this if i can just set the text above from the [profile xxxx]
//	[level release];
//	[coinCount release];
//	[trapsSet release];
//	[killCount release];
//	[hitPoints release];
	
	//[self reloadData];
	//NSArray *allKeys = [inventory allKeys];
	//NSLog(@"first one is: %@", [inventory objectForKey:<#(id)aKey#>);
}

- (void)viewDidLoad {
    [super viewDidLoad];
	NSLog(@"showing home tableview");
	
	self.title = NSLocalizedString(@"Home", @"Home Title");	
//	NSMutableArray *array = [[NSArray alloc] initWithObjects:@"Profile", @"Wall",@"Drop History", @"Inbox",@"Leaderboard",@"Store", nil];
	//NSMutableArray *array = [[NSArray alloc] initWithObjects:@"Drop Traps", @"Inventory", @"Social", @"Store", nil];
	
	//NSDictionary *inventory = [NSDictionary alloc];
	//UserProfile *userProfile = [UserProfile sharedSingleton];

	//NSLog(@"profile returned is: %@", userProfile);
	//inventory = [userProfile getInventory];
	//NSLog(@"inventory %@", inventory);
	//NSDictionary *keys = [inventory allKeys];
	//self.menuArray = keys;
	//[keys release];
	//self.menuArray = array;
	//[inventory release];
	
	mySession = [[FBSession sessionForApplication:@"3243a6e2dd3a0d084480d05f301cba85"
								secret:@"d8611553a286dce3531353b3de53ef2e"
								delegate:self] retain];

	hasAppeared = FALSE;
}

- (void)viewDidAppear:(BOOL)animated {
	[super viewDidAppear:animated];
	if(!hasAppeared){
		if([mySession resume] == YES){
			NSLog(@"session resumed");
		}
		else{
			NSLog(@"should show dialog?");
			FBDialog *dialog = [[[FBLoginDialog alloc] initWithSession:mySession] autorelease];
			dialog.delegate = self;
			[dialog show];
		}
		hasAppeared = TRUE;
	}
}

- (void)viewWillAppear:(BOOL)animated {
	NSLog(@"viewWillAppear in home table view controller");
	//[self updateMiniProfile:[NSDictionary dictionaryWithContentsOfFile:@"Profile.p list"]];
	UserProfile *userProfile = [UserProfile sharedSingleton];
	NSLog(@"in updateMiniProfile viewWillAppear");
	[self updateMiniProfile:userProfile];
	NSLog(@"out of updateMiniProfile viewWillAppear");
	FBLoginButton *button = [[[FBLoginButton alloc] init] autorelease];
	[self.view addSubview:button];
	[super viewWillAppear:animated];
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

- (void)dealloc {
	[profileViewController release];
	[mySession.delegates removeObject: self];
    [super dealloc];
}


#pragma mark FB Connect stuff

-(void)session:(FBSession *)session willLogout:(FBUID)uid{
	//Clear profile
	NSMutableDictionary *emptyProfile = [[NSMutableDictionary alloc] init];
	[emptyProfile setObject:@"" forKey:@"userName"];
	[emptyProfile setObject:@"" forKey:@"coinCount"];
	[emptyProfile setObject:@"" forKey:@"level"];
	UserProfile *userProfile = [UserProfile sharedSingleton];
	[userProfile newProfileFromDictionary:emptyProfile];
	[emptyProfile release];
	NSLog(@"%@", [userProfile getUserName]);
	//NSLog(@"update with this username %@", [userProfile obje)
	NSLog(@"in updateMiniProfile pageLoaded");
	[self updateMiniProfile:userProfile];
	
	NetworkRequestOperation *op = [[NetworkRequestOperation alloc] init];
	op.targetURL = @"Logout";
	op.callingDelegate = self;
	
	queue = [[NSOperationQueue alloc] init];
	[queue addOperation:op];
	[op release];
	
	FBDialog *dialog = [[[FBLoginDialog alloc] initWithSession:session] autorelease];
	dialog.delegate = self;
	[dialog show];
	hasAppeared = FALSE;
}

- (void)session:(FBSession *)session didLogin:(FBUID)uid{
	
	NSLog(@"did log in from facebook here and the session is %@ %d", 
		  [session description], uid);
	//Do fb query
	NSString *fql = [NSString stringWithFormat:
					 @"select uid, first_name, last_name, name, pic_square from user where uid= %lld", 
					 [session uid]];
	NSDictionary *params = [NSDictionary dictionaryWithObject:fql forKey:@"query"];
	[[FBRequest requestWithDelegate:self] call:@"facebook.fql.query" params:params];
}

- (void) request:(FBRequest *)request didLoad:(id)result {
	NSLog(@"Request has returned %@", request);
	NSArray *users = result;
	NSLog(@"users returned is %@", users);
	NSDictionary *user = [users objectAtIndex:0];
	
	UserProfile *sharedSingleton = [UserProfile sharedSingleton];
	[sharedSingleton newFBProfileFromDictionary:user];
	
	NetworkRequestOperation *op = [[NetworkRequestOperation alloc] init];
	[op setTargetURL:@"IPhoneLogin"];
	op.arguments = [[NSMutableDictionary alloc] init];
	[op.arguments setObject:[user objectForKey:@"uid"] forKey:@"uname"];
	[op.arguments setObject:(NSString *)[user objectForKey:@"uid"] forKey:@"password"];
	[op.arguments setObject:(NSString *)[user objectForKey:@"last_name"] forKey:@"last_name"];
	[op.arguments setObject:(NSString *)[user objectForKey:@"first_name"] forKey:@"first_name"];
	[op.arguments setObject:(NSString *)@"1" forKey:@"tutorial"];

	op.callingDelegate = self;
	queue = [[NSOperationQueue alloc] init];
	[queue addOperation:op];
	[op release];
	
	//Set the mini profile image
	NSURL *photoUrl = [NSURL URLWithString:[user objectForKey:@"pic_square"]];
	NSData *photoData = [NSData dataWithContentsOfURL:photoUrl];
	UIImage *profileImage =	[UIImage imageWithData:photoData];
	userImage.image = profileImage;
	
	//Set the mini porofile name
	userName.text = [user objectForKey:@"name"];
}

- (void)pageLoaded:(NSDictionary*)webRequestResults{
	UserProfile *userProfile = [UserProfile sharedSingleton];
	[userProfile newProfileFromDictionary:webRequestResults];
	[self updateMiniProfile:userProfile];
	[homeTableView reloadData];
	
	NSNumber *tutorialValue = (NSNumber *)[webRequestResults objectForKey:@"tutorialValue"];

	if([tutorialValue intValue] == 1){
		NSLog(@"looking in tutorial 1 %@", webRequestResults);
		[userProfile setTutorial:2];
		NSLog(@"tutorial after setting: %d", [userProfile getTutorial]);
		UIAlertView *alert;
		NSString *tutorialText = [webRequestResults objectForKey:@"tutorialText"];
		alert = [[UIAlertView alloc] initWithTitle:@"Tutorial" 
										   message:tutorialText
										  delegate:self 
								 cancelButtonTitle:@"Ok" 
								 otherButtonTitles:nil];
		[alert show]; 
		[alert release]; 
	}
}

#pragma mark Table view methods

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

// Customize the number of rows in the table view.
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
	UserProfile *profile = [UserProfile sharedSingleton];
	NSArray *inventory = (NSArray *)[profile getInventory];
	return [inventory count];
}

// Customize the appearance of table view cells.
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    NSLog(@"in cellforrowatindexpath for home view for each row. should print the inventory");
    static NSString *CellIdentifier = @"Cell";
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
        cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier] autorelease];
    }
    UserProfile *profile = [UserProfile sharedSingleton];
	NSArray *inventory = (NSArray *)[profile getInventory];
    // Set up the cell...
	NSString *cellText = [NSString stringWithFormat:@"%@ %@",  [[inventory objectAtIndex:[indexPath row]] objectForKey:@"name"], [[inventory objectAtIndex:[indexPath row]] objectForKey:@"count"]];
	NSLog(@"celltext %@", cellText);
	[cell.textLabel setText:cellText];
    return cell;
}

-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
	return 30;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
	
	//NSInteger row = [indexPath row];
//	if (row == 0 ){
//		if (self.profileViewController == nil){
//			ProfileViewController *aProfileViewController = [[ProfileViewController alloc] initWithNibName:@"ProfileView" bundle:nil];
//			self.profileViewController = aProfileViewController;
//			[aProfileViewController release];
//		}
//		profileViewController.title = @"TheUserName";
//		
//		BoobyTrap3AppDelegate *delegate = [[UIApplication sharedApplication] delegate];
//		[delegate.homeNavController pushViewController:profileViewController animated:YES];
//		
//	}
	//NSMutableArray *array = [[NSArray alloc] initWithObjects:@"Drop Traps", @"Inventory", @"Social", @"Store", nil];

	//if (row == 3){
//		[Airship takeOff: @"EK_BtrOrSOmo95TTsAb_Fw" identifiedBy: @"vAixh-KLT5u0Ay8Xv6cf4Q"];
//		[[Airship shared] displayStoreFront];
//	}
}
@end

