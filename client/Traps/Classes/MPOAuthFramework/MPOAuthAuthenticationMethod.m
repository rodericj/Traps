//
//  MPOAuthAuthenticationMethod.m
//  MPOAuthConnection
//
//  Created by Karl Adam on 09.12.19.
//  Copyright 2009 matrixPointer. All rights reserved.
//

#import "MPOAuthAuthenticationMethod.h"
#import "MPOAuthAuthenticationMethodOAuth.h"
#import "MPOAuthCredentialConcreteStore.h"
#import "MPURLRequestParameter.h"

#import "NSURL+MPURLParameterAdditions.h"

NSString * const MPOAuthAccessTokenURLKey					= @"MPOAuthAccessTokenURL";

@interface MPOAuthAuthenticationMethod ()
@property (nonatomic, readwrite, retain) NSTimer *refreshTimer;

+ (Class)_authorizationMethodClassForURL:(NSURL *)inBaseURL withConfiguration:(NSDictionary **)outConfig;
- (id)initWithAPI:(MPOAuthAPI *)inAPI forURL:(NSURL *)inURL withConfiguration:(NSDictionary *)inConfig;
- (void)_automaticallyRefreshAccessToken:(NSTimer *)inTimer;
@end

@implementation MPOAuthAuthenticationMethod
- (id)initWithAPI:(MPOAuthAPI *)inAPI forURL:(NSURL *)inURL {
	return [self initWithAPI:inAPI forURL:inURL withConfiguration:nil];
}

- (id)initWithAPI:(MPOAuthAPI *)inAPI forURL:(NSURL *)inURL withConfiguration:(NSDictionary *)inConfig {
	NSLog(@"init MPOauthAuthentactionMethod: class: %@ url: %@", [self class], inURL);
	if ([[self class] isEqual:[MPOAuthAuthenticationMethod class]]) {
		NSLog(@"so it is an authentcation method");
		NSDictionary *configuration = nil;
		Class methodClass = [[self class] _authorizationMethodClassForURL:inURL withConfiguration:&configuration];
		[self release];
		NSLog(@"ok so we've got an OAuth Method here as defined by the twitter config");
		self = [[methodClass alloc] initWithAPI:inAPI forURL:inURL withConfiguration:configuration];
		NSLog(@"set up self to be that type of method");
	} else if (self = [super init]) {
		NSLog(@"else");
		self.oauthAPI = inAPI;		
	}
	NSLog(@"pop out of initWithAPI");
	return self;
}

- (oneway void)dealloc {
	self.oauthAPI = nil;
	self.oauthGetAccessTokenURL = nil;

	[self.refreshTimer invalidate];
	self.refreshTimer = nil;

	[super dealloc];
}

@synthesize oauthAPI = oauthAPI_;
@synthesize oauthGetAccessTokenURL = oauthGetAccessTokenURL_;
@synthesize refreshTimer = refreshTimer_;

#pragma mark -

+ (Class)_authorizationMethodClassForURL:(NSURL *)inBaseURL withConfiguration:(NSDictionary **)outConfig {
	Class methodClass = [MPOAuthAuthenticationMethodOAuth class];
	NSLog(@"about to get plist");
	NSString *oauthConfigPath = [[NSBundle bundleForClass:[self class]] pathForResource:@"oauthAutoConfig" ofType:@"plist"];
	NSLog(@"got plist");
	NSDictionary *oauthConfigDictionary = [NSDictionary dictionaryWithContentsOfFile:oauthConfigPath];
	NSLog(@"inBaseUrl %@", inBaseURL);
	for ( NSString *domainString in [oauthConfigDictionary keyEnumerator]) {
		NSLog(@"in for %@", domainString);
		if ([inBaseURL domainMatches:domainString]) {
			NSLog(@"in if");
			NSDictionary *oauthConfig = [oauthConfigDictionary objectForKey:domainString];
			
			NSArray *requestedMethods = [oauthConfig objectForKey:@"MPOAuthAuthenticationPreferredMethods"];
			NSString *requestedMethod = nil;
			NSLog(@"before for");
			for (requestedMethod in requestedMethods) {
				NSLog(@"in for again");
				Class requestedMethodClass = NSClassFromString(requestedMethod);
				
				if (requestedMethodClass) {
					methodClass = requestedMethodClass;
				}
				NSLog(@"breaking");
				break;
			}
			NSLog(@"after the for loop");
			if (requestedMethod) {
				NSLog(@"the requested method %@", requestedMethod);
				NSLog(@"setting config 1 %@", oauthConfig);
				*outConfig = [oauthConfig objectForKey:requestedMethod];
			} else {
				NSLog(@"setting config 2");
				*outConfig = oauthConfig;
			}
			NSLog(@"config is %@", *outConfig);
			break;
		}
	}
	NSLog(@"the method Class is %@", methodClass);
	
	return methodClass; 
}

#pragma mark -

- (void)authenticate {
	NSLog(@"authenticate in MPOAuthAuthenticationMethod.m");
	[NSException raise:@"Not Implemented" format:@"All subclasses of MPOAuthAuthenticationMethod are required to implement -authenticate"];
}

- (void)setTokenRefreshInterval:(NSTimeInterval)inTimeInterval {
	if (!self.refreshTimer && inTimeInterval > 0.0) {
		self.refreshTimer = [NSTimer scheduledTimerWithTimeInterval:inTimeInterval target:self selector:@selector(_automaticallyRefreshAccessToken:) userInfo:nil repeats:YES];	
	}
}

- (void)refreshAccessToken {
	MPURLRequestParameter *sessionHandleParameter = nil;
	MPOAuthCredentialConcreteStore *credentials = (MPOAuthCredentialConcreteStore *)[self.oauthAPI credentials];
	
	if (credentials.sessionHandle) {
		sessionHandleParameter = [[MPURLRequestParameter alloc] init];
		sessionHandleParameter.name = @"oauth_session_handle";
		sessionHandleParameter.value = credentials.sessionHandle;
	}
	
	[self.oauthAPI performMethod:nil
						   atURL:self.oauthGetAccessTokenURL
				  withParameters:sessionHandleParameter ? [NSArray arrayWithObject:sessionHandleParameter] : nil
					  withTarget:nil
					   andAction:nil];
	
	[sessionHandleParameter release];	
}

#pragma mark -

- (void)_automaticallyRefreshAccessToken:(NSTimer *)inTimer {
	[self refreshAccessToken];
}

@end
