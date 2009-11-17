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

@implementation HomeTableViewController
@synthesize menuArray;
@synthesize profileViewController;
@synthesize userName;
@synthesize userLevel;
@synthesize userCoinCount;

#pragma mark initialization and setup
-(void)updateMiniProfile:(NSDictionary *)profile{
	NSLog(@"updating mini profile");
	
	[userName setText:[profile objectForKey:@"username"]];
	[userLevel setText:[profile objectForKey:@"level"]];
	[userCoinCount setText:[profile objectForKey:@"coinCount"]];

}
- (void)viewDidLoad {
    [super viewDidLoad];
	
	self.title = NSLocalizedString(@"Home", @"Home Title");	
	NSMutableArray *array = [[NSArray alloc] initWithObjects:@"Profile", @"Wall",@"Drop History", @"Inbox",@"Leaderboard",@"Store", nil];
	self.menuArray = array;
	[array release];
	
    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
    // self.navigationItem.rightBarButtonItem = self.editButtonItem;
}

- (void)viewWillAppear:(BOOL)animated {
	NSLog(@"viewWillAppear in home table view controller");
	[self updateMiniProfile:[NSDictionary dictionaryWithContentsOfFile:@"Profile.plist"]];
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
    [super dealloc];
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
    // Navigation logic may go here. Create and push another view controller.
	// AnotherViewController *anotherViewController = [[AnotherViewController alloc] initWithNibName:@"AnotherView" bundle:nil];
	// [self.navigationController pushViewController:anotherViewController];
	// [anotherViewController release];
	
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

