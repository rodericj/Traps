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

#import "UADateUtils.h"


@implementation UADateUtils


+(NSDate*) localizedDateFromUTC:(NSDate*)sourceDate {
	NSTimeZone* sourceTimeZone = [NSTimeZone timeZoneWithAbbreviation:@"UTC"];
	NSTimeZone* destinationTimeZone = [NSTimeZone systemTimeZone];
	
	NSInteger sourceGMTOffset = [sourceTimeZone secondsFromGMTForDate:sourceDate];
	NSInteger destinationGMTOffset = [destinationTimeZone secondsFromGMTForDate:sourceDate];
	NSTimeInterval interval = destinationGMTOffset - sourceGMTOffset;
	
	NSDate* destinationDate = [[[NSDate alloc] initWithTimeInterval:interval sinceDate:sourceDate] autorelease];
	return destinationDate;
}

+(NSString *) formattedDateRelativeToNow:(NSDate *)date
{
	NSDateFormatter *mdf = [[NSDateFormatter alloc] init];
	[mdf setDateFormat:@"yyyy-MM-dd"];
	NSDate *midnight = [mdf dateFromString:[mdf stringFromDate:date]];
	[mdf release];
	
	NSInteger dayDiff = (int)[midnight timeIntervalSinceNow] / (60*60*24);
	NSDateFormatter *dateFormatter = [[[NSDateFormatter alloc] init] autorelease]; 
	
	if(dayDiff == 0)
		[dateFormatter setDateFormat:@"h:mm aaa"];
	else if(dayDiff == -1)
		[dateFormatter setDateFormat:@"'Yesterday"];
	else if(dayDiff == -2)
		[dateFormatter setDateFormat:@"Two days ago'"];
	else if(dayDiff == -3)
		[dateFormatter setDateFormat:@"Three days ago'"];
	else if(dayDiff == -3)
		[dateFormatter setDateFormat:@"Four days ago'"];
	else if(dayDiff == -3)
		[dateFormatter setDateFormat:@"Five days ago'"];
	else if(dayDiff == -3)
		[dateFormatter setDateFormat:@"Six days ago'"];
	else if(dayDiff < -14 && dayDiff >= -7)
		[dateFormatter setDateFormat:@"Last week'"];
	else
		[dateFormatter setDateFormat:@"MMMM d'"];
	
	return [dateFormatter stringFromDate:date];
} 


@end
