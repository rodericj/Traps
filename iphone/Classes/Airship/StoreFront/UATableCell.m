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

#import "UATableCell.h"
#import "UAGlobal.h"

@implementation UATableCell

@synthesize isOdd;

-(void)dealloc {
	[super dealloc];
}	


- (id)initWithFrame:(CGRect)frame reuseIdentifier:(NSString *)reuseIdentifier {
    if (self = [super initWithFrame:frame reuseIdentifier:reuseIdentifier]) {
        self.isOdd = NO;
    }
    return self;
}

- (void)drawRect:(CGRect)rect {
	[super drawRect:rect];
	CGContextRef context = UIGraphicsGetCurrentContext(); 

	//Background
	CGRect drawRect = CGRectMake(rect.origin.x, rect.origin.y,
								 rect.size.width, rect.size.height);

	if(self.isOdd) {
		BG_RGBA(152.0f, 152.0f, 156.0f, 1.0f);
	} else {
		BG_RGBA(173.0f, 173.0f, 176.0f, 1.0f);
	}
	CGContextFillRect(context, drawRect);

	//Highlight
	BG_RGBA(187.0f, 187.0f, 189.f, 1.0f);
	CGRect highlight = CGRectMake(rect.origin.x, rect.origin.y,
								  rect.size.width , rect.origin.y+1);
	CGContextFillRect(context, highlight);
	
	//Lowlight
	BG_RGBA(137.0f, 138.0f, 141.0f, 1.0f);
	CGRect lowlight = CGRectMake(rect.origin.x, rect.size.height-1 ,
								 rect.size.width , rect.size.height);
	CGContextFillRect(context, lowlight);
}

@end
