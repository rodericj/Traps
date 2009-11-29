//
//  TrapInventoryTableViewController.m
//  BoobyTrap3
//
//  Created by Roderic Campbell on 11/13/09.
//  Copyright 2009 __MyCompanyName__. All rights reserved.
//

#import "TrapInventoryTableViewController.h"
#import "UserProfile.h"
#import "NetworkRequestOperation.h"
#import "BoobyTrap3AppDelegate.h"
#import "FBConnect/FBConnect.h"

@implementation TrapInventoryTableViewController

#pragma mark initialization

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
    [super dealloc];
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
	NSLog(@"creating the cells at the rows");

    static NSString *CellIdentifier = @"Cell";
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
        cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier] autorelease];
    }
    
	UserProfile *profile = [UserProfile sharedSingleton];
	NSArray *inventory = (NSArray *)[profile getInventory];


    // Set up the cell...
	cell.text = [[inventory objectAtIndex:[indexPath row]] objectForKey:@"name"];
    return cell;
}


- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
	UserProfile *profile = [UserProfile sharedSingleton];
	NSArray *inventory = (NSArray *)[profile getInventory];
	NSString *trap = [[inventory objectAtIndex:[indexPath row]] objectForKey:@"name"];
	NSInteger *iid = (NSInteger *)[[inventory objectAtIndex:[indexPath row]] objectForKey:@"id"];
	[profile setWhichTrap:iid];

	NSString *alertStatement = [NSString stringWithFormat:@"Are you sure you wish to drop %@? %@", trap, [profile whichTrap]];
	NSLog(alertStatement);
	UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Are you sure?" message:alertStatement delegate:self cancelButtonTitle:@"No" otherButtonTitles:@"Yes", nil]; 
	
	[alert show]; 
	[alert release]; 
}

#pragma mark Drop Trap Flow

- (void)alertView:(UIAlertView *)alertView  clickedButtonAtIndex:(NSInteger)buttonIndex {

	if(buttonIndex == 0){
		NSLog(@"no");
		//Do nothing I guess
	}
	else{
		NSLog(@"Yes");
		UserProfile *profile = [UserProfile sharedSingleton];
		NSArray *inventory = [profile getInventory];
		[self doDropTrap];
	}
}

- (void)doDropTrap {
	UserProfile *profile = [UserProfile sharedSingleton];
	NetworkRequestOperation *op = [[NetworkRequestOperation alloc] init];
	[op setTargetURL:@"SetTrap"];
	op.arguments = [[NSMutableDictionary alloc] init];
	[op.arguments setObject:[profile whichVenue] forKey:@"vid"];
	[op.arguments setObject:(NSString *)[profile whichTrap] forKey:@"iid"];
	op.callingDelegate = self;
	queue = [[NSOperationQueue alloc] init];
	[queue addOperation:op];
	[op release];
	
}

- (void)pageLoaded:(NSDictionary*)webRequestResults{
	NSLog(@"webrequest returned %@", webRequestResults);
	[self didDropTrap:webRequestResults];
}

- (void)didDropTrap:(NSDictionary *) results{
	UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Boom" message:@"You've just set a trap." delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil]; 
	[alert show]; 
	[alert release]; 
	
	//FBPermissionDialog *dialog = [[[FBPermissionDialog alloc] init] autorelease];
//	dialog.permission = @"status_update";
//	[dialog show];
	
	[self.navigationController popViewControllerAnimated:TRUE];
}

@end

