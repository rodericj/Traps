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

#import "UADownloadHistoryItem.h"
#import "UADownloadHistoryViewController.h"
#import "StoreFront.h"
#import "UAGlobal.h"


/* 
 * Simple model that is a combination of some product meta data, a timestamp
 * and a progress delegate
 */
@implementation UADownloadHistoryItem

@synthesize title;
@synthesize progressDelegate;
@synthesize iconURL;
@synthesize order;
@synthesize dateDisplay;
@synthesize productIdentifier;
@synthesize finished;

-(void)dealloc {
	RELEASE_SAFELY(title);
	self.progressDelegate = nil;
	RELEASE_SAFELY(iconURL);
	RELEASE_SAFELY(order);
	RELEASE_SAFELY(dateDisplay);
	RELEASE_SAFELY(productIdentifier);
	[super dealloc];
}

-(void)initDateFields {
	NSDate *now = [[NSDate alloc] init];
	NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
	
	[formatter setDateFormat:  @"yyyyMMddHHmmssAA"];
	self.order = [formatter stringFromDate: now];
	
	[formatter setDateFormat: @"yyyy-MM-dd HH:mm:ss"];
	self.dateDisplay = [formatter stringFromDate: now];
	
	[formatter release];
	[now release];	
}

-(id)initWithProduct: (UAProduct*)product {
	if (self = [super init]) {
		[self initDateFields];
		self.iconURL = product.iconURL;
		self.title = product.title;
		self.productIdentifier = product.productIdentifier;
		self.finished = NO;
	}
	return self;
}

-(id)initWithDict: (NSDictionary*)dict {
	if (self = [super init]) {
		self.title = [dict objectForKey: @"title"];
		self.iconURL = [NSURL URLWithString: [dict objectForKey: @"icon_url"]];
		self.dateDisplay = [dict objectForKey: @"date_display"];
		self.order = [dict objectForKey: @"order"];
		self.productIdentifier = [dict objectForKey: @"product_identifier"];
		self.finished = YES;
	}
	return self;
}

-(NSDictionary*)toDict {
	NSMutableDictionary* dict = [[NSMutableDictionary alloc] init];
	[dict setObject: self.title forKey: @"title"];
	[dict setObject: [self.iconURL absoluteString] forKey: @"icon_url"];
	[dict setObject: self.dateDisplay forKey: @"date_display"];
	[dict setObject: self.order forKey: @"order"];
	[dict setObject: self.productIdentifier forKey: @"product_identifier"];
	return dict;
}

-(id)init {
	if (self = [super init]) {
		[self initDateFields];
    }
    return self;
}

-(void)setProgress:(float)progress {
	if([progressDelegate respondsToSelector: @selector( setProgress: )] == YES) {
		[progressDelegate setProgress: progress];
	}
	if(progress >= kProcessingDone) {
		self.finished = YES;
	}
	
	UADownloadHistoryViewController* historyController = [[StoreFront shared].rootViewController historyController];
	[historyController saveToDisk];
}

@end
