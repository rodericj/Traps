//
//  BTVenueAnnotationView.m
//  Traps
//
//  Created by Roderic Campbell on 4/11/10.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import "BTVenueAnnotationView.h"
#import "BTConstants.h"


@implementation BTVenueAnnotationView

@synthesize venueName;
@synthesize chanceOfDrop;
@synthesize dudeIcon;

- (id)initWithAnnotation:(id <MKAnnotation>)annotation reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithAnnotation:annotation reuseIdentifier:reuseIdentifier];
    if (self != nil)
    {
        CGRect frame = self.frame;
        frame.size = CGSizeMake(185.0, 95.0);
        self.frame = frame;
        self.backgroundColor = [UIColor clearColor];
        self.centerOffset = CGPointMake(0, -45);
    }
    return self;
}

- (void)setAnnotation:(id <MKAnnotation>)annotation
{
    [super setAnnotation:annotation];
    [self setNeedsDisplay];
}

-(void) drawRect:(CGRect) rect{
	
	CGContextRef context = UIGraphicsGetCurrentContext();
	CGContextSetLineWidth(context, 1);
	
	[[UIImage imageNamed:@"mapannotation.png"] drawInRect:rect];

	// draw the strings from the Venue Details
	[[UIColor whiteColor] set];
	NSLog(@"venueName is %@", venueName);
	[venueName drawInRect:CGRectMake(annotationxcoord, annotationxcoord, 100.0, 40.0) withFont:[UIFont systemFontOfSize:14.0]];
	[chanceOfDrop drawInRect:CGRectMake(120.0, chanceofdropycoord, 50.0, 40.0) withFont:[UIFont systemFontOfSize:14.0]];
	
	NSString *chanceOfDropLabel = @"Chance of drop";
	[chanceOfDropLabel drawInRect:CGRectMake(annotationxcoord, chanceofdropycoord, 130, 40) withFont:[UIFont systemFontOfSize:14]];
	[[UIImage imageNamed:dudeIcon] drawInRect:CGRectMake(guyorigxcoord, guyorigycoord, guywidth, guyheight)];

}
@end
