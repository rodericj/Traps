/*
Copyright 2009 Urban Airship Inc. All rights reserved.

Redistribution and use in source and binary forms, with or without
modification, are permitted provided that the following conditions are met:

1. Redistributions of source code must retain the above copyright notice, this
list of conditions and the following disclaimer.

2. Redistributions in binaryform must reproduce the above copyright notice,
this list of conditions and the following disclaimer in the documentation 
and/or other materials provided withthe distribution.

THIS SOFTWARE IS PROVIDED BY THE URBAN AIRSHIP INC ``AS IS'' AND ANY EXPRESS OR
IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED WARRANTIES OF
MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE DISCLAIMED. IN NO
EVENT SHALL URBAN AIRSHIP INC OR CONTRIBUTORS BE LIABLE FOR ANY DIRECT,
INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES (INCLUDING,
BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES; LOSS OF USE,
DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY OF
LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT (INCLUDING NEGLIGENCE
OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS SOFTWARE, EVEN IF
ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
*/

#import "Airship.h"
#import "UAGlobal.h"
#import "UAInventory.h"
#import "UAAsycImageView.h"
#import "UAUpdateCell.h"
#import "UAStoreUpdatesViewController.h"
#import "UAStoreTabBarController.h"
#import "StoreFront.h"

@implementation UAStoreUpdatesViewController

@synthesize navController;

- (void)dealloc {
	RELEASE_SAFELY(navController);
    [super dealloc];
}

#pragma mark -
#pragma mark UIViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil {
    if (self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil]) {
		self.navController = [[UINavigationController alloc] initWithRootViewController: self];
		self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem: UIBarButtonSystemItemDone 
																							   target: self
																							   action: @selector(done:)];		
        self.title = @"Updates";
		UIImage* image = [UIImage imageWithContentsOfFile: [[NSBundle mainBundle] pathForResource: @"update" ofType: @"png"]];
		self.tabBarItem = [[UITabBarItem alloc] initWithTitle: self.title image: image tag: 0];
		purchaseReceipts = [[NSMutableDictionary alloc] init];
		updates = [[NSMutableArray alloc] init];
		receiptsLoaded = NO;
		[self loadReceipts];
    }
    return self;
}

- (void)didReceiveMemoryWarning {
	// Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
}

#pragma mark -

-(IBAction)done:(id)sender {
	[StoreFront quitStoreFront];
}

-(void)addUpdate:(UAProduct*)product {
	UAUpdateCell* cell = nil;
	NSArray *views = [[NSBundle mainBundle] loadNibNamed: @"UAUpdateCell" 
												   owner: nil 
												 options: nil];
	for(id currentObject in views) {
		if([currentObject isKindOfClass:[UAUpdateCell class]]) {
			cell = (UAUpdateCell *)currentObject;
			break;
		}
	}
	
	[cell setData: product];
	[updates addObject: cell];
	[updatesTable reloadData];
	
	UAStoreTabBarController* root = (UAStoreTabBarController*)[[StoreFront shared] rootViewController];
	[[root.updatesController tabBarItem] setBadgeValue: [NSString stringWithFormat: @"%d", [updates count]]];
	
	self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithTitle: @"Update All"
																					  style: UIBarButtonItemStylePlain
																					 target: self
																					 action: @selector(updateAll)];
}

-(void)updateAll {
	UALOG(@"Updating %d products", [updates count]);
	for(UAUpdateCell* item in updates) {
		[self updateProduct: item.product];
	}
	[updates removeAllObjects];
	[updatesTable reloadData];
	
	UAStoreTabBarController* root = (UAStoreTabBarController*)[[StoreFront shared] rootViewController];
	[[root.updatesController tabBarItem] setBadgeValue: nil];
	[root setSelectedViewController: [root.historyController navController]];
}

-(void)updateProduct: (UAProduct*)product {
	UALOG(@"%@ - %@", product.productIdentifier, product.receipt);
	[[StoreFront shared].sfObserver verifyReceipt: product];
}	

-(void)checkForUpdates {
	
	if([purchaseReceipts count] == 0) {
		return;
	}
	
	for(NSString* productIdentifier in purchaseReceipts) {
		
		UAProduct* product = [[StoreFront shared].inventory productWithIdentifier: productIdentifier];
		NSDictionary* item = [purchaseReceipts objectForKey: productIdentifier];
		product.receipt = [[purchaseReceipts objectForKey: productIdentifier] objectForKey: @"receipt"];
		if(product == nil) {
			UALOG(@"Product no longer in inventory %@", productIdentifier);
			continue;
		}
		if(product.revision > [[item objectForKey: @"revision"] intValue]) {
			[self addUpdate: product];
		}
	}
}

-(void)loadReceipts {
	NSMutableDictionary* fromDisk = [NSMutableDictionary dictionaryWithContentsOfFile: kReceiptHistoryFile];
	if(fromDisk != nil) {
		[purchaseReceipts setDictionary: fromDisk];
	}
	receiptsLoaded = YES;
}

-(void)addReceipt:(UAProduct*)product {
	UALOG(@"Add receipt for product %@", product.productIdentifier);
	NSNumber* rev = [NSNumber numberWithInt: product.revision];
	NSDictionary* data = [NSDictionary dictionaryWithObjectsAndKeys: 
						  rev, @"revision",
						  product.receipt, @"receipt",
						  nil
	];
	[purchaseReceipts setObject: data forKey: product.productIdentifier];
}

-(void)saveReceipts {
	UALOG(@"Saving %d receipts", [purchaseReceipts count]);
	// Don't want to potentially stomp on the file by saving a blank dictionary
	// when the receipts haven't finished loading
	if(receiptsLoaded == NO) {
		return;
	}
	if([purchaseReceipts count] > 0) {
		BOOL saved = [purchaseReceipts writeToFile: kReceiptHistoryFile atomically: YES];
		if(!saved) {
			UALOG(@"Unable to save receipt data to file");
		}
	}
}

#pragma mark -
#pragma mark UITableViewDataSource

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
	UAUpdateCell* cell = (UAUpdateCell*)[updates objectAtIndex: [indexPath row]];
	
	CGRect frame;
	frame.size.width=57; frame.size.height=57;
	frame.origin.x=0; frame.origin.y=0;
	UAAsyncImageView* asyncImage = [[[UAAsyncImageView alloc]
									 initWithFrame:frame] autorelease];
	[asyncImage loadImageFromURL: [cell.product iconURL] withRoundedEdges: YES];	
	[cell.iconContainer addSubview: asyncImage];
	
	int index =[indexPath row];
	if(index%2==0) {
		[cell setIsOdd: YES];
	}
	return cell;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
	return [updates count];
}

@end
