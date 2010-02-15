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

#import <UIKit/UIKit.h>

#import "UAProduct.h"
#import "UATableCell.h"
#import "UADownloadHistoryItem.h"
	
@interface UADownloadProgressCell : UATableCell {
	IBOutlet UILabel* title;
	IBOutlet UILabel* dateView;
	IBOutlet UILabel* processing;
	IBOutlet UIProgressView* progressView;
	IBOutlet UIActivityIndicatorView* activityView;
	IBOutlet UIView* iconContainer;
	UADownloadHistoryItem* item;
	BOOL tabBarNotified;
}

@property (nonatomic, retain) UILabel* dateView;
@property (nonatomic, retain) UILabel* title;
@property (nonatomic, retain) UIProgressView* progressView;
@property (nonatomic, retain) UADownloadHistoryItem* item;
@property (nonatomic, retain) UIView* iconContainer;


- (void)processingDone;
- (void)downloadDone;
- (void)resetProgress;

- (void)incrementDownloadCount;
- (void)decrementDownloadCount;
	
- (void)setProgress:(float)progress;
- (void)setData:(UADownloadHistoryItem*)item;
	
@end
