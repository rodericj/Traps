//
//  SegmentedTableViewController.m
//  BoobyTrap3
//
//  Created by Roderic Campbell on 2/18/10.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import "SegmentedTableViewController.h"
#import "NetworkRequestOperation.h"
#import "UserProfile.h"
#import "BoobyTrap3AppDelegate.h"

@implementation SegmentedTableViewController

-(void)viewWillAppear:(BOOL)animated{	
	NetworkRequestOperation *op = [[NetworkRequestOperation alloc] init];
	[op setTargetURL:@"GetUserFeed"];
	op.callingDelegate = self;
	
	queue = [[NSOperationQueue alloc] init];
	[queue addOperation:op];
	[op release];
}

- (void)pageLoaded:(NSArray*)webRequestResults{
	UserProfile *userProfile = [UserProfile sharedSingleton];
	[userProfile setUserFeed:webRequestResults];
	
	if (selectedSegment == INVENTORYSEGMENT) {
		currentData = [userProfile getInventory];
	}
	else if (selectedSegment == USERFEEDSEGMENT){
		currentData = webRequestResults;
	}
	[self.tableView reloadData];
}

- (void)viewDidLoad {
	UISegmentedControl *segmentControl = (UISegmentedControl *)self.navigationItem.titleView;
	[segmentControl addTarget:self action:@selector(segmentAction:) forControlEvents:UIControlEventValueChanged];
	selectedSegment = [segmentControl selectedSegmentIndex];
	self.navigationItem.titleView = segmentControl;
	
    [super viewDidLoad];
}

-(void)segmentAction:(id)sender{
	UISegmentedControl *segmentControl = sender;
	selectedSegment = [segmentControl selectedSegmentIndex];
	UserProfile *userProfile = [UserProfile sharedSingleton];

	if (selectedSegment == USERFEEDSEGMENT) {
		currentData = [userProfile userFeed];
	}
	else if(selectedSegment == INVENTORYSEGMENT){
		currentData = [userProfile getInventory];
	}
	
	[self.tableView reloadData];
	
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
	return [currentData count];
}

// Customize the appearance of table view cells.
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    static NSString *CellIdentifier = @"Cell";
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
        cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier] autorelease];
    }
    
    // Set up the cell...
	NSDictionary *row = [currentData objectAtIndex:[indexPath row]];
	
	if(selectedSegment == USERFEEDSEGMENT){		
		cell.text = [NSString stringWithFormat:@"%@", [row objectForKey:@"name"]];
	}
	else if (selectedSegment == INVENTORYSEGMENT) {
		UserProfile *userProfile = [UserProfile sharedSingleton];
		NSArray *inventory = [userProfile getInventory];
		NSDictionary *thisItem = [inventory objectAtIndex:[indexPath row]];
		cell.text = [NSString stringWithFormat:@"%@ : %@",  
					 [thisItem objectForKey:@"name"], 
					 [thisItem objectForKey:@"count"]];
	}
	

	//cell.text = [NSString stringWithFormat:@"%@", [row objectForKey:@"name"]];

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

