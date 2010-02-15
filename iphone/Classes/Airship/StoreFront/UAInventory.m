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

#import "UAInventory.h"
#import "StoreFront.h"
#import "SBJSON.h"

@implementation UAInventory

@synthesize statusDelegate;
@synthesize status;

-(void)dealloc {
	self.statusDelegate = nil;
	[super dealloc];
}	

- (UAInventory*)initWithStatusDelegate:(id)delegate {
	if (self = [super init]) {
		productList = [[NSMutableDictionary alloc] init];
		keys = [[NSMutableArray alloc] init];
		statusDelegate = delegate;
		[self fetchStoreInventory];
	}
	return self;
}

- (UAInventory*)init {
	return [self initWithStatusDelegate: nil];
}

-(NSMutableDictionary*)products {
	return productList;
}

-(void)updateKeys {
	[keys setArray: [productList allKeys]];
	NSLog(@"BEFORE %@", keys);
	[keys sortUsingSelector: @selector(compare:)];
	NSLog(@"AFTER %@", keys);
}

- (void)removeProduct:(NSString*)productId {
	[productList removeObjectForKey: productId];
	[self updateKeys];
}

- (UAProduct*)productWithIdentifier:(NSString*)productId {
	return [productList objectForKey: productId];
}

- (void)addProduct:(UAProduct*)product {
	[productList setObject: product forKey: product.productIdentifier];
	[self updateKeys];
}

- (int)count {
	return [keys count];
}

- (UAProduct*)productAtIndex:(int)index {
	return [productList objectForKey: [keys objectAtIndex: index]];
}

+(NSString*)localizedPrice:(SKProduct*)product {
	NSNumberFormatter *numberFormatter = [[NSNumberFormatter alloc] init];
	[numberFormatter setFormatterBehavior: NSNumberFormatterBehavior10_4];
	[numberFormatter setNumberStyle: NSNumberFormatterCurrencyStyle];
	[numberFormatter setLocale: product.priceLocale];
	NSString *formattedString = [numberFormatter stringFromNumber: product.price];
	[numberFormatter release];
	return formattedString;
}

#pragma mark -

-(void)fetchStoreInventory {
	[statusDelegate updateInventoryStatus: UAInventoryStatusDownloading];
	NSString *urlString = [NSString stringWithFormat: @"%@%@", [[Airship shared] server], @"/api/app/content/"];
	NSURL *url = [NSURL URLWithString: urlString];
	ASIHTTPRequest *request = [[[ASIHTTPRequest alloc] initWithURL:url] autorelease];
	request.username = [[Airship shared] appId];
	request.password = [[Airship shared] appSecret];
	
	[request setDelegate:self];
	[request setDidFinishSelector: @selector(inventoryReady:)];
	[request setDidFailSelector: @selector(requestWentWrong:)];

	[request startAsynchronous];
}


-(void)inventoryReady:(ASIHTTPRequest *)request {
	UALOG([request responseString]);
	
	SBJsonParser *parser = [SBJsonParser new];
	NSArray* tmpInv = [parser objectWithString: [request responseString]];
	[parser release];
	NSMutableSet* productIdentifiers = [[NSMutableSet alloc] initWithCapacity: 3];
	for(NSDictionary *item in tmpInv) {
		NSString* productIdentifier = [item objectForKey: @"product_id"];
		[productIdentifiers addObject: productIdentifier];
		UAProduct* product = [[UAProduct alloc] init];
		product.productIdentifier = productIdentifier;
		product.previewURL = [NSURL URLWithString: [item objectForKey: @"preview_url"]];
		product.downloadURL = [NSURL URLWithString: [item objectForKey: @"download_url"]];
		product.iconURL = [NSURL URLWithString: [item objectForKey: @"icon_url"]];		
		product.title = [item objectForKey: @"name"];
		product.isFree = NO;
		if([item objectForKey: @"free"] != [NSNull null] && [[item objectForKey: @"free"] intValue] != 0) {
			product.isFree = YES;
			product.description = [item objectForKey: @"description"];
			product.price = @"FREE";
		}
		
		product.revision = [[item objectForKey: @"current_revision"] intValue];
		[self addProduct: product];
		[product release];
	}
	[statusDelegate updateInventoryStatus: UAInventoryStatusApple];
	SKProductsRequest *skrequest= [[SKProductsRequest alloc] initWithProductIdentifiers: productIdentifiers];
	[productIdentifiers release];
	skrequest.delegate = self;
	
	[skrequest start];
}

- (void)requestWentWrong:(ASIHTTPRequest *)request {
	NSError *error = [request error];
	UALOG(@"Connection ERROR: NSError query result: %@", error);
	[statusDelegate updateInventoryStatus: UAInventoryStatusFailed];
}

#pragma mark -
#pragma mark SKProductsRequestDelegate

- (void)productsRequest:(SKProductsRequest *)request didReceiveResponse:(SKProductsResponse *)response { 
	UAProduct *uaitem = nil;
	for(SKProduct *skitem in response.products) {
		uaitem = [[self products] objectForKey: skitem.productIdentifier];
		if(uaitem != nil && uaitem.isFree != YES) {
			uaitem.title = [skitem localizedTitle];
			uaitem.description = [skitem localizedDescription];
			NSString* localizedPrice = [UAInventory localizedPrice: skitem];
			uaitem.price = localizedPrice;
		}
	}
	
	for(NSString *invalid in response.invalidProductIdentifiers) {
		
		UAProduct* product = [self productWithIdentifier: invalid];
		if(!product.isFree) {
			UALOG(@"INVALID PRODUCT ID: %@", invalid);
			[self removeProduct: invalid];
		}
	}
	
	[statusDelegate updateInventoryStatus: UAInventoryStatusFinished];
	
	//@TODO: Remove this
	StoreFront* sf = [StoreFront shared];
	UAStoreTabBarController* root = (UAStoreTabBarController*)sf.rootViewController;
	[root.updatesController checkForUpdates];
	
	// Wait until inventory is loaded to add an observer
	[[SKPaymentQueue defaultQueue] addTransactionObserver: sf.sfObserver];
}




@end
