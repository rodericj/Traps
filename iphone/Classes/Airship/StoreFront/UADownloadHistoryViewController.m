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
#import "UAGlobal.h"
#import "UAAsycImageView.h"
#import "UADownloadHistoryViewController.h"
#import "UAStoreTabBarController.h"
#import "UADownloadHistoryItem.h"


@implementation UADownloadHistoryViewController

@synthesize navController;
@synthesize historyTable;
@synthesize rootController;
@synthesize rowColors;

@synthesize downloadItems;

- (void)dealloc {
	RELEASE_SAFELY(historyTable);
	RELEASE_SAFELY(navController);
	RELEASE_SAFELY(rootController);
	RELEASE_SAFELY(downloadItems);
	RELEASE_SAFELY(rowColors);
    [super dealloc];
}


#pragma mark -
#pragma mark UIViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil {
    if (self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil]) {
		self.title = @"Downloads";
		self.tabBarItem = [[UITabBarItem alloc] initWithTabBarSystemItem: UITabBarSystemItemDownloads tag: 4];
		self.navController = [[UINavigationController alloc] initWithRootViewController: self];
		self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem: UIBarButtonSystemItemDone 
																							   target: self
																							   action: @selector(done:)];
		
		historyLoaded = NO;
	}
    return self;
}

- (void)viewDidLoad {
	downloadItems = [[NSMutableArray alloc] init];
	[self loadHistory];
}

- (void)viewDidUnload {
	[self saveToDisk];
	RELEASE_SAFELY(downloadItems);
	RELEASE_SAFELY(rowColors);
}

#pragma mark -
#pragma mark UITableViewDelegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
}

#pragma mark -
#pragma mark UITableViewDataSource

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
	UADownloadProgressCell* cell = (UADownloadProgressCell*)[tableView dequeueReusableCellWithIdentifier: @"any-cell"];
	if (cell == nil) {
		NSArray *topLevelObjects = [[NSBundle mainBundle] loadNibNamed: @"UADownloadProgressCell" owner: nil options: nil];
		for(id currentObject in topLevelObjects) {
			if([currentObject isKindOfClass:[UADownloadProgressCell class]]) {
				cell = (UADownloadProgressCell *)currentObject;
				break;
			}
		}
	} else {
		UAAsyncImageView* oldImage = (UAAsyncImageView*) [cell.contentView viewWithTag:999];
		[oldImage removeFromSuperview];
	}
	
	UADownloadHistoryItem *item = [downloadItems objectAtIndex:indexPath.row];
	[cell setData: item];
	
	CGRect frame;
	frame.size.width=57; frame.size.height=57;
	frame.origin.x=0; frame.origin.y=0;
	UAAsyncImageView* asyncImage = [[[UAAsyncImageView alloc]
									 initWithFrame: frame] autorelease];
	asyncImage.tag = 999;
	[asyncImage loadImageFromURL: item.iconURL withRoundedEdges: YES];	
	[cell.iconContainer addSubview: asyncImage];	
	
	[cell setIsOdd: [[rowColors objectForKey: item.order] intValue]];
	
	return cell;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
	return [downloadItems count];
}

#pragma mark -

-(void)scrollToTop {
	[historyTable setContentOffset:CGPointMake(0, 0) animated: YES];
}

-(id)addDownload: (UAProduct*)product {
	[self scrollToTop];
	
	UADownloadHistoryItem* item = [[UADownloadHistoryItem alloc] initWithProduct: product];
	[downloadItems insertObject:item atIndex:0];
	NSNumber* odd = [NSNumber numberWithInt:  [downloadItems count] % 2];
	[rowColors setObject: odd forKey: item.order];
	[item release];

	NSIndexPath* path = [NSIndexPath indexPathForRow: 0 inSection: 0];
	NSArray* paths = [[NSArray alloc] initWithObjects: path, nil];
	[historyTable insertRowsAtIndexPaths: paths withRowAnimation: UITableViewRowAnimationTop];
	[paths release];
	return item;
}

-(void)loadHistory {
	NSMutableArray* history = [[NSMutableArray alloc] initWithContentsOfFile: kDownloadHistoryFile];
	rowColors = [[NSMutableDictionary alloc] init];
	
	for(NSDictionary* dict in history) {
		UADownloadHistoryItem* item = [[UADownloadHistoryItem alloc] initWithDict: dict];
		[downloadItems addObject:item];
		NSNumber* odd = [NSNumber numberWithInt:  [downloadItems count] % 2];
		[rowColors setObject: odd forKey: item.order];
		[item release];
	}
	[history release];
	historyLoaded = YES;
}

-(void)saveToDisk {
	// don't stomp on our history
	if(!historyLoaded) {
		return;
	}

	NSMutableArray* history = [NSMutableArray arrayWithCapacity: [downloadItems count]];
	for(UADownloadHistoryItem* item in downloadItems) {
		if(item.finished == YES) {
			[history addObject: [item toDict]];
		}
	}
	BOOL saved = [history writeToFile: kDownloadHistoryFile atomically: YES];
	if(!saved) {
		UALOG(@"Failed to save history to disk");
	}
}

-(IBAction)done:(id)sender {
	[StoreFront quitStoreFront];
}

@end
