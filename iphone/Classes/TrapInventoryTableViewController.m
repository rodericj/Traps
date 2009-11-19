//
//  TrapInventoryTableViewController.m
//  BoobyTrap3
//
//  Created by Roderic Campbell on 11/13/09.
//  Copyright 2009 __MyCompanyName__. All rights reserved.
//

#import "TrapInventoryTableViewController.h"
#import "UserProfile.h"

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
	//NSDictionary *profile = [NSDictionary dictionaryWithContentsOfFile:@"Profile.p list"];
	NSLog(@"trying singleton inventory again");

	NSArray *inventory = (NSArray *)[profile getInventory];
	//NSArray *inventory = [profile objectForKey:@"inventory"];
	NSLog(@"number of rows has an inventory: %@", inventory);

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
    
	//NSArray *inventory = [NSArray arrayWithContentsOfFile:@"Inventory.p list"];
	//NSDictionary *profile = [NSDictionary dictionaryWithContentsOfFile:@"Profile.p list"];
	//NSArray *inventory = [profile objectForKey:@"inventory"];

	UserProfile *profile = [UserProfile sharedSingleton];
	NSArray *inventory = (NSArray *)[profile getInventory];


    // Set up the cell...
	cell.text = [[inventory objectAtIndex:[indexPath row]] objectForKey:@"name"];
	//[inventory release];
    return cell;
}


- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
	UserProfile *profile = [UserProfile sharedSingleton];
	NSArray *inventory = (NSArray *)[profile getInventory];
	
	NSString *trap = [[inventory objectAtIndex:[indexPath row]] objectForKey:@"name"];
	NSInteger *iid = (NSInteger *)[[inventory objectAtIndex:[indexPath row]] objectForKey:@"id"];
	[profile setWhichTrap:iid];
	//[profile setWhichVenue:[NSString stringWithFormat:@"%d", [indexPath row]]];
	
//[profile setWhichTrap:iid];
	//[profile setWhichTrap:(NSInteger *)[[inventory objectAtIndex:[indexPath row]] objectForKey:@"id"]];
	NSLog(@"ok it's set");
	NSLog(@"now whichTrap within our static object %@", [profile whichTrap]);
	NSLog(@"now whichVenue within our static object %@", [profile whichVenue]);
	//NSLog([indexPath row]);
	//NSLog(@"Set trap 2");
	//whichTrap = [indexPath row];
	//NSLog(whichTrap);
	
	//NSLog(self.whichTrap);
	NSLog(trap);
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
//NSLog(whichTrap);
		//NSLog([NSString stringWithFormat:@"%@", self.whichTrap]);
		UserProfile *profile = [UserProfile sharedSingleton];
		NSArray *inventory = [profile getInventory];
		NSLog(@"has inventory %@ \n %@", [profile whichTrap], inventory);
		//[NSArray arrayWithContentsOfFile:@"Inventory.plist"];
		NSString *trap = [inventory objectAtIndex:(NSInteger*)buttonIndex];

		NSLog(@"the trap name is: %@", trap);
		[NSThread detachNewThreadSelector:@selector(doDropTrap:) toTarget:self withObject:trap];
	}
}

- (void)doDropTrap:(NSString *)trap {
	NSLog(@"doDropTrap Called");
	

	NSAutoreleasePool *pool = [[NSAutoreleasePool alloc] init];
	NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:[NSURL URLWithString:@"http://localhost:8000/SetTrap/"]
															   cachePolicy:NSURLRequestReloadIgnoringLocalCacheData
														   timeoutInterval:60.0];
	[request setHTTPMethod:@"POST"];
	NSLog(@"get outta here");
	//NSLog(@"%@", [self.whichVenue intValue]);
	//NSLog(self.whichVenue);
	NSLog(@"srsly");
	UserProfile *profile = [UserProfile sharedSingleton];
	NSLog(@"%@",[profile whichTrap]);
	[request setHTTPBody:[[NSString stringWithFormat:@"vid=%@&iid=%@", [profile whichVenue], [profile whichTrap]] //vid, iid, uid
							dataUsingEncoding:NSUTF8StringEncoding]];
	[[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:YES];
	NSURLResponse *response;
	NSError *error;

	NSData *urlData = [NSURLConnection sendSynchronousRequest:request
												returningResponse:&response
															error:&error];

	NSString *results = [[NSString alloc] initWithData:urlData encoding:NSUTF8StringEncoding];
	NSLog(@"doDropTrap networking 3");
	NSLog(results);
	NSLog(@"results done");
	NSDictionary *resultsDict =[results JSONValue];
	NSLog(@"net 4");
	//NSLog(@)
	//[foundVenues writeToFile:@"NearbyPlaces.plist" atomically:TRUE];
	self.navigationItem.rightBarButtonItem = nil;
	NSLog(@"net 5");
	[self performSelectorOnMainThread:@selector(didDropTrap:) withObject:resultsDict waitUntilDone:NO];
		[pool release];
}

- (void)didDropTrap:(NSDictionary *) results{
	NSLog(@"start popup");
	//UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Are you sure?" message:@"hi" delegate:self cancelButtonTitle:@"No" otherButtonTitles:@"Yes", nil];
	UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Boom" message:@"You've just set a trap." delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil]; 
	NSLog(@"stop popup");
	
	[alert show]; 
	[alert release]; 
	
}

@end

