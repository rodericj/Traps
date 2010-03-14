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

#define kHomeTitle			@"Home"
#define kSearchTitle		@"Search"
#define kProfileTitle		@"Profile"
#define kLeaderboardTitle	@"Leaderboard"

#pragma mark -
#pragma mark HTTP

#define kHTTPHost	@"192.168.2.46:8000"
