//
//  NetworkRequestOperation.h
//  BoobyTrap3
//
//  Created by Roderic Campbell on 11/25/09.
//  Copyright 2009 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>


@interface NetworkRequestOperation : NSOperation {
	NSURL *targetURL;
	NSMutableDictionary *arguments;
	NSObject *callingDelegate;
}
@property(retain) NSURL *targetURL;
@property(retain) NSDictionary *arguments;
@property(retain) NSObject *callingDelegate;

@end
