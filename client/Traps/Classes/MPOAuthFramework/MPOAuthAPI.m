//
//  MPOAuthAPI.m
//  MPOAuthConnection
//
//  Created by Karl Adam on 08.12.05.
//  Copyright 2008 matrixPointer. All rights reserved.
//

#import "MPOAuthAPIRequestLoader.h"
#import "MPOAuthAPI.h"
#import "MPOAuthCredentialConcreteStore.h"
#import "MPOAuthURLRequest.h"
#import "MPOAuthURLResponse.h"
#import "MPURLRequestParameter.h"
#import "MPOAuthAuthenticationMethod.h"

#import "NSURL+MPURLParameterAdditions.h"

NSString *kMPOAuthCredentialConsumerKey				= @"kMPOAuthCredentialConsumerKey";
NSString *kMPOAuthCredentialConsumerSecret			= @"kMPOAuthCredentialConsumerSecret";
NSString *kMPOAuthCredentialUsername				= @"kMPOAuthCredentialUsername";
NSString *kMPOAuthCredentialPassword				= @"kMPOAuthCredentialPassword";
NSString *kMPOAuthCredentialRequestToken			= @"kMPOAuthCredentialRequestToken";
NSString *kMPOAuthCredentialRequestTokenSecret		= @"kMPOAuthCredentialRequestTokenSecret";
NSString *kMPOAuthCredentialAccessToken				= @"kMPOAuthCredentialAccessToken";
NSString *kMPOAuthCredentialAccessTokenSecret		= @"kMPOAuthCredentialAccessTokenSecret";
NSString *kMPOAuthCredentialSessionHandle			= @"kMPOAuthCredentialSessionHandle";

NSString *kMPOAuthSignatureMethod					= @"kMPOAuthSignatureMethod";
NSString * const MPOAuthTokenRefreshDateDefaultsKey		= @"MPOAuthAutomaticTokenRefreshLastExpiryDate";

@interface MPOAuthAPI ()
@property (nonatomic, readwrite, retain) id <MPOAuthCredentialStore, MPOAuthParameterFactory> credentials;
@property (nonatomic, readwrite, retain) NSURL *authenticationURL;
@property (nonatomic, readwrite, retain) NSURL *baseURL;
@property (nonatomic, readwrite, retain) NSMutableArray *activeLoaders;
@property (nonatomic, readwrite, assign) MPOAuthAuthenticationState authenticationState;

- (void)performMethod:(NSString *)inMethod atURL:(NSURL *)inURL withParameters:(NSArray *)inParameters withTarget:(id)inTarget andAction:(SEL)inAction usingHTTPMethod:(NSString *)inHTTPMethod;
@end

@implementation MPOAuthAPI

- (id)initWithCredentials:(NSDictionary *)inCredentials andBaseURL:(NSURL *)inBaseURL {
	return [self initWithCredentials:inCredentials authenticationURL:inBaseURL andBaseURL:inBaseURL];
}

- (id)initWithCredentials:(NSDictionary *)inCredentials authenticationURL:(NSURL *)inAuthURL andBaseURL:(NSURL *)inBaseURL {
	return [self initWithCredentials:inCredentials authenticationURL:inBaseURL andBaseURL:inBaseURL autoStart:YES];	
}

- (id)initWithCredentials:(NSDictionary *)inCredentials authenticationURL:(NSURL *)inAuthURL andBaseURL:(NSURL *)inBaseURL autoStart:(BOOL)aFlag {
	NSLog(@"initWithCreds");
	if (self = [super init]) {
		NSLog(@"1");
		self.authenticationURL = inAuthURL;
		NSLog(@"2");
		self.baseURL = inBaseURL;
		self.authenticationState = MPOAuthAuthenticationStateUnauthenticated;
		NSLog(@"3");
		credentials_ = [[MPOAuthCredentialConcreteStore alloc] initWithCredentials:inCredentials forBaseURL:inBaseURL withAuthenticationURL:inAuthURL];
		NSLog(@"creds");
		NSLog(@"%@", credentials_);
		self.authenticationMethod = [[MPOAuthAuthenticationMethod alloc] initWithAPI:self forURL:inAuthURL];	
		NSLog(@"3.5");
		self.signatureScheme = MPOAuthSignatureSchemeHMACSHA1;
		NSLog(@"4");

		activeLoaders_ = [[NSMutableArray alloc] initWithCapacity:10];
		NSLog(@"all set up, lets authenticate");
		if (aFlag) {
			NSLog(@"authenticating");
			[self authenticate];
			NSLog(@"done authenticating");
		}
	}
	NSLog(@"bounce out");
	return self;	
}

- (oneway void)dealloc {
	self.credentials = nil;
	self.baseURL = nil;
	self.authenticationURL = nil;
	self.authenticationMethod = nil;
	self.activeLoaders = nil;
	
	[super dealloc];
}

@synthesize credentials = credentials_;
@synthesize baseURL = baseURL_;
@synthesize authenticationURL = authenticationURL_;
@synthesize authenticationMethod = authenticationMethod_;
@synthesize signatureScheme = signatureScheme_;
@synthesize activeLoaders = activeLoaders_;
@synthesize authenticationState = oauthAuthenticationState_;

#pragma mark -

- (void)setSignatureScheme:(MPOAuthSignatureScheme)inScheme {
	signatureScheme_ = inScheme;
	
	NSString *methodString = @"HMAC-SHA1";
	
	switch (signatureScheme_) {
		case MPOAuthSignatureSchemePlainText:
			methodString = @"PLAINTEXT";
			break;
		case MPOAuthSignatureSchemeRSASHA1:
			methodString = @"RSA-SHA1";
		case MPOAuthSignatureSchemeHMACSHA1:
		default:
			// already initted to the default
			break;
	}
	
	[(MPOAuthCredentialConcreteStore *)credentials_ setSignatureMethod:methodString];
}

#pragma mark -

- (void)authenticate {
	NSLog(@"MPOAuthAPI:authenticate() type of method: %@", [self.authenticationMethod class]);
	NSAssert(credentials_.consumerKey, @"A Consumer Key is required for use of OAuth.");
	NSLog(@"Call authenticate on %@", [self.authenticationMethod class]);
	[self.authenticationMethod authenticate];
}

- (BOOL)isAuthenticated {
	return (self.authenticationState == MPOAuthAuthenticationStateAuthenticated);
}

#pragma mark -

- (void)performMethod:(NSString *)inMethod withTarget:(id)inTarget andAction:(SEL)inAction {
	NSLog(@"MPOAuthAPI: performMethod1");
	[self performMethod:inMethod atURL:self.baseURL withParameters:nil withTarget:inTarget andAction:inAction usingHTTPMethod:@"GET"];
}

- (void)performMethod:(NSString *)inMethod atURL:(NSURL *)inURL withParameters:(NSArray *)inParameters withTarget:(id)inTarget andAction:(SEL)inAction {
	NSLog(@"MPOAuthAPI: performMethod2");

	[self performMethod:inMethod atURL:inURL withParameters:inParameters withTarget:inTarget andAction:inAction usingHTTPMethod:@"GET"];
}

- (void)performPOSTMethod:(NSString *)inMethod atURL:(NSURL *)inURL withParameters:(NSArray *)inParameters withTarget:(id)inTarget andAction:(SEL)inAction {
	NSLog(@"MPOAuthAPI: performPOSTMethod");

	[self performMethod:inMethod atURL:inURL withParameters:inParameters withTarget:inTarget andAction:inAction usingHTTPMethod:@"POST"];
}

- (void)performMethod:(NSString *)inMethod atURL:(NSURL *)inURL withParameters:(NSArray *)inParameters withTarget:(id)inTarget andAction:(SEL)inAction usingHTTPMethod:(NSString *)inHTTPMethod {
	NSLog(@"MPOAuthAPI: performMethod3");

	if (!inMethod && ![inURL path] && ![inURL query]) {
		[NSException raise:@"MPOAuthNilMethodRequestException" format:@"Nil was passed as the method to be performed on %@", inURL];
	}
	NSLog(@"MPOAuthAPI: inURL: %@", inURL);
	NSURL *requestURL = inMethod ? [NSURL URLWithString:inMethod relativeToURL:inURL] : inURL;
	NSLog(@"creating request");
	MPOAuthURLRequest *aRequest = [[MPOAuthURLRequest alloc] initWithURL:requestURL andParameters:inParameters];
	NSLog(@"creating loader");

	MPOAuthAPIRequestLoader *loader = [[MPOAuthAPIRequestLoader alloc] initWithRequest:aRequest];
	NSLog(@"setting up loader and request");
	aRequest.HTTPMethod = inHTTPMethod;
	loader.credentials = self.credentials;
	loader.target = inTarget;
	NSLog(@"1");
	loader.action = inAction ? inAction : @selector(_performedLoad:receivingData:);
	NSLog(@"2");
	//NSLog(@"credentials:  %@   target: %@   action %@", loader.credentials, loader.target, loader.action);
	NSLog(@"3");
	[loader loadSynchronously:NO];
	NSLog(@"4");
	//	[self.activeLoaders addObject:loader];
	
	[loader release];
	[aRequest release];
}

- (void)performURLRequest:(NSURLRequest *)inRequest withTarget:(id)inTarget andAction:(SEL)inAction {
	NSLog(@"MPOAuthAPI: performURLRequest");

	if (!inRequest && ![[inRequest URL] path] && ![[inRequest URL] query]) {
		[NSException raise:@"MPOAuthNilMethodRequestException" format:@"Nil was passed as the method to be performed on %@", inRequest];
	}

	MPOAuthURLRequest *aRequest = [[MPOAuthURLRequest alloc] initWithURLRequest:inRequest];
	MPOAuthAPIRequestLoader *loader = [[MPOAuthAPIRequestLoader alloc] initWithRequest:aRequest];
	
	loader.credentials = self.credentials;
	loader.target = inTarget;
	loader.action = inAction ? inAction : @selector(_performedLoad:receivingData:);
	
	[loader loadSynchronously:NO];
	//	[self.activeLoaders addObject:loader];
	
	[loader release];
	[aRequest release];	
}

- (NSData *)dataForMethod:(NSString *)inMethod {
	NSLog(@"MPOAuthAPI: dataForMethod1");
	return [self dataForURL:self.baseURL andMethod:inMethod withParameters:nil];
}

- (NSData *)dataForMethod:(NSString *)inMethod withParameters:(NSArray *)inParameters {
	NSLog(@"MPOAuthAPI: dataForMethod2");

	return [self dataForURL:self.baseURL andMethod:inMethod withParameters:inParameters];
}

- (NSData *)dataForURL:(NSURL *)inURL andMethod:(NSString *)inMethod withParameters:(NSArray *)inParameters {
	NSLog(@"MPOAuthAPI: dataForURL");

	NSURL *requestURL = [NSURL URLWithString:inMethod relativeToURL:inURL];
	MPOAuthURLRequest *aRequest = [[MPOAuthURLRequest alloc] initWithURL:requestURL andParameters:inParameters];
	MPOAuthAPIRequestLoader *loader = [[MPOAuthAPIRequestLoader alloc] initWithRequest:aRequest];

	loader.credentials = self.credentials;
	[loader loadSynchronously:YES];
	
	[loader autorelease];
	[aRequest release];
	
	return loader.data;
}

#pragma mark -

- (id)credentialNamed:(NSString *)inCredentialName {
	return [self.credentials credentialNamed:inCredentialName];
}

- (void)setCredential:(id)inCredential withName:(NSString *)inName {
	[(MPOAuthCredentialConcreteStore *)self.credentials setCredential:inCredential withName:inName];
}

- (void)removeCredentialNamed:(NSString *)inName {
	[(MPOAuthCredentialConcreteStore *)self.credentials removeCredentialNamed:inName];
}

- (void)discardCredentials {
	[self.credentials discardOAuthCredentials];
	
	self.authenticationState = MPOAuthAuthenticationStateUnauthenticated;
}

#pragma mark -
#pragma mark - Private APIs -

- (void)_performedLoad:(MPOAuthAPIRequestLoader *)inLoader receivingData:(NSData *)inData {
	NSLog(@"loaded %@, and got %@", inLoader, inData);
}

@end
