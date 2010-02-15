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
#import "UADownloadHistoryCell.h"
#import "UAStoreTabBarController.h"
#import "UAGlobal.h"

@implementation UADownloadProgressCell

@synthesize progressView;
@synthesize title;
@synthesize dateView;
@synthesize item;
@synthesize iconContainer;

- (void)dealloc {
	RELEASE_SAFELY(iconContainer);
	RELEASE_SAFELY(dateView);
	RELEASE_SAFELY(progressView);
	RELEASE_SAFELY(title);
	[super dealloc];
}

- (void)setData:(UADownloadHistoryItem*)_item {
	title.text = _item.title;
	dateView.text = _item.dateDisplay;
	self.item = _item;
	if(_item.finished == YES) {
		[self processingDone];
	} else {
		[self resetProgress];
	}
}

- (void)resetProgress {
	[self.item setProgressDelegate: self];
	[progressView setHidden: NO];
	[self setAccessoryType: UITableViewCellAccessoryNone];
}

- (void)processingDone {
	[self.item setFinished: YES];
	[activityView stopAnimating];
	[progressView setHidden: YES];
	[processing setHidden: YES];
	[self setAccessoryType: UITableViewCellAccessoryCheckmark];
}

- (void)downloadDone {
	[progressView setHidden: YES];
	[activityView startAnimating];
	[processing setHidden: NO];
}

- (void)incrementDownloadCount {
	UAStoreTabBarController* root = [[StoreFront shared] rootViewController];
	int current = [[[root.historyController tabBarItem] badgeValue] intValue];
	[[root.historyController tabBarItem] setBadgeValue: 
		[NSString stringWithFormat: @"%d", current +1]];
	tabBarNotified = YES;	
}

- (void)decrementDownloadCount {
	UAStoreTabBarController* root = [[StoreFront shared] rootViewController];
	int current = [[[root.historyController tabBarItem] badgeValue] intValue];
	int val = current - 1;
	if (val>0) {
		[[root.historyController tabBarItem] setBadgeValue: 
			[NSString stringWithFormat: @"%d", val]];
	} else {
		[[root.historyController tabBarItem] setBadgeValue: nil];
	}	
}

- (void)setProgress:(float)progress {
	if(progress >= kProcessingDone) {
		[self processingDone];
		[self decrementDownloadCount];
		
		//Notify delegate
		StoreFront* sf = [StoreFront shared];
		UAProduct* product = [[[StoreFront shared] inventory] productWithIdentifier: item.productIdentifier];
		[sf.delegate productPurchased: product];
		
		return;
	} else if(progress >= kDownloadDone) {
		[self downloadDone];
		return;
	} else {
		progressView.progress = progress;
	}
	if(!tabBarNotified) {
		[self incrementDownloadCount];
	}
}

@end
