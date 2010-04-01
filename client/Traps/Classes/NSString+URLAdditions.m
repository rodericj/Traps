//
//  NSString+URLAdditions.m
//  Traps
//
//  Created by Kelvin Kakugawa on 3/14/10.
//  Copyright 2010 Apple Inc. All rights reserved.
//

#import "NSString+URLAdditions.h"


@implementation NSString (URLAdditions)

- (NSString *)urlEncode {
	NSString *result =
	(NSString *)CFURLCreateStringByAddingPercentEscapes(
														kCFAllocatorDefault,
														(CFStringRef)self,
														NULL,
														CFSTR(":/?#[]@!$&’()*+,;="),
														kCFStringEncodingUTF8);
	return [result autorelease];
}

@end
