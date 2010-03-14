//
//  BTHomeInternalViewController.m
//  Traps
//
//  Created by Kelvin Kakugawa on 3/14/10.
//  Copyright 2010 Apple Inc. All rights reserved.
//

#import "BTHomeInternalViewController.h"

@implementation BTHomeInternalViewController

#pragma mark -
#pragma mark Initialization

- (id)init {
    if ((self = [super initWithStyle:UITableViewStylePlain]) == nil) {
		return nil;
    }
	
	self.title = kHomeTitle;
	
    return self;
}

#pragma mark -
#pragma mark Cleanup

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
	
	//XXX: purge unnecessary data structures
}

- (void)dealloc {	
    [super dealloc];
}

#pragma mark -
#pragma mark UIViewController

- (void)viewDidLoad {
    [super viewDidLoad];
	
	//XXX: add code here
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
	
	//XXX: add code here
}

- (void)viewDidDisappear:(BOOL)animated {
	[super viewDidDisappear:animated];
	
	//XXX: add code here
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

#pragma mark -
#pragma mark UITableView

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
	return 0;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
	UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"default"];
	
    return cell;
}

#pragma mark -
#pragma mark BTHomeInternalViewController

@end

