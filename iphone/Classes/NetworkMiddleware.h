//
//  NetworkMiddleware.h
//  BoobyTrap3
//
//  Created by Roderic Campbell on 11/2/09.
//  Copyright 2009 Slide. All rights reserved.
//

#import <Foundation/Foundation.h>


@interface NetworkMiddleware : NSObject {
	NSString *viewName;
	NSString *postData;
	
}
@property (nonatomic, retain) NSString *viewName;
@property (nonatomic, retain) NSString *postData;
-(NSData *) makeRequest; 

@end
