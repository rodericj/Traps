//
//  BTNetworkHttp.h
//  Traps
//
//  Created by Roderic Campbell on 3/14/10.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>

#import "BTConstants.h"

extern NSString *const kHTTPRequestError;

#define kNetworkHTTPRunMode	@"com.thetrapgame.http.RunMode"

@interface BTNetworkHttp : NSObject {
@private 
	BOOL _finished;
	
	id _responseObject;
	NSString *_responseMethodSignature;
	
	NSMutableData	*_data;
}

// Initialization
+ (id)networkHttpWithResponseObject:(id)responseObject methodSignature:(NSString *)methodSignature;
- (id)initWithResponseObject:(id)responseObject methodSignature:(NSString *)methodSignature;

// Network
- (void)performHTTPRequestWithMethod:(NSString *)method
						 relativeURL:(NSString *)relativeURL
							  params:(NSDictionary *)params;

@end
