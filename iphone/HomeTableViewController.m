//
//  HomeTableViewController.m
//  BoobyTrap3
//
//  Created by Roderic Campbell on 10/11/09.
//  Copyright 2009 Slide. All rights reserved.
//

#import "HomeTableViewController.h"
#import "ProfileViewController.h"
#import "BoobyTrap3AppDelegate.h"
#import "UserProfile.h"
#import "NetworkRequestOperation.h"
#import "FBConnect/FBConnect.h"


@implementation HomeTableViewController
@synthesize menuArray;
@synthesize profileViewController;
@synthesize userName;
@synthesize userLevel;
@synthesize userCoinCount;
@synthesize userImage;

#pragma mark Initialization and setup
-(void)updateMiniProfile:(NSDictionary *)profile{
	NSLog(@"updating mini profile");
	
	[userName setText:[profile objectForKey:@"username"]];
	[userLevel setText:[profile objectForKey:@"level"]];
	[userCoinCount setText:[profile objectForKey:@"coinCount"]];
}

- (void)viewDidLoad {
    [super viewDidLoad];
	NSLog(@"showing home tableview");
	
	self.title = NSLocalizedString(@"Home", @"Home Title");	
	NSMutableArray *array = [[NSArray alloc] initWithObjects:@"Profile", @"Wall",@"Drop History", @"Inbox",@"Leaderboard",@"Store", nil];
	self.menuArray = array;
	[array release];
	
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
	[self updateMiniProfile:[[UserProfile sharedSingleton] profile]];
	
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

-(void)session:(FBSession *)session willLogout:uid{
	NSLog(@"will log out");
	BoobyTrap3AppDelegate *delegate = [[UIApplication sharedApplication] delegate];

	NetworkRequestOperation *op = [[NetworkRequestOperation alloc] init];
	op.targetURL =[NSString stringWithFormat:@"%s%s", [delegate serverAddress], @"/Logout/"];
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
	NSLog(fql);
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
	op.callingDelegate = self;
	queue = [[NSOperationQueue alloc] init];
	[queue addOperation:op];
	[op release];
	
	//Set the mini profile image
	NSURL *photoUrl = [NSURL URLWithString:[user objectForKey:@"pic_square"]];
	NSLog([user objectForKey:@"pic_square"]);
	NSData *photoData = [NSData dataWithContentsOfURL:photoUrl];
	UIImage *profileImage =	[UIImage imageWithData:photoData];
	userImage.image = profileImage;
	
	//Set the mini porofile name
	userName.text = [user objectForKey:@"name"];
	
	//[self loadView];
}

- (void)pageLoaded:(NSDictionary*)webRequestResults{
	NSLog(@"webrequest returned %@", webRequestResults);
	UserProfile *userProfile = [UserProfile sharedSingleton];
	[userProfile newProfileFromDictionary:webRequestResults];
}

#pragma mark Table view methods

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

// Customize the number of rows in the table view.
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return [menuArray count];
}

// Customize the appearance of table view cells.
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    static NSString *CellIdentifier = @"Cell";
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
        cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier] autorelease];
    }
    
    // Set up the cell...
	NSUInteger row = [indexPath row];
	cell.text = [menuArray objectAtIndex:row];	
    return cell;
}


- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
	
	NSInteger row = [indexPath row];
	if (row == 0 ){
		if (self.profileViewController == nil){
			ProfileViewController *aProfileViewController = [[ProfileViewController alloc] initWithNibName:@"ProfileView" bundle:nil];
			self.profileViewController = aProfileViewController;
			[aProfileViewController release];
		}
		profileViewController.title = @"TheUserName";
		
		BoobyTrap3AppDelegate *delegate = [[UIApplication sharedApplication] delegate];
		[delegate.homeNavController pushViewController:profileViewController animated:YES];
		
	}
	if (row == 1){
		NSLog(@" row is 1");
	}
	
}
@end

