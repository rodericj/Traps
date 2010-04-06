//
//  BTUserInventoryTableView.m
//  Traps
//
//  Created by Roderic Campbell on 3/29/10.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import "BTUserInventoryTableView.h"
#import <JSON/JSON.h>
#import "BTNetwork.h"
#import "asyncimageview.h"
#import "BTUserProfile.h"

@implementation BTUserInventoryTableView

@synthesize userInventory;
//TODO get rid of all of the unused / commented out code



- (void)viewDidLoad {
	[[BTNetwork sharedNetwork] performHttpOperationWithResponseObject:self
													  methodSignature:NSStringFromSelector(@selector(ProfileLoaded:))
															   method:@"POST"
															   domain:kHTTPHost
														  relativeURL:@"GetMyUserProfile/"
															   params:nil];
    [super viewDidLoad];

    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
    // self.navigationItem.rightBarButtonItem = self.editButtonItem;
}



- (void)viewWillAppear:(BOOL)animated {
	
    [super viewWillAppear:animated];
}

#pragma mark -
#pragma mark networking
-(void)ProfileLoaded:(id)response{
	if ([response isKindOfClass:[NSError class]]) {
		NSLog(@"test: response: error!!!: %@", response);		
		return;
	}
	NSString *responseString = [[NSString alloc] initWithData:response encoding:NSUTF8StringEncoding];
	
	SBJSON *parser = [SBJSON new];
	NSDictionary* responseAsDictionary = [parser objectWithString:responseString error:NULL];
	NSLog(@"returned from the server for inventory %@", responseAsDictionary);
	userInventory = [[responseAsDictionary objectForKey:@"inventory"] copy];
	NSLog(@"the inventory is %@", userInventory);
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
	if (userInventory == nil) {
		return 0;
	}
    return [userInventory count];
}

-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
	return inventoryitemheight;
}


- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
	//TODO may need to conditionalize this for if we are in the select a trap to drop view
	NSLog(@"selected %d", [indexPath row]);
	[[BTUserProfile sharedBTUserProfile] setSelectedTrap:[indexPath row]];
	NSLog(@"selected from profile %d", [[BTUserProfile sharedBTUserProfile] selectedTrap]);

	[self.navigationController popViewControllerAnimated:TRUE];
	
}

// Customize the appearance of table view cells.
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    //static NSString *CellIdentifier = @"Cell";
	NSString *reuseId = [NSString stringWithFormat:@"home%d", [indexPath row]];

    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:reuseId];
    if (cell == nil) {
       // cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier] autorelease];
		cell = [self getInventoryItemCell:reuseId item:[userInventory objectAtIndex:[indexPath row]]];
	}
        
	// Set up the cell...
    return cell;
}


- (UITableViewCell *) getInventoryItemCell:(NSString *)cellIdentifier item:(NSDictionary *)item{
	//name
	NSString *itemName = [item objectForKey:@"name"];
	NSString *itemDescription = [item objectForKey:@"note"];
	
	CGRect CellFrame = CGRectMake(0, 0, iphonescreenwidth, inventoryitemheight);
	UITableViewCell *cell = [[[UITableViewCell alloc] initWithFrame:CellFrame 
													reuseIdentifier:cellIdentifier] autorelease];
	
	CGRect ItemNameLabelFrame = CGRectMake(inventoryitemwidth, 0, iphonescreenwidth - inventoryitemwidth, 25);
	CGRect ItemDescriptionFrame = CGRectMake(inventoryitemwidth, 20, iphonescreenwidth - inventoryitemwidth, 25);
	CGRect ItemImageFrame = CGRectMake(0, 0, inventoryitemwidth, inventoryitemheight);
	
	UIImage *userImage;
	userImage = [UIImage imageNamed:@"user.png"];
	
	//For the upcoming text, pick a color
	UIColor *textColor = [UIColor blackColor];	
	
	UILabel *lblTemp;
	lblTemp = [[UILabel alloc] initWithFrame:ItemNameLabelFrame];
	lblTemp.tag = 1;
	[lblTemp setBackgroundColor:[UIColor clearColor]];
	[lblTemp setText:itemName];
	[lblTemp setTextColor:[UIColor blueColor]];
	[cell.contentView addSubview:lblTemp];
	[lblTemp release];
	
	lblTemp = [[UILabel alloc] initWithFrame:ItemDescriptionFrame];
	lblTemp.tag = 1;
	[lblTemp setBackgroundColor:[UIColor clearColor]];
	[lblTemp setText:itemDescription];
	[lblTemp setAdjustsFontSizeToFitWidth:TRUE];
	[lblTemp setTextColor:textColor];
	[cell.contentView addSubview:lblTemp];
	[lblTemp release];
		
	AsyncImageView *asyncImage = [[AsyncImageView alloc] initWithFrame:ItemImageFrame];
	asyncImage.tag = 999;
	NSURL *url = [NSURL URLWithString:[NSString stringWithFormat:@"http://%@/%@", kHTTPHost, [item objectForKey:@"path"]]];
	[asyncImage loadImageFromURL:url];
	[cell.contentView addSubview:asyncImage];
	
	return cell;
	
}

- (void)dealloc {
    [super dealloc];
}


@end

