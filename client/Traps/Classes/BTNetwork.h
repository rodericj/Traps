//
//  BTNetwork.h
//  Traps
//
//  Created by Roderic Campbell on 3/14/10.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>


@interface BTNetwork : NSObject {
	NSOperationQueue *httpOperationQueue;
}

+ (id) sharedBTNetwork;
@end
