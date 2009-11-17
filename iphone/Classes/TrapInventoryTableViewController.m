//
//  TrapInventoryTableViewController.m
//  BoobyTrap3
//
//  Created by Roderic Campbell on 11/13/09.
//  Copyright 2009 __MyCompanyName__. All rights reserved.
//

#import "TrapInventoryTableViewController.h"


@implementation TrapInventoryTableViewController
@synthesize whichTrap;
@synthesize whichVenue;
/*
- (id)initWithStyle:(UITableViewStyle)style {
    // Override initWithStyle: if you create the controller programmatically and want to perform customization that is not appropriate for viewDidLoad.
    if (self = [super initWithStyle:style]) {
    }
    return self;
}
*/

/*
- (void)viewDidLoad {
    [super viewDidLoad];

    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
    // self.navigationItem.rightBarButtonItem = self.editButtonItem;
}
*/

/*
- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
}
*/
/*
- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
}
*/
/*
- (void)viewWillDisappear:(BOOL)animated {
	[super viewWillDisappear:animated];
}
*/
/*
- (void)viewDidDisappear:(BOOL)animated {
	[super viewDidDisappear:animated];
}
*/

/*
// Override to allow orientations other than the default portrait orientation.
- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
    // Return YES for supported orientations
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}
*/

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
	NSDictionary *profile = [NSDictionary dictionaryWithContentsOfFile:@"Profile.plist"];
	NSArray *inventory = [profile objectForKey:@"inventory"];
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
    
	//NSArray *inventory = [NSArray arrayWithContentsOfFile:@"Inventory.plist"];
	NSDictionary *profile = [NSDictionary dictionaryWithContentsOfFile:@"Profile.plist"];
	NSArray *inventory = [profile objectForKey:@"inventory"];

    // Set up the cell...
	cell.text = [[inventory objectAtIndex:[indexPath row]] objectForKey:@"name"];
	//[inventory release];
    return cell;
}


- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
	NSDictionary *profile = [NSDictionary dictionaryWithContentsOfFile:@"Profile.plist"];
	NSArray *inventory = [profile objectForKey:@"inventory"];
	NSString *trap = [[inventory objectAtIndex:[indexPath row]] objectForKey:@"name"];
	NSInteger *iid = [[inventory objectAtIndex:[indexPath row]] objectForKey:@"id"];
	self.whichTrap = [[inventory objectAtIndex:[indexPath row]] objectForKey:@"id"];
	NSLog(@"Set trap");
	//NSLog([indexPath description]);
	NSLog(@"%@", iid);
	NSLog(@"%@", whichTrap);
	NSLog(@"%@", self.whichTrap);
	//NSLog([indexPath row]);
	//NSLog(@"Set trap 2");
	//whichTrap = [indexPath row];
	//NSLog(whichTrap);
	
	//NSLog(self.whichTrap);
	NSLog(trap);
	NSString *alertStatement = [NSString stringWithFormat:@"Are you sure you wish to drop %@? %@", trap, self.whichTrap];
	NSLog(alertStatement);
	UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Are you sure?" message:alertStatement delegate:self cancelButtonTitle:@"No" otherButtonTitles:@"Yes", nil]; 
	
	[alert show]; 
	[alert release]; 
}

- (void)alertView:(UIAlertView *)alertView  clickedButtonAtIndex:(NSInteger)buttonIndex {
	if(buttonIndex == 0){
		NSLog(@"no");
		//Do nothing I guess
	}
	else{
		NSLog(@"Yes");
//NSLog(whichTrap);
		//NSLog([NSString stringWithFormat:@"%@", self.whichTrap]);
		NSLog(@" which trap after 'yes' %d", self.whichTrap);
		NSArray *inventory = [NSArray arrayWithContentsOfFile:@"Inventory.plist"];
		NSString *trap = [inventory objectAtIndex:whichTrap];
		NSLog(@"the trap name is: %@", trap);
		[NSThread detachNewThreadSelector:@selector(doDropTrap:) toTarget:self withObject:trap];
	}
}

- (void)doDropTrap:(NSString *)trap {
	NSLog(@"doDropTrap Called");
	
	//if (location == NULL){
//		NSLog(@"the location was null which means that the thread is doing something intersting. Lets send this back.");
//	}
	//else{
	NSAutoreleasePool *pool = [[NSAutoreleasePool alloc] init];
	NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:[NSURL URLWithString:@"http://localhost:8000/SetTrap/"]
															   cachePolicy:NSURLRequestReloadIgnoringLocalCacheData
														   timeoutInterval:60.0];
	[request setHTTPMethod:@"POST"];
	NSLog(@"get outta here");
	//NSLog(@"%@", [self.whichVenue intValue]);
	//NSLog(self.whichVenue);
	NSLog(@"srsly");
	NSLog(self.whichTrap);
	[request setHTTPBody:[[NSString stringWithFormat:@"vid=%@&iid=%@", whichVenue, whichTrap] //vid, iid, uid
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
//}
}
- (void)didDropTrap:(NSDictionary *) results{
	NSLog(@"start popup");
	//UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Are you sure?" message:@"hi" delegate:self cancelButtonTitle:@"No" otherButtonTitles:@"Yes", nil];
	UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Boom" message:@"You've just set a trap." delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil]; 
	NSLog(@"stop popup");

	[alert show]; 
	[alert release]; 
	
}


/*
// Override to support conditional editing of the table view.
- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath {
    // Return NO if you do not want the specified item to be editable.
    return YES;
}
*/


/*
// Override to support editing the table view.
- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath {
    
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        // Delete the row from the data source
        [tableView deleteRowsAtIndexPaths:[NSArray arrayWithObject:indexPath] withRowAnimation:YES];
    }   
    else if (editingStyle == UITableViewCellEditingStyleInsert) {
        // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
    }   
}
*/


/*
// Override to support rearranging the table view.
- (void)tableView:(UITableView *)tableView moveRowAtIndexPath:(NSIndexPath *)fromIndexPath toIndexPath:(NSIndexPath *)toIndexPath {
}
*/


/*
// Override to support conditional rearranging of the table view.
- (BOOL)tableView:(UITableView *)tableView canMoveRowAtIndexPath:(NSIndexPath *)indexPath {
    // Return NO if you do not want the item to be re-orderable.
    return YES;
}
*/


- (void)dealloc {
    [super dealloc];
}


@end

