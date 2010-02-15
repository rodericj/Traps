//
//  SocialTableViewController.m
//  BoobyTrap3
//
//  Created by Roderic Campbell on 11/21/09.
//  Copyright 2009 __MyCompanyName__. All rights reserved.
//

#import "SocialTableViewController.h"
#import "FBConnect/FBConnect.h"
#import "CompositeSubviewBasedApplicationCell.h"
#import "NetworkRequestOperation.h"
#import "SBJSON.H"
@implementation SocialTableViewController
@synthesize friendsWithApp;
//@synthesize session;
- (void)viewDidLoad {
    [super viewDidLoad];
  }

- (void) request:(FBRequest *)request didLoad:(id)result {
	NSArray *users = result;
	self.friendsWithApp = [[NSArray alloc] initWithArray:users];
	[self loadView];
	
	SBJsonWriter *writer = [SBJsonWriter new];
	NSString *friendListString = [writer stringWithObject:self.friendsWithApp];
	//NSString *friendList = [[[SBJSON alloc] init] stringWithObject:self.friendsWithApp];
	NSLog(@"friendList %@", friendListString);
	//Now send this list over to the server and get their rankings
	NetworkRequestOperation *op = [[NetworkRequestOperation alloc] init];
	[op setTargetURL:@"GetFriends"];
	op.arguments = [[[NSMutableDictionary alloc] init] autorelease];
	[op.arguments setObject:friendListString forKey:@"friends"];
	op.callingDelegate = self;
	queue = [[[NSOperationQueue alloc] init] autorelease];
	[queue addOperation:op];
	[op release];
}

- (void)pageLoaded:(NSArray*)webRequestResults{
	NSLog(@"results of friend stuff: %@", webRequestResults);
	self.friendsWithApp = webRequestResults;
	[self loadView];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
	
	session = [[FBSession sessionForApplication:@"3243a6e2dd3a0d084480d05f301cba85"
 													secret:@"d8611553a286dce3531353b3de53ef2e" 
 												  delegate:self] retain];
}

- (void)viewDidAppear:(BOOL)animated {
	[super viewDidAppear:animated];
	[session resume];
}

- (void)session:(FBSession *)localSession didLogin:(FBUID)uid{
	NSLog(@"did log in from facebook in socialtablview");
	NSString *fql = [NSString stringWithFormat:
					 @"select uid, first_name, last_name, name, pic_square from user where uid in (select uid from user where is_app_user = 1 and uid in (SELECT uid2 FROM friend WHERE uid1= %lld))", 
					 [localSession uid]];
	NSDictionary *params = [NSDictionary dictionaryWithObject:fql forKey:@"query"];
	[[FBRequest requestWithDelegate:self] call:@"facebook.fql.query" params:params];
	
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

-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
	return 60;
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

// Customize the number of rows in the table view.
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return [self.friendsWithApp count];
}

// Customize the appearance of table view cells.
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    static NSString *CellIdentifier = @"Cell";
    
   // UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
	ApplicationCell *cell = (ApplicationCell *)[tableView dequeueReusableCellWithIdentifier:CellIdentifier];

	if(cell == nil)
        cell = [[[CompositeSubviewBasedApplicationCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"ApplicationCell"] autorelease];

	//First get the dictionary object
	NSDictionary *friend = [friendsWithApp objectAtIndex:indexPath.row];
	NSString *friendName = [friend objectForKey:@"name"];
	NSString *killCount = [friend objectForKey:@"killCount"];
	NSLog(@"kill count: %@", killCount);
	NSURL *photoUrl = [NSURL URLWithString:[friend objectForKey:@"pic_square"]];
	NSData *photoData = [NSData dataWithContentsOfURL:photoUrl];
	UIImage *profileImage =	[UIImage imageWithData:photoData];
	cell.icon = profileImage;
	
	cell.name = friendName;
	cell.killCount = [NSString stringWithFormat:@"%@", killCount];
	[friendName release];
	[killCount release];
	
	return cell;
}
	
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    // Navigation logic may go here. Create and push another view controller.
	// AnotherViewController *anotherViewController = [[AnotherViewController alloc] initWithNibName:@"AnotherView" bundle:nil];
	// [self.navigationController pushViewController:anotherViewController];
	// [anotherViewController release];
}


- (void)dealloc {
    [super dealloc];
}

@end

