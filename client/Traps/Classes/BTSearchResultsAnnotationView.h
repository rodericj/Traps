//
//  BTSearchResultsAnnotationView.h
//  Traps
//
//  Created by Roderic Campbell on 4/11/10.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "BTVenueAnnotationView.h"

@interface BTSearchResultsAnnotationView : BTVenueAnnotationView {
	NSString *resultsString;
}

@property (nonatomic, retain) NSString *resultsString;
@end
