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

#import "UAStoreTabBarController.h"
#import "UAInventory.h"
#import "StoreFront.h"
#import "UAGlobal.h"

@implementation UAStoreTabBarController

@synthesize historyController;
@synthesize updatesController;
@synthesize downloadController;


- (void)dealloc {
	RELEASE_SAFELY(updatesController);
	RELEASE_SAFELY(historyController);
	RELEASE_SAFELY(downloadController);
    [super dealloc];
}

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil {
    if (self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil]) {
		NSMutableArray* controllers = [NSMutableArray arrayWithCapacity: 3];
		
		//Make sure ~/Documents/ua directory exists, we use it for storing
		//various bits of data like download history, image cache
		BOOL uaExists = [[NSFileManager defaultManager] fileExistsAtPath: kUADirectory];
		if(!uaExists) {
			[[NSFileManager defaultManager] createDirectoryAtPath: kUADirectory attributes: nil];
		}		
		
		//Downloads
		downloadController = [[UAStoreFrontViewController alloc] initWithNibName: @"UAStoreFront" bundle: nil];
		[controllers addObject: downloadController.navController];
		
		//Updates
		updatesController = [[UAStoreUpdatesViewController alloc] initWithNibName: @"UAStoreUpdates" bundle: nil];
		[controllers addObject: updatesController.navController];
		
		//Download History
		historyController = [[UADownloadHistoryViewController alloc] initWithNibName: @"UADownloadHistory" bundle: nil];
		historyController.rootController = self;
		[controllers addObject: historyController.navController];
		
		self.viewControllers = controllers;
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
}

-(void)viewWillAppear:(BOOL)animated {
	[super viewWillAppear: animated];
	//Turn on Statusbar after saving previous state
	[UIApplication sharedApplication].statusBarOrientation = UIInterfaceOrientationPortrait;
	appStatusBarHidden = [[UIApplication sharedApplication] isStatusBarHidden];
	[[UIApplication sharedApplication] setStatusBarHidden: NO];
	appStatusBarStyle = [[UIApplication sharedApplication] statusBarStyle];
	[[UIApplication sharedApplication] setStatusBarStyle: UIStatusBarStyleDefault];
	appStatusBarOrientation = [UIApplication sharedApplication].statusBarOrientation;	
}

- (void)viewDidDisappear:(BOOL)animated {
	[super viewWillAppear: animated];
	[[UIApplication sharedApplication] setStatusBarHidden: appStatusBarHidden];
	[[UIApplication sharedApplication] setStatusBarStyle: appStatusBarStyle];
	[UIApplication sharedApplication].statusBarOrientation = appStatusBarOrientation;
	[historyController saveToDisk];
	[updatesController saveReceipts];
}

- (void)didReceiveMemoryWarning {
	// Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
}

- (void)viewDidUnload {
	[super viewDidUnload];
}

@end
