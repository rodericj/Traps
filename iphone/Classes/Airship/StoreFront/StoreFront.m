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

#import "StoreFront.h"
#import "UAStoreTabBarController.h"
#import "UAStoreKitObserver.h"
#import "UAAsycImageView.h"

@implementation StoreFront

@synthesize rootViewController;
@synthesize sfObserver;
@synthesize delegate;
@synthesize inventory;

SINGLETON_IMPLEMENTATION(StoreFront)

-(void)dealloc {
	RELEASE_SAFELY(rootViewController);
	RELEASE_SAFELY(sfObserver);
	RELEASE_SAFELY(inventory);
	self.delegate = nil;
	[super dealloc];
}	

-(void)cleanup {
	[[SKPaymentQueue defaultQueue] removeTransactionObserver: sfObserver];
}

-(id)init {
	UALOG(@"INIT");
	
    if (self = [super init]) {
		//Setup transaction observer
		sfObserver = [[UAStoreKitObserver alloc] init];
    }
    return self;
}

// Thanks to jjthrash http://gist.github.com/228050
+ (UIView*)makeStoreFrontView {
 	StoreFront* sf = [StoreFront shared];
 	[[SKPaymentQueue defaultQueue] addTransactionObserver: sf.sfObserver];

	if(sf.rootViewController == nil) {
		UAStoreTabBarController* tabBarController = [[UAStoreTabBarController alloc] initWithNibName:nil bundle:nil];
		sf.rootViewController = tabBarController;
		
		// Let download history know about updates to inventory
		sf.inventory = [[UAInventory alloc] initWithStatusDelegate: tabBarController.downloadController];
	}
	
	return sf.rootViewController.view;
}

+ (void)displayStoreFront {
	UIWindow* kwin =  [[UIApplication sharedApplication] keyWindow];
	[kwin addSubview: [self makeStoreFrontView]];
}
	

+ (void)quitStoreFront {
	StoreFront* sf = [StoreFront shared];
	if([sf.delegate respondsToSelector: @selector(storeFrontWillHide)]) {
		[sf.delegate storeFrontWillHide];
	}
	[sf.rootViewController.view removeFromSuperview];
	if([sf.delegate respondsToSelector: @selector(storeFrontDidHide)]) {
		[sf.delegate storeFrontDidHide];
	}
}

@end
