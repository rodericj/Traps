//
//  BTSearchResultsAnnotationView.m
//  Traps
//
//  Created by Roderic Campbell on 4/11/10.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import "BTSearchResultsAnnotationView.h"
#import "BTConstants.h"


@implementation BTSearchResultsAnnotationView

@synthesize resultsString;

-(void) drawRect:(CGRect) rect{
	
	CGContextRef context = UIGraphicsGetCurrentContext();
	CGContextSetLineWidth(context, 1);
	
	[[UIImage imageNamed:@"mapannotation.png"] drawInRect:rect];
	NSLog(@"the results string is %@", resultsString);
	// draw the strings from the Venue Details
	[[UIColor whiteColor] set];
	[resultsString drawInRect:CGRectMake(annotationxcoord, annotationycoord, 125.0, 80.0) withFont:[UIFont systemFontOfSize:12.0]];
	[[UIImage imageNamed:dudeIcon] drawInRect:CGRectMake(guyorigxcoord, guyorigycoord, guywidth, guyheight)];

}

@end
