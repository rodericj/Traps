//
//  BoobyTrap3AppDelegate.m
//  BoobyTrap3
//
//  Created by Roderic Campbell on 10/11/09.
//  Copyright Slide 2009. All rights reserved.
//

#import "BoobyTrap3AppDelegate.h"
#import "HomeNavController.h"
#import "DropTrapsNavController.h"
#import "NetworkRequestOperation.h"

@implementation BoobyTrap3AppDelegate

@synthesize dropTrapsNavController;
@synthesize window;
@synthesize rootController;
@synthesize homeNavController;
@synthesize session;
@synthesize serverAddress;
@synthesize deviceToken;

- (void)applicationDidFinishLaunching:(UIApplication *)application {  
	
	if(
	   getenv("NSZombieEnabled") || getenv("NSAutoreleaseFreedObjectCheckEnabled")
	   ) {
		NSLog(@"NSZombieEnabled/NSAutoreleaseFreedObjectCheckEnabled enabled!");
	}
	
	[self setServerAddress:REMOTE_SERVER];

	//Register for notifications
	//This will send an asynchronous call to 
	NSLog(@"setting up for APNS by contacting them");
	[[UIApplication sharedApplication]
	 registerForRemoteNotificationTypes:(UIRemoteNotificationTypeBadge |
										 UIRemoteNotificationTypeSound |
										 UIRemoteNotificationTypeAlert)];
	NSLog(@"done sending request");
	
	[window addSubview:rootController.view];
	[window makeKeyAndVisible];
}

- (void)application:(UIApplication *)application didRegisterForRemoteNotificationsWithDeviceToken:(NSData *)_deviceToken {
	NSLog(@"we did register for remote notifications %@", _deviceToken);
	// Get a hex string from the device token with no spaces or < >
	self.deviceToken = [[[[_deviceToken description] stringByReplacingOccurrencesOfString:@"<"withString:@""] 
						 stringByReplacingOccurrencesOfString:@">" withString:@""] 
						stringByReplacingOccurrencesOfString: @" " withString: @""];
	
	//Set the device token to the userDefaults. If it's already set we don't need to notify the home base
	NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
	
	NSString *storedToken = [userDefaults stringForKey: @"deviceToken"]; 
	if ([storedToken isEqualToString:self.deviceToken] != TRUE) {		
		//It doesn't exist, so set it and kick off the network process and store the deviceToken
		NetworkRequestOperation *op = [[NetworkRequestOperation alloc] init];
		[op setTargetURL:@"SetDeviceToken"];
		op.arguments = [[NSMutableDictionary alloc] init];
		[op.arguments setObject:(NSString *) self.deviceToken forKey:@"deviceToken"];
		
		op.callingDelegate = self;
		queue = [[NSOperationQueue alloc] init];
		[queue addOperation:op];
		[op release];
		
		[userDefaults setObject:self.deviceToken forKey:@"deviceToken"];
		
	}

}

- (NSDictionary *)parseQueryString:(NSString *)query {
    NSMutableDictionary *dict = [[[NSMutableDictionary alloc] initWithCapacity:6] autorelease];
    NSArray *pairs = [query componentsSeparatedByString:@"&"];
    
    for (NSString *pair in pairs) {
        NSArray *elements = [pair componentsSeparatedByString:@"="];
        NSString *key = [[elements objectAtIndex:0] stringByReplacingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
        NSString *val = [[elements objectAtIndex:1] stringByReplacingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
        
        [dict setObject:val forKey:key];
    }
    return dict;
}


- (BOOL)application:(UIApplication *)application handleOpenURL:(NSURL *)url {
    NSLog(@"handle url recieved: %@", url);
    NSLog(@"handle query string: %@", [url query]);
    NSLog(@"handle host: %@", [url host]);
    NSLog(@"handle url path: %@", [url path]);
    NSDictionary *dict = [self parseQueryString:[url query]];
    NSLog(@"handle query dict: %@", dict);
    return YES;
	

}


- (void)pageLoaded:(NSDictionary*)webRequestResults{
	NSLog(@"call to SetDeviceToken Returned %@", webRequestResults);
}

- (void)application:(UIApplication *)application didFailToRegisterForRemoteNotificationsWithError:(NSError *) error {
	NSLog(@"Failed to register APN with error: %@", error);
}

- (void)dealloc {
    [window release];
	[rootController release];
	[dropTrapsNavController release];
	[homeNavController release];
    [super dealloc];
}


@end
