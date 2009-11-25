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

@implementation SocialTableViewController
@synthesize friendsWithApp;

- (void)viewDidLoad {
    [super viewDidLoad];
  }

- (void) request:(FBRequest *)request didLoad:(id)result {
	NSArray *users = result;
	self.friendsWithApp = [[NSArray alloc] initWithArray:users];
	[self loadView];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
	FBSession *session = [[FBSession sessionForApplication:@"3243a6e2dd3a0d084480d05f301cba85"
 													secret:@"d8611553a286dce3531353b3de53ef2e" 
 												  delegate:self] retain];
	if([session resume] == NO){
		NSLog(@"viewwillappear for socialtableview. resume returned no");
		}
	else{
		NSLog(@"viewwillappear for socialtableview. resume returned yes");
	}
	
	//Do fb query
	NSString *fql = [NSString stringWithFormat:
					 @"select uid, first_name, last_name, name, pic_square from user where uid in (select uid from user where is_app_user = 1 and uid in (SELECT uid2 FROM friend WHERE uid1= %lld))", 
					 [session uid]];
	NSDictionary *params = [NSDictionary dictionaryWithObject:fql forKey:@"query"];
	[[FBRequest requestWithDelegate:self] call:@"facebook.fql.query" params:params];
	
}

- (void)session:(FBSession *)session didLogin:(FBUID)uid{
	NSLog(@"did log in from facebook in socialtablview");
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
	NSURL *photoUrl = [NSURL URLWithString:[friend objectForKey:@"pic_square"]];
	NSData *photoData = [NSData dataWithContentsOfURL:photoUrl];
	UIImage *profileImage =	[UIImage imageWithData:photoData];
	cell.icon = profileImage;
	
	cell.name = friendName;
	[friendName release];
	
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

