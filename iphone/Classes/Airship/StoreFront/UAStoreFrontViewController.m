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
#import "StoreFront.h"

#import "UAStoreFrontViewController.h"
#import "UAProductDetailViewController.h"
#import "UAStoreTabBarController.h"		
#import "UAStoreFrontCell.h"
#import "UAAsycImageView.h"

@implementation UAStoreFrontViewController

@synthesize navController;

#pragma mark -
#pragma mark UIViewController

- (void)dealloc {
	RELEASE_SAFELY(navController);
    [super dealloc];
}

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil {
    if (self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil]) {
		self.title = @"Content";
		UIImage* image = [UIImage imageWithContentsOfFile: [[NSBundle mainBundle] pathForResource: @"content" ofType: @"png"]];
		self.tabBarItem = [[UITabBarItem alloc] initWithTitle: self.title image: image tag: 0];
		
		self.navController = [[UINavigationController alloc] initWithRootViewController: self];
		self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem: UIBarButtonSystemItemDone 
																							   target: self
																							   action: @selector(done:)];
		
    }
    return self;
}

-(void)viewDidLoad {
    [super viewDidLoad];
	[activity startAnimating];
	[activity setHidden: NO];
	[status setHidden: NO];
	[status setText: @"Fetching inventory."];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

- (void)viewDidUnload {
}

- (void)viewDidDisappear:(BOOL)animated {
	[super viewDidDisappear:animated];
	[productTable deselectRowAtIndexPath:[productTable indexPathForSelectedRow] animated:NO];
}

-(IBAction)done:(id)sender {
	[StoreFront quitStoreFront];
}

#pragma mark -
#pragma mark UITableViewDelegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
	UAProductDetailViewController *productDetail = [[UAProductDetailViewController alloc] initWithNibName:@"UAProductDetail" bundle:nil];
	productDetail.product = [[StoreFront shared].inventory productAtIndex: [indexPath row]];
	productDetail.navController = navController;
	[navController pushViewController: productDetail animated: YES];
	[navController setDelegate: self];
}

#pragma mark -
#pragma mark UITableViewDataSource

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
	UAStoreFrontCell* cell = (UAStoreFrontCell*)[tableView dequeueReusableCellWithIdentifier: @"any-cell"];
	if (cell == nil) {
		NSArray *topLevelObjects = [[NSBundle mainBundle] loadNibNamed: @"UAStoreFrontCell" owner: nil options: nil];
		for(id currentObject in topLevelObjects) {
			if([currentObject isKindOfClass:[UAStoreFrontCell class]]) {
				cell = (UAStoreFrontCell *)currentObject;
				break;
			}
		}
	} else {
		UAAsyncImageView* oldImage = (UAAsyncImageView*) [cell.contentView viewWithTag:999];
		[oldImage removeFromSuperview];
	}
	
	UAProduct* product = [[StoreFront shared].inventory productAtIndex: [indexPath row]];
	
	CGRect frame;
	frame.size.width=57; frame.size.height=57;
	frame.origin.x=0; frame.origin.y=0;
	UAAsyncImageView* asyncImage = [[[UAAsyncImageView alloc]
								   initWithFrame:frame] autorelease];
	asyncImage.tag = 999;
	[asyncImage loadImageFromURL: product.iconURL withRoundedEdges: YES];	
	[cell.iconContainer addSubview: asyncImage];

	int index;
	index = [indexPath row];
	if(index%2==0) {
		[cell setIsOdd: YES];
	}
	
	[cell setData: product];

	return cell;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
	return [[StoreFront shared].inventory count];
}

#pragma mark -
#pragma mark UAInventoryStatusDelegate

-(void)updateInventoryStatus:(UAInventoryStatus)theStatus {
	if(theStatus == UAInventoryStatusApple) {
		[status setText: @"Retrieving pricing information from Apple."];
	} else if(theStatus == UAInventoryStatusFailed) {
		[status setText: @"Failed to contact server."];
		[activity stopAnimating];
		[activity setHidden: YES];
	} else if(theStatus == UAInventoryStatusFinished) {
		[activity stopAnimating];
		[activity setHidden: YES];
		[status setHidden: YES];
		[productTable reloadData];
	}
}

@end
