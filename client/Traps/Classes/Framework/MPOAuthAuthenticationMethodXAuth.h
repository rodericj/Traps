//
//  MPOAuthAuthenticationMethodXAuth.h
//  MPOAuth
//
//  Created by Karl Adam on 10.03.07.
//  Copyright 2010 Yahoo. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "MPOAuthAPI.h"
#import "MPOAuthAuthenticationMethod.h"
@protocol MPOAuthAuthenticationMethodOAuthDelegate;

@interface MPOAuthAuthenticationMethodXAuth : MPOAuthAuthenticationMethod <MPOAuthAPIInternalClient> {
	id <MPOAuthAuthenticationMethodOAuthDelegate> delegate_;

}
@property (nonatomic, readwrite, assign) id <MPOAuthAuthenticationMethodOAuthDelegate> delegate;

@end
