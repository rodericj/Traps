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
#import "UAStoreTabBarController.h"
#import "UAStoreKitObserver.h"
#import "UAGlobal.h"

#import "SBJSON.h"
#import "ZipArchive.h"

@implementation UAStoreFrontRequest

@synthesize transaction;
@synthesize product;

- (void)dealloc {
	RELEASE_SAFELY(product);
	RELEASE_SAFELY(transaction);
	[super dealloc];
}

@end

@implementation UAStoreKitObserver

- (void)dealloc {
	[networkQueue cancelAllOperations];
	[super dealloc];
}


#pragma mark -
#pragma mark SKPaymentTransactionObserver

- (void)paymentQueue:(SKPaymentQueue *)queue removedTransactions:(NSArray *)transactions {
	UALOG(@"paymentQueue:removedTransaction");
}

- (void)paymentQueue:(SKPaymentQueue *)queue updatedTransactions:(NSArray *)transactions {
    for (SKPaymentTransaction *transaction in transactions) {
        switch (transaction.transactionState) {
			case SKPaymentTransactionStatePurchasing:
				break;
            case SKPaymentTransactionStatePurchased:
                [self completeTransaction:transaction];
                break;
            case SKPaymentTransactionStateFailed:
                [self failedTransaction:transaction];
                break;
            case SKPaymentTransactionStateRestored:
                [self restoreTransaction:transaction];
            default:
                break;
        }
    }
}

#pragma mark -

- (void) completeTransaction: (SKPaymentTransaction *)transaction {
	UALOG(@"Purchase Successful, provide content");
	[self verifyReceipt: transaction];
}

- (void) restoreTransaction: (SKPaymentTransaction *)transaction {
	UALOG(@"Restore Transaction");
    [self verifyReceipt: transaction];
}

- (void) failedTransaction: (SKPaymentTransaction *)transaction {
    if ((int)transaction.error.code != SKErrorPaymentCancelled) {
		UALOG(@"Transaction Failed (%d), product: %@", (int)transaction.error.code, transaction.payment.productIdentifier);
		UIAlertView *failureAlert = [[UIAlertView alloc] initWithTitle :@"In-App-Purchase Error:"
															   message: @"There was an error purchasing this item please try again."
															 delegate : self cancelButtonTitle:@"OK"otherButtonTitles:nil];
		[failureAlert show];
		[failureAlert release];
    }
    [[SKPaymentQueue defaultQueue] finishTransaction: transaction];
}

#pragma mark -
#pragma mark Network Interactions

- (void) verifyReceipt:(id)product {
	networkQueue = [ASINetworkQueue queue];
	[networkQueue retain];
	NSString* productIdentifier = nil;
	if ([product isKindOfClass:[UAProduct class]])  {
		productIdentifier = [(UAProduct*)product productIdentifier];
	} else if([product isKindOfClass: [SKPaymentTransaction class]]) {
		productIdentifier = [[(SKPaymentTransaction*)product payment] productIdentifier];
	}
	
	NSString* server = [[Airship shared] server];
	NSString *urlString = [NSString stringWithFormat: @"%@/api/app/content/%@/download", server, productIdentifier];
	NSURL* itemURL = [NSURL URLWithString: urlString];
	UAStoreFrontRequest *request = [[UAStoreFrontRequest alloc] initWithURL: itemURL];
	
	if([product isKindOfClass: [SKPaymentTransaction class]]) {
		[request setTransaction: product];
	} else {
		request.product = product;
	}
	
	[request setRequestMethod: @"POST"];
	request.password = [[Airship shared] appSecret];
	request.username = [[Airship shared] appId];
	[request setUseSessionPersistance: NO]; // We don't want to UA auth to S3
	[request setDelegate: self];
	[request setDidFinishSelector: @selector(downloadStoreItem:)];
	[request setShouldRedirect: NO];
	
	NSString* receipt = nil;
	if([product isKindOfClass: [SKPaymentTransaction class]]) {
		receipt = [[NSString alloc] initWithData: [(SKPaymentTransaction*)product transactionReceipt] encoding: NSUTF8StringEncoding];
	} else {
		if([(UAProduct*)product isFree] != YES) {
			receipt = [(UAProduct*)product receipt];
		}
	}

	if(receipt != nil) {
		[request addRequestHeader: @"Content-Type" value: @"application/json"];
		NSDictionary* data = [NSDictionary dictionaryWithObjectsAndKeys: receipt, @"transaction_receipt", nil];
		SBJsonWriter *writer = [SBJsonWriter new];
		[request appendPostData: [[writer stringWithObject: data] dataUsingEncoding: NSUTF8StringEncoding]];
		[writer release];
	}
	
    [networkQueue addOperation: request];
	[networkQueue go];
	
	[receipt release];
}


//Pull an item from the store and decompress it into the ~/Documents directory
- (void) downloadStoreItem:(UAStoreFrontRequest*)request {
	
	NSString* productIdentifier = nil;
	if(request.product != nil) {
		productIdentifier = request.product.productIdentifier;
	} else if(request.transaction != nil) {
		productIdentifier = [[request.transaction payment] productIdentifier];
	}
	
	StoreFront* sf = [StoreFront shared];
	UAStoreTabBarController* root = (UAStoreTabBarController*)sf.rootViewController;
	UAProduct* product = [[StoreFront shared].inventory productWithIdentifier: productIdentifier];

	//Save receipt
	if(request.transaction) {
		product.receipt = [[NSString alloc] initWithData: [request.transaction transactionReceipt] encoding: NSUTF8StringEncoding];
		[root.updatesController addReceipt: product];
	}

	if (request.responseStatusCode != 200) {
		UALOG(@"Failure verifying receipt");
		UALOG(@"Server Response: %d, %@, %@", request.responseStatusCode, request.responseHeaders, [request responseString]);
		//TODO: Fail visually
		return;
	}
	SBJsonParser *parser = [SBJsonParser new];
	NSDictionary* jsonResponse = [parser objectWithString: [request responseString]];
	[parser release];
	NSString* urlString = [jsonResponse objectForKey: @"content_url"];

	UADownloadHistoryItem* historyItem = [root.historyController addDownload: product];
	
	//Create a unique name for the file to avoid conflicts
	NSString *tempDirectory = NSTemporaryDirectory();
	CFUUIDRef theUUID = CFUUIDCreate(NULL);
	CFStringRef string = CFUUIDCreateString(NULL, theUUID);
	CFRelease(theUUID);
	NSString *fileUID = [(NSString *)string autorelease];
	//@TODO set correct file extention
	NSString *path = [tempDirectory stringByAppendingPathComponent: [NSString stringWithFormat: @"%@.zip", fileUID]];
	[ASIHTTPRequest clearSession]; //Silly @HACK
	UAStoreFrontRequest *downloadRequest = [[UAStoreFrontRequest alloc] initWithURL: [NSURL URLWithString: urlString]];
	downloadRequest.product = product;
	[downloadRequest setDownloadDestinationPath: path];
	[downloadRequest setTransaction: request.transaction];
	[downloadRequest setDelegate: self];
	[downloadRequest setRequestMethod: @"GET"];
	[downloadRequest setDownloadProgressDelegate: historyItem];
	[downloadRequest setDidFinishSelector: @selector(downloadFinished:)];
	[networkQueue setShowAccurateProgress: YES];
	[networkQueue addOperation: downloadRequest];
}

- (void)downloadFinished:(UAStoreFrontRequest *)request {
	if (request.responseStatusCode != 200) {
		UALOG(@"Request Headers: %@", [request requestHeaders]);
		UALOG(@"Failure downloading content");
		UALOG(@"Server Response: %d, %@, %@", request.responseStatusCode, request.responseHeaders, [request responseString]);
		if(request.transaction) {
			[self failedTransaction: request.transaction];
		}
		return;
	}
	
	NSString* ext = [[request downloadDestinationPath] pathExtension];
	if([ext caseInsensitiveCompare: @"zip"] == NSOrderedSame) {
		[NSThread detachNewThreadSelector:@selector(decompressContent:) toTarget:self withObject: request];
	} else {
		//TODO: do something sane with non .zip content
		UALOG(@"Content must end with .zip extention, ignoring");
	}

	if(request.transaction) {
		[[SKPaymentQueue defaultQueue] finishTransaction: request.transaction];
	}
}

- (void)decompressContent:(UAStoreFrontRequest*)request {
	NSAutoreleasePool *pool = [[NSAutoreleasePool alloc] init];
	NSString *docsDirectory = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) objectAtIndex:0];
	NSString* path = [request downloadDestinationPath];
	ZipArchive* za = [[ZipArchive alloc] init];
	if( [za UnzipOpenFile: path] ) {
		BOOL ret = [za UnzipFileTo: [NSString stringWithFormat: @"%@/", docsDirectory] overWrite:YES];
		if( NO==ret ) {
			UALOG(@"Failed to decompress content %@", path);
		}
		[za UnzipCloseFile];
	}
	[za release];
		
	[[request downloadProgressDelegate] setProgress: kProcessingDone];
	[pool release];
}

- (void)requestFailed:(UAStoreFrontRequest *)request {
	NSError *error = [request error];
	UALOG(@"ERROR: NSError query result: %@", error);
	UALOG(@"Server Response: %d, %@", request.responseStatusCode, request.responseHeaders);
	if(request.transaction) {
		[self failedTransaction: request.transaction];
	}
}

@end