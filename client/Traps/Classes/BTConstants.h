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
//#define kHTTPHost	@"192.168.1.101:8080"
//#define kHTTPHost	@"192.168.0.116:8000"
//#define kHTTPHost	@"10.0.1.172:8000"
//#define kHTTPHost  @"http://10.247.1.151:8000"

#pragma mark -
#pragma mark django views

#define django_login				@"iphone_login/"
#define django_get_user_feed		@"get_user_feed"
#define django_search_venue			@"search_venue/"
#define django_set_device_token		@"set_device_token/"
#define django_logout				@"app_logout/"
#define django_set_trap				@"set_trap/"
#define django_get_my_user_profile	@"get_my_user_profile/"
#define django_get_friends			@"get_friends"

#define oauth_key					@"1VPFYWEOQITVCFURSTB0PXKAEA5CBCMDKO2PXHPPIZI5RTYM"
#define oauth_secret				@"ZEZ1HY0HYQORJG0YRKSI25VGCD3DRDMECS2URZHYXGRMK01R"

#define twitter_oauth_key			@"8DRCvYvHLLU0W1ZPHZ4MsA"
#define twitter_oauth_secret		@"RCvPfSCT8th85uAjB7Ddd1YYa8WI4XDhB6Imx3iibWk"

#define foursquare_api				@"api.foursquare.com"
#define foursquare_api_base			@"http://api.foursquare.com"
#define foursquare_auth_url			@"http://www.foursquare.com/oauth/"

#define CRASH_REPORTER_URL			@"http://crashreport.rodericj.webfactional.com/server/server/crash_v200.php"
#define foursquare_venues_endpoint	@"v1/venues.json"
#define foursquare_checkin_endpoint	@"v1/checkin.json"

#define kHomeTitle					@"Home"
#define kSearchTitle				@"Search"
#define kProfileTitle				@"Profile"
#define kLeaderboardTitle			@"Leaderboard"

#pragma mark -
#pragma mark FB
#define fbAppId						@"3243a6e2dd3a0d084480d05f301cba85"
#define fbSecret					@"d8611553a286dce3531353b3de53ef2e"

#pragma mark -
#pragma mark general constants
#define iphonescreenheight	480
#define iphonescreenwidth	320
#define navbarheight		44	
#define iphonetabbarheight	52

#define profilestatusheight		110
#define fbprofileinforowheight	80
#define fblogoutbuttonheight	31
#define fblogoutbuttonwidth		90

#define inventoryitemheight 100
#define inventoryitemwidth	100

#define venuerowheight		100
#define wantfoursquarecheckinrowheight 50
#define detailmapviewheight iphonescreenheight - venuerowheight - wantfoursquarecheckinrowheight - (navbarheight*2)-24

#pragma mark -
#pragma mark Home view
#pragma mark -
#define leftstatusxcoord	0
#define leftstatusycoord	0
#define rightstatusxcoord	160
#define rightstatusycoord	0

#define statusboxwidth		160
#define statusboxheight		110
#define statusboxtextheight 28



#pragma mark -
#pragma mark annotation views
#pragma mark -

#pragma mark guy coordinates
#define guyorigxcoord	135
#define guyorigycoord	3
#define guywidth		40
#define guyheight		55

#pragma mark -
#pragma mark text coordinates
#define annotationxcoord	10
#define annotationycoord	5

#pragma mark -
#pragma mark foursquare login view

#define foursquarerowheight		120

#define foursquarebuttonwidth	180
#define foursquarebuttonheight	24
#define textboxwidth			200
#define textboxheight			25
#define labelheight				20

#define doyouwanttocheckin				@"Check-in to foursquare?"
#define foursquareratelimitexceeded		@"Sorry but it looks like we've exceeded the foursquare rate limit. We'll have to get you to log in, or just play around with the beginner venues."
#define foursquarecheckinprefered		@"Sign in to foursquare to have the option to checkin when searching!"
#define invalidloginalertstatement		@"Looks like your username and password were not accepted. Let's try again"
#define yousetatrap						@"Congrats, you've just set a trap here!"