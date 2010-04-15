/*
 *  BTConstants.h
 *  Traps
 *
 *  Created by Kelvin Kakugawa on 3/14/10.
 *  Copyright 2010 Apple Inc. All rights reserved.
 *
 */

#pragma mark -
#pragma mark Convenience Macros

#define RELEASE_SAFELY(__POINTER) { [__POINTER release]; __POINTER = nil; }
#define AUTORELEASE_SAFELY(__POINTER) { [__POINTER autorelease]; __POINTER = nil; }
#define INVALIDATE_TIMER(__TIMER) { [__TIMER invalidate]; __TIMER = nil; }
#define RELEASE_TIMER(__TIMER) { [__TIMER invalidate]; [__TIMER release]; __TIMER = nil; }

#pragma mark -
#pragma mark Application Sections

#define kHTTPHost	@"thetrapgame.com"
//#define kHTTPHost	@"192.168.1.110:8000"
//#define kHTTPHost	@"192.168.0.116:8000"
//#define kHTTPHost	@"10.0.1.182:8000"

#pragma mark -
#pragma mark Foursquare api
#define oauth_request_token_url @"http://foursquare.com/oauth/request_token"
#define oauth_access_token_url @"http://foursquare.com/oauth/access_token"
#define oauth_authorize_url @"http://foursquare.com/oauth/authorize"

#define oauth_key @"JL4SJUD5VDGKSXSNAJNTM5D12VELWCEVYXWZDI4CYGJ1HGBI"
#define oauth_secret @"NFZME0GFKF3LM5EF3PO55BBNMB4ZLAE0K1T5K3AQ1JMZI3PW"

#define foursquareApi @"api.foursquare.com"


#define kHomeTitle			@"Home"
#define kSearchTitle		@"Search"
#define kProfileTitle		@"Profile"
#define kLeaderboardTitle	@"Leaderboard"

#pragma mark -
#pragma mark FB
#define fbAppId  @"3243a6e2dd3a0d084480d05f301cba85"
#define fbSecret	 @"d8611553a286dce3531353b3de53ef2e"

#pragma mark -
#pragma mark general constants
#define iphonescreenheight 480
#define iphonescreenwidth 320
#define navbarheight 44	
#define iphonetabbarheight 52

#define profilestatusheight 110
#define fbprofileinforowheight 80
#define fblogoutbuttonheight 31
#define fblogoutbuttonwidth 90

#define inventoryitemheight 100
#define inventoryitemwidth 100

#define venuerowheight 100

#pragma mark -
#pragma mark Home view
#pragma mark -
#define leftstatusxcoord 0
#define leftstatusycoord 0
#define rightstatusxcoord 160
#define rightstatusycoord 0

#define statusboxwidth 160
#define statusboxheight 110
#define statusboxtextheight 28



#pragma mark -
#pragma mark annotation views
#pragma mark -

#pragma mark guy coordinates
#define guyorigxcoord 135
#define guyorigycoord 3
#define guywidth 40
#define guyheight 55

#pragma mark -
#pragma mark text coordinates
#define annotationxcoord 10
#define annotationycoord 5
#define chanceofdropycoord 60



#pragma mark -
#pragma mark foursquare login view
#define foursquarerowheight 120

#define foursquarebuttonwidth 180
#define foursquarebuttonheight 24
#define textboxwidth 200
#define textboxheight 25
#define labelheight 20

#define foursquareratelimitexceeded @"Sorry but it looks like we've exceeded the foursquare rate limit. We'll have to get you to log in, or just play around with the beginner venues."
#define foursquarecheckinprefered @"Sign in to foursquare to have the option to checkin when searching!"

