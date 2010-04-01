//
//  BTInvocationMaker.h
//  Traps
//
//  Created by Kelvin Kakugawa on 3/14/10.
//  Copyright 2010 Apple Inc. All rights reserved.
//

#import <Foundation/Foundation.h>


@interface BTInvocationMaker : NSObject {
	id target;
	NSInvocation *invocation;
}

@property (nonatomic, retain) id target;
@property (nonatomic, retain) NSInvocation *invocation;

- (id)initWithTarget:(id)theTarget;

+ (id)invocationMaker;
+ (id)invocationMakerWithTarget:(id)theTarget;

@end
