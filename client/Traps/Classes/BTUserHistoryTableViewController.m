//
//  BTUserHistoryTableViewController.m
//  Traps
//
//  Created by Roderic Campbell on 3/29/10.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import "BTUserHistoryTableViewController.h"
#import "BTNetwork.h"
#import "BTConstants.h"

#import <JSON/JSON.h>
@implementation BTUserHistoryTableViewController

/*
- (id)initWithStyle:(UITableViewStyle)style {
    // Override initWithStyle: if you create the controller programmatically and want to perform customization that is not appropriate for viewDidLoad.
    if (self = [super initWithStyle:style]) {
    }
    return self;
}
*/


- (void)viewDidLoad {
    [super viewDidLoad];
	[[BTNetwork sharedNetwork] performHttpOperationWithResponseObject:self
													  methodSignature:NSStringFromSelector(@selector(didGetFeed:))
															   method:@"GET"
															   domain:kHTTPHost
														  relativeURL:django_get_user_feed
															   params:nil 
															  headers:nil];
    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
    // self.navigationItem.rightBarButtonItem = self.editButtonItem;
}



//- (void)viewWillAppear:(BOOL)animated {
//
//
//	
//    [super viewWillAppear:animated];
//}


//- (void)viewDidAppear:(BOOL)animated {
//
//    [super viewDidAppear:animated];
//}

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
    return 3;
}

- (UITableViewCell *) getItemCell:(NSString *)cellIdentifier item:(NSUInteger)whichItem{
	CGRect CellFrame = CGRectMake(0, 0, iphonescreenwidth, inventoryitemheight);

	UITableViewCell *cell = [[[UITableViewCell alloc] initWithFrame:CellFrame 
													reuseIdentifier:cellIdentifier] autorelease];
	
   // UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
	[cell.textLabel setText:@"userHistory"];
	return cell;
}
// Customize the appearance of table view cells.
//- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
//    
//    static NSString *CellIdentifier = @"Cell";
//    
//    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
//    if (cell == nil) {
//        cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier] autorelease];
//    }
//    
//    // Set up the cell...
//	[cell.textLabel setText:@"userHistory"];
//    return cell;
//}

- (void)didGetFeed:(id)response{
	//NSLog(@"got the user feed for this user");
	if ([response isKindOfClass:[NSError class]]) {
		NSLog(@"test: response: error!!!: %@", response);		
		return;
	}
	//NSString *responseString = [[NSString alloc] initWithData:response encoding:NSUTF8StringEncoding];
	
	//SBJSON *parser = [SBJSON new];
	//NSArray* responseAsArray = [parser objectWithString:responseString error:NULL];
	//NSLog(@"returned %@", responseAsArray);
}


- (void)dealloc {
    [super dealloc];
}


@end

