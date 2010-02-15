/*
Copyright 2009 Urban Airship Inc. All rights reserved.

Redistribution and use in source and binary forms, with or without
modification, are permitted provided that the following conditions are met:

1. Redistributions of source code must retain the above copyright notice, this
list of conditions and the following disclaimer.

2. Redistributions in binaryform must reproduce the above copyright notice,
this list of conditions and the following disclaimer in the documentation 
and/or other materials provided withthe distribution.

THIS SOFTWARE IS PROVIDED BY THE URBAN AIRSHIP INC ``AS IS'' AND ANY EXPRESS OR
IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED WARRANTIES OF
MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE DISCLAIMED. IN NO
EVENT SHALL URBAN AIRSHIP INC OR CONTRIBUTORS BE LIABLE FOR ANY DIRECT,
INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES (INCLUDING,
BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES; LOSS OF USE,
DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY OF
LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT (INCLUDING NEGLIGENCE
OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS SOFTWARE, EVEN IF
ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
*/
#import <StoreKit/StoreKit.h>
#import "QuartzCore/QuartzCore.h" // for CALayer

#import "Airship.h"
#import "StoreFront.h"
#import "UAGlobal.h"
#import "UAProductDetailViewController.h"
#import "UAAsycImageView.h"
#import "UAStoreTabBarController.h"


#define kCellPaddingHeight 30

@implementation UAProductDetailViewController

@synthesize product;
@synthesize productTitle;
@synthesize iconContainer;
@synthesize purchaseButton;
@synthesize revision;
@synthesize reflection;
@synthesize navController;

- (void)dealloc {
	RELEASE_SAFELY(product);
	RELEASE_SAFELY(productTitle);
	RELEASE_SAFELY(iconContainer);
	RELEASE_SAFELY(purchaseButton);
	RELEASE_SAFELY(revision);
	RELEASE_SAFELY(reflection);
	RELEASE_SAFELY(navController);
    [super dealloc];
}

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil {
    if (self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil]) {
		self.title = @"Details";
    }
    return self;
}

-(void) loadReflection:(id)sender {
	reflection.image =  [self reflectedImage: sender withHeight: 15];
}

- (void)viewDidLoad {
    [super viewDidLoad];
	self.productTitle.text = product.title;

	CGRect frame;
	frame.size.width=57; frame.size.height=57;
	frame.origin.x=0; frame.origin.y=0;
	UAAsyncImageView* asyncImage = [[[UAAsyncImageView alloc]
									 initWithFrame:frame] autorelease];
	[asyncImage loadImageFromURL: self.product.iconURL withRoundedEdges: YES];	
	[iconContainer addSubview: asyncImage];
	asyncImage.target = self;
	asyncImage.onReady = @selector(loadReflection:);
	
	revision.text = [NSString stringWithFormat: @"%d", product.revision];
	[purchaseButton setTitle: product.price forState: UIControlStateNormal];
	[purchaseButton setTitle: product.price forState: UIControlStateApplication];
	[purchaseButton setTitle: product.price forState: UIControlStateHighlighted];
	[purchaseButton setTitle: product.price forState: UIControlStateReserved];
	[purchaseButton setTitle: product.price forState: UIControlStateSelected];
	[purchaseButton setTitle: product.price forState: UIControlStateDisabled];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

- (void)viewDidUnload {
	self.productTitle = nil;
	self.iconContainer = nil;
	self.purchaseButton = nil;
	self.revision = nil;
	self.reflection = nil;
}

-(IBAction)purchase:(id)sender {
	StoreFront* sf = [StoreFront shared];
	
	if(product.isFree == YES) {
		[sf.sfObserver verifyReceipt: product];
	} else {
		SKPayment *payment = [SKPayment 
						paymentWithProductIdentifier: product.productIdentifier]; 
		[[SKPaymentQueue defaultQueue] addPayment: payment];
	}
	[navController popViewControllerAnimated: NO];
	[sf.rootViewController setSelectedViewController: [sf.rootViewController.historyController navController]];
}


CGImageRef CreateGradientImage(int pixelsWide, int pixelsHigh)
{
	CGImageRef theCGImage = NULL;
	
	// gradient is always black-white and the mask must be in the gray colorspace
    CGColorSpaceRef colorSpace = CGColorSpaceCreateDeviceGray();
	
	// create the bitmap context
	CGContextRef gradientBitmapContext = CGBitmapContextCreate(nil, pixelsWide, pixelsHigh,
															   8, 0, colorSpace, kCGImageAlphaNone);
	
	// define the start and end grayscale values (with the alpha, even though
	// our bitmap context doesn't support alpha the gradient requires it)
	CGFloat colors[] = {0.0, 1.0, 1.0, 1.0};
	
	// create the CGGradient and then release the gray color space
	CGGradientRef grayScaleGradient = CGGradientCreateWithColorComponents(colorSpace, colors, NULL, 2);
	CGColorSpaceRelease(colorSpace);
	
	// create the start and end points for the gradient vector (straight down)
	CGPoint gradientStartPoint = CGPointZero;
	CGPoint gradientEndPoint = CGPointMake(0, pixelsHigh);
	
	// draw the gradient into the gray bitmap context
	CGContextDrawLinearGradient(gradientBitmapContext, grayScaleGradient, gradientStartPoint,
								gradientEndPoint, kCGGradientDrawsAfterEndLocation);
	
	// convert the context into a CGImageRef and release the context
	theCGImage = CGBitmapContextCreateImage(gradientBitmapContext);
	CGContextRelease(gradientBitmapContext);
	
	// return the imageref containing the gradient
    return theCGImage;
}

CGContextRef MyCreateBitmapContext(int pixelsWide, int pixelsHigh)
{
    CGColorSpaceRef colorSpace = CGColorSpaceCreateDeviceRGB();
	
	// create the bitmap context
	CGContextRef bitmapContext = CGBitmapContextCreate (nil, pixelsWide, pixelsHigh, 8,
														0, colorSpace,
														// this will give us an optimal BGRA format for the device:
														(kCGBitmapByteOrder32Little | kCGImageAlphaPremultipliedFirst));
	CGColorSpaceRelease(colorSpace);
	
    return bitmapContext;
}

// reflected image code from Apple samples
- (UIImage *)reflectedImage:(UIImageView *)fromImage withHeight:(NSUInteger)height
{
    if (!height) return nil;
    
	// create a bitmap graphics context the size of the image
	CGContextRef mainViewContentContext = MyCreateBitmapContext(fromImage.bounds.size.width, height);
	
	// offset the context -
	// This is necessary because, by default, the layer created by a view for caching its content is flipped.
	// But when you actually access the layer content and have it rendered it is inverted.  Since we're only creating
	// a context the size of our reflection view (a fraction of the size of the main view) we have to translate the
	// context the delta in size, and render it.
	//
	CGFloat translateVertical= fromImage.bounds.size.height - height;
	CGContextTranslateCTM(mainViewContentContext, 0, -translateVertical);
	
	// render the layer into the bitmap context
	CALayer *layer = fromImage.layer;
	[layer renderInContext:mainViewContentContext];
	
	// create CGImageRef of the main view bitmap content, and then release that bitmap context
	CGImageRef mainViewContentBitmapContext = CGBitmapContextCreateImage(mainViewContentContext);
	CGContextRelease(mainViewContentContext);
	
	// create a 2 bit CGImage containing a gradient that will be used for masking the 
	// main view content to create the 'fade' of the reflection.  The CGImageCreateWithMask
	// function will stretch the bitmap image as required, so we can create a 1 pixel wide gradient
	CGImageRef gradientMaskImage = CreateGradientImage(1, height);
	
	// create an image by masking the bitmap of the mainView content with the gradient view
	// then release the  pre-masked content bitmap and the gradient bitmap
	CGImageRef reflectionImage = CGImageCreateWithMask(mainViewContentBitmapContext, gradientMaskImage);
	CGImageRelease(mainViewContentBitmapContext);
	CGImageRelease(gradientMaskImage);
	
	// convert the finished reflection image to a UIImage 
	UIImage *theImage = [UIImage imageWithCGImage:reflectionImage];
	
	// image is retained by the property setting above, so we can release the original
	CGImageRelease(reflectionImage);
	
	return theImage;
}


#pragma mark -
#pragma mark UITableViewDelegate

- (CGFloat) tableView: (UITableView *) tableView heightForRowAtIndexPath: (NSIndexPath *) indexPath {
	if([indexPath row] == 0) {
		UIFont *font = [UIFont systemFontOfSize: 16];
		NSString* text = product.description;
		CGFloat height = [text sizeWithFont: font
						  constrainedToSize: CGSizeMake(300.0, 1500.0)
							  lineBreakMode: UILineBreakModeWordWrap].height;
		return height + kCellPaddingHeight;
	}

	return 240 + kCellPaddingHeight;
}

#pragma mark -
#pragma mark UITableViewDataSource

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
	UIColor *backgroundColor = RGBA(200.0f, 202.0f, 204.0f, 0.0f); //transparent
	UITableViewCell* cell;
	if([indexPath row]) {
		cell = [[UITableViewCell alloc] initWithStyle: UITableViewCellStyleDefault reuseIdentifier: @"preview-cell"];
		if (product.previewURL != nil && product.preview == nil) {
			//@TODO display preview image properly
//			NSData *data = [NSData dataWithContentsOfURL: product.previewURL];
//			UIImage *img = [[UIImage alloc] initWithData:data];
//			product.preview = img;
//			[img release];
		}
		UIImageView* previewImage = [[UIImageView alloc] initWithImage: product.preview];
		[cell addSubview: previewImage];
	} else {
		NSString* text = product.description;
		UIFont *font = [UIFont systemFontOfSize: 16];
		
		UILabel* description = [[UILabel alloc] init];
		description.text = text;
		description.lineBreakMode = UILineBreakModeWordWrap;
		description.numberOfLines = 0;
		description.backgroundColor = backgroundColor;
		[description setFont: font];
		CGFloat height = [text sizeWithFont: font
						  constrainedToSize: CGSizeMake(300.0, 1500.0)
							  lineBreakMode: UILineBreakModeWordWrap].height;
		[description setFrame: CGRectMake(0.0f, 0.0f, 320.0f, height)];
		[description setBounds: CGRectMake(0.10f, 0.0f, 300.0f, height)]; 
		cell = [[UITableViewCell alloc] initWithStyle: UITableViewCellStyleDefault reuseIdentifier: @"description-cell"];
		[cell addSubview: description];
	}
	[cell setSelectionStyle: UITableViewCellSelectionStyleNone];
	cell.backgroundColor = backgroundColor;
	return cell;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
	return 2;
}


@end
