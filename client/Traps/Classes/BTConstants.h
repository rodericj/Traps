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

//#define kHTTPHost	@"thetrapgame.com"
#define kHTTPHost	@"192.168.1.110:8000"
//#define kHTTPHost	@"10.0.1.182:8000"

#define kHomeTitle			@"Home"
#define kSearchTitle		@"Search"
#define kProfileTitle		@"Profile"
#define kLeaderboardTitle	@"Leaderboard"

#pragma mark -
#pragma mark HTTP



#define foursquareApi @"api.foursquare.com"


#pragma mark -
#pragma mark FB
#define fbAppId  @"3243a6e2dd3a0d084480d05f301cba85"
#define fbSecret	 @"d8611553a286dce3531353b3de53ef2e"

#define iphonescreenheight 480
#define iphonescreenwidth 320
#define navbarheight 44	

#define fbprofileinforowheight 80
#define fblogoutbuttonheight 31
#define fblogoutbuttonwidth 90

#define inventoryitemheight 100
#define inventoryitemwidth 100

#define venuerowheight 100

