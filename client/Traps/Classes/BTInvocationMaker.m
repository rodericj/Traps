//
//  BTInvocationMaker.m
//  Traps
//
//  Created by Kelvin Kakugawa on 3/14/10.
//  Copyright 2010 Apple Inc. All rights reserved.
//

#import "BTInvocationMaker.h"


@implementation BTInvocationMaker

@synthesize target;
@synthesize invocation;

#pragma mark -
#pragma mark Initialization

- (id)initWithTarget:(id)theTarget {
	if (![super init]) {
		return nil;
	}
	
	self.target = theTarget;
	
	return self;
}

+ (id)invocationMaker {
	return [[[self alloc] init] autorelease];
}

+ (id)invocationMakerWithTarget:(id)theTarget {
	BTInvocationMaker *invocationMaker = [BTInvocationMaker invocationMaker];
	
	invocationMaker.target = theTarget;
	
	return invocationMaker;
}

#pragma mark -
#pragma mark NSObject

- (NSMethodSignature *)methodSignatureForSelector:(SEL)aSelector {
	return [self.target methodSignatureForSelector:aSelector];
}

- (void)forwardInvocation:(NSInvocation *)anInvocation {
	[anInvocation setTarget:self.target];
	self.invocation = anInvocation;
}

@end
