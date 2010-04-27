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
@synthesize trapsOnly;
//TODO get rid of all of the unused / commented out code



- (void)viewDidLoad {
	[[BTNetwork sharedNetwork] performHttpOperationWithResponseObject:self
													  methodSignature:NSStringFromSelector(@selector(ProfileLoaded:))
															   method:@"POST"
															   domain:kHTTPHost
														  relativeURL:django_get_my_user_profile
															   params:nil 
															  headers:nil];
    [super viewDidLoad];

	NSLog(@"time to start up the spinner");
	_spinner = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleWhiteLarge];
	[_spinner setFrame:CGRectMake(iphonescreenwidth/2-20, iphonescreenheight/2 - navbarheight - iphonetabbarheight - inventoryitemheight, 40, 40)];
	[self.view addSubview:_spinner];
	[_spinner startAnimating];
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
	NSLog(@"the inventory is %@ %@", userInventory, [userInventory class]);
	userTraps = [[NSMutableArray alloc] init];
	for (NSDictionary *item in userInventory){
		NSString *type = [item objectForKey:@"type"];
		if([type isEqual:@"TP"]){
			NSLog(@"this one is a trap");
			NSLog(@" %@", item);
			[userTraps addObject:item];
		}
		else{
			NSLog(@"this is not a trap");
			NSLog(@" %@", item);
		}
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
    NSArray *thisArray;
	if(trapsOnly){
		thisArray = userTraps;
	}
	else{
		thisArray = userInventory;
	}
	
	if (thisArray == nil) {
		return 0;
	}
	[_spinner stopAnimating];
	[_spinner release];
    return [thisArray count];
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
    NSArray *thisArray;
	if(trapsOnly){
		thisArray = userTraps;
	}
	else{
		thisArray = userInventory;
	}
    //static NSString *CellIdentifier = @"Cell";
	NSString *reuseId = [NSString stringWithFormat:@"home%d", [indexPath row]];

    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:reuseId];
    if (cell == nil) {
       // cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier] autorelease];
		cell = [self getInventoryItemCell:reuseId item:[thisArray objectAtIndex:[indexPath row]]];
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

