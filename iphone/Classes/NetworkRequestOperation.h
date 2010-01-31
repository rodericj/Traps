//
//  NetworkRequestOperation.h
//  BoobyTrap3
//
//  Created by Roderic Campbell on 11/25/09.
//  Copyright 2009 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>


@interface NetworkRequestOperation : NSOperation {
	NSString *targetURL;
	NSMutableDictionary *arguments;
	NSObject *callingDelegate;
}
@property(retain) NSString *targetURL;
@property(retain) NSMutableDictionary *arguments;
@property(retain) NSObject *callingDelegate;

@end
