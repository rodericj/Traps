//
//  BTSearchResultsAnnotationView.m
//  Traps
//
//  Created by Roderic Campbell on 4/11/10.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import "BTSearchResultsAnnotationView.h"


@implementation BTSearchResultsAnnotationView

@synthesize resultsString;

-(void) drawRect:(CGRect) rect{
	
	CGContextRef context = UIGraphicsGetCurrentContext();
	CGContextSetLineWidth(context, 1);
	
	
	// draw the gray pointed shape:
	CGMutablePathRef path = CGPathCreateMutable();
	CGPathMoveToPoint(path, NULL, 14.0, 0.0);
	CGPathAddLineToPoint(path, NULL, 0.0, 0.0); 
	CGPathAddLineToPoint(path, NULL, 55.0, 50.0); 
	CGContextAddPath(context, path);
	CGContextSetFillColorWithColor(context, [UIColor lightGrayColor].CGColor);
	CGContextSetStrokeColorWithColor(context, [UIColor grayColor].CGColor);
	CGContextDrawPath(context, kCGPathFillStroke);
	CGPathRelease(path);
	
	[[UIImage imageNamed:@"SearchResultsAnnotation.png"] drawInRect:rect];
	NSLog(@"the results string is %@", resultsString);
	// draw the strings from the Venue Details
	[[UIColor whiteColor] set];
	[resultsString drawInRect:CGRectMake(10.0, 20.0, 125.0, 80.0) withFont:[UIFont systemFontOfSize:12.0]];
	//[chanceOfDrop drawInRect:CGRectMake(140.0, 65.0, 50.0, 40.0) withFont:[UIFont systemFontOfSize:14.0]];
	
}

@end
