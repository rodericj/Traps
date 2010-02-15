/*
Copyright 2009 Urban Airship Inc. All rights reserved.

Redistribution and use in source and binary forms, with or without
modification, are permitted provided that the following conditions are met:

1. Redistributions of source code must retain the above copyright notice, this
list of conditions and the following disclaimer.

2. Redistributions in binaryform must reproduce the above copyright notice,
this list of conditions and the following disclaimer in the documentation 
and/or other materials provided withthe distribution.

THIS SOFTWARE IS PROVIDED BY THE URBAN AIRSHIP INC``AS IS'' AND ANY EXPRESS OR
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

#import "Airship.h"
#import "UAGlobal.h"
#import "ASIHTTPRequest.h"

#define kAirshipProductionServer @"https://go.urbanairship.com"
#define kAirshipStagingServer @"https://sgc.urbanairship.com"

static Airship *_sharedAirship;

@implementation Airship

@synthesize server;
@synthesize appId;
@synthesize appSecret;

-(void)dealloc {
	RELEASE_SAFELY(appId);
	RELEASE_SAFELY(appSecret);
	RELEASE_SAFELY(server);
	[super dealloc];
}	

-(id)initWithId:(NSString *)appkey identifiedBy:(NSString *)secret {
    if (self = [super init]) {
		self.appId = appkey;
		self.appSecret = secret;
    }
    return self;
}

+(void)takeOff:(NSString *)appid identifiedBy:(NSString *)secret {
	if(!_sharedAirship) {
#ifdef staging
		_sharedAirship = [[Airship alloc] initWithId: @"PTxkCRX6TUy5ae4uO6BxGg"
										identifiedBy: @"LpzvaNKNQLW9e0W6io0skQ"];
		_sharedAirship.server = kAirshipStagingServer;
		UALOG(@"Running Staging test build - UA INTERNAL TESTING ONLY - If you are"
			  " trying the staging build it will probably not work as expected");
#else
		if([appid isEqual: @"YOUR_APP_KEY"] || [secret isEqual: @"YOUR_APP_SECRET"]) {
			NSString* errorMessage = @"Application KEY and/or SECRET not set, please"
			" insert your application key from http://go.urbanairship.com into"
			" the Airship initialization located in your App Delegate's"
			" didFinishLaunching method";
			UIAlertView *someError = [[UIAlertView alloc] initWithTitle: @"Ooopsie"
																message: errorMessage
															   delegate: self 
													  cancelButtonTitle: @"Ok"
													  otherButtonTitles: nil];
			
			[someError show];
			[someError release];
		}
		
		_sharedAirship = [[Airship alloc] initWithId: appid identifiedBy: secret];
		_sharedAirship.server = kAirshipProductionServer;
#endif
		UALOG(@"%@", _sharedAirship.server);
	}
}

+(void)land {
	[_sharedAirship release];
	_sharedAirship = nil;
	
	id storeFront = NSClassFromString(@"StoreFront");
	[[storeFront shared] cleanup];
}

+(Airship *)shared {
	return _sharedAirship;
}

// Apple Remote Push Notifications
-(void)registerDeviceToken:(NSData *)token {
	[self registerDeviceToken: token withAlias: nil];
}

-(void)registerDeviceToken:(NSData *)token withAlias:(NSString *)alias {
	deviceToken = [[[[token description] stringByReplacingOccurrencesOfString:@"<"withString:@""] 
						 stringByReplacingOccurrencesOfString:@">" withString:@""] 
						stringByReplacingOccurrencesOfString: @" " withString: @""];
			
	// We like to use ASIHttpRequest classes, but you can make this register call how ever you like
	// just notice that it's an http PUT
	NSString *urlString = [NSString stringWithFormat:@"%@%@%@/", self.server, @"/api/device_tokens/", deviceToken];
	NSURL *url = [NSURL URLWithString:  urlString];
	ASIHTTPRequest *request = [[[ASIHTTPRequest alloc] initWithURL:url] autorelease];
	request.requestMethod = @"PUT";
	
	if(alias != nil) {
		// Send along our device alias as the JSON encoded request body
		[request addRequestHeader: @"Content-Type" value: @"application/json"];
		[request appendPostData:[[NSString stringWithFormat: @"{\"alias\": \"%@\"}", deviceAlias]
							 dataUsingEncoding:NSUTF8StringEncoding]];
	}
	
	// Authenticate to the server
	request.username = self.appId;
	request.password = self.appSecret;
	
	[request setDelegate:self];
	[request setDidFailSelector: @selector(tokenRegistrationFail:)];
	[request startAsynchronous];
}

- (void)tokenRegistrationFail:(ASIHTTPRequest *)request {
	NSError *error = [request error];
	UALOG(@"ERROR registering device token: %@", error);
}

- (void)displayStoreFront {
	id storeFront = NSClassFromString(@"StoreFront");
	NSAssert(storeFront != nil,@"Could not find StoreFront class to initialize");
	[storeFront displayStoreFront];
}

- (void)quitStoreFront {
	id storeFront = NSClassFromString(@"StoreFront");
	NSAssert(storeFront != nil,@"Could not find StoreFront class");
	[storeFront quitStoreFront];
}

@end
