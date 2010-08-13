//
//  MPOAuthAuthenticationMethodAuthExchange.h
//  MPOAuthMobile
//
//  Created by Karl Adam on 09.12.20.
//  Copyright 2009 matrixPointer. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "MPOAuthAPI.h"
#import "MPOAuthAuthenticationMethod.h"
@protocol MPOAuthAuthenticationMethodOAuthDelegate;

@interface MPOAuthAuthenticationMethodAuthExchange : MPOAuthAuthenticationMethod <MPOAuthAPIInternalClient> {
	id <MPOAuthAuthenticationMethodOAuthDelegate> delegate_;
}
@property (nonatomic, readwrite, assign) id <MPOAuthAuthenticationMethodOAuthDelegate> delegate;

@end
