//
//  BTNetwork.h
//  Traps
//
//  Created by Roderic Campbell on 3/14/10.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>

#import "BTConstants.h"

@interface BTNetwork : NSObject {
	// one-off http operations
	NSOperationQueue *httpOperationQueue;
}

// Singleton
+ (id) sharedNetwork;

// Network
- (oneway void)performHttpOperationWithResponseObject:(id)responseObject
									  methodSignature:(NSString *)methodSignature
											   method:(NSString *)method
											   domain:(NSString *)domain
										  relativeURL:(NSString *)relativeURL
											   params:(NSDictionary *)params;

@end
