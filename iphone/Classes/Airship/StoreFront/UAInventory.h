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

#import <Foundation/Foundation.h>
#import <StoreKit/StoreKit.h>

#import "Airship.h"
#import "UAProduct.h"

#import "ASIHTTPRequest.h"
#import "ASINetworkQueue.h"

typedef enum {
	UAInventoryStatusDownloading,
	UAInventoryStatusApple,
	UAInventoryStatusFinished,
	UAInventoryStatusFailed
}  UAInventoryStatus;

@protocol UAInventoryStatusDelegate

-(void)updateInventoryStatus:(UAInventoryStatus)status;

@end

@interface UAInventory : NSObject<SKProductsRequestDelegate> {
	NSMutableDictionary* productList;
	NSMutableArray* keys;
	id<UAInventoryStatusDelegate> statusDelegate;
	ASINetworkQueue* networkQueue;
	UAInventoryStatus status;
}

@property (assign) UAInventoryStatus status;
@property (assign) id statusDelegate;

- (UAInventory*)init;
- (UAInventory*)initWithStatusDelegate:(id)delegate;

- (void)fetchStoreInventory;
- (void)inventoryReady:(ASIHTTPRequest*)request;

- (UAProduct*)productWithIdentifier:(NSString*)productId;
- (UAProduct*)productAtIndex:(int)index;

- (void)addProduct:(UAProduct*)product;
- (void)removeProduct:(NSString*)productId;
- (NSMutableDictionary*)products;
- (int)count;
- (void)updateKeys;

@end