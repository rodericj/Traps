//
//  BTVenueAnnotationView.m
//  Traps
//
//  Created by Roderic Campbell on 4/11/10.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import "BTVenueAnnotationView.h"


@implementation BTVenueAnnotationView

@synthesize venueName;
@synthesize chanceOfDrop;

- (id)initWithAnnotation:(id <MKAnnotation>)annotation reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithAnnotation:annotation reuseIdentifier:reuseIdentifier];
    if (self != nil)
    {
        CGRect frame = self.frame;
        frame.size = CGSizeMake(185.0, 95.0);
        self.frame = frame;
        self.backgroundColor = [UIColor clearColor];
        self.centerOffset = CGPointMake(185/2+30, 95/2);
    }
    return self;
}

- (void)setAnnotation:(id <MKAnnotation>)annotation
{
    [super setAnnotation:annotation];
    
    // this annotation view has custom drawing code.  So when we reuse an annotation view
    // (through MapView's delegate "dequeueReusableAnnoationViewWithIdentifier" which returns non-nil)
    // we need to have it redraw the new annotation data.
    //
    // for any other custom annotation view which has just contains a simple image, this won't be needed
    //
    [self setNeedsDisplay];
}

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
	
	[[UIImage imageNamed:@"VenueAnnotation.png"] drawInRect:rect];

	// draw the strings from the Venue Details
	[[UIColor whiteColor] set];
	NSLog(@"venueName is %@", venueName);
	[venueName drawInRect:CGRectMake(15.0, 5.0, 100.0, 40.0) withFont:[UIFont systemFontOfSize:14.0]];
	[chanceOfDrop drawInRect:CGRectMake(140.0, 65.0, 50.0, 40.0) withFont:[UIFont systemFontOfSize:14.0]];

}
@end
