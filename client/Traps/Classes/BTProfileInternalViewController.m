//
//  BTProfileInternalViewController.m
//  Traps
//
//  Created by Roderic Campbell on 3/14/10.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import "BTProfileInternalViewController.h"
#import "BTUserHistoryTableViewController.h"
#import "BTUserInventoryTableView.h"

@implementation BTProfileInternalViewController

@synthesize segmentedControl;
@synthesize segmentViews;
#pragma mark -
#pragma mark Initialization

- (id)init {
    if ((self = [super initWithStyle:UITableViewStylePlain]) == nil) {
		return nil;
    }
	
	self.title = @"";//kProfileTitle;
	segmentedControl = [[UISegmentedControl alloc] initWithItems:[NSArray arrayWithObjects:@"Activity",
																  @"Inventory",
																  nil]];
	//set up the segment control
	[segmentedControl setSelectedSegmentIndex:0];
	[segmentedControl addTarget:self 
						 action:@selector(segmentedControlChanged) 
			   forControlEvents:UIControlEventValueChanged];
	
		NSLog(@"done init");

    return self;
}

#pragma mark -
#pragma mark Cleanup

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
	
	//XXX: purge unnecessary data structures
}

- (void)dealloc {	
	
	//Let's get rid of each of the views in our segmentedview
	UITableView *current;
	for(int i = 0; i < [segmentViews count]; i++){
		current = [segmentViews objectAtIndex:i];
		[current release];
	}
	
	//get rid of the segmentViews Array
	[segmentViews release];
	
    [super dealloc];
}

#pragma mark -
#pragma mark UIViewController

- (void)viewDidLoad {
    [super viewDidLoad];
	
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
	NSLog(@"view will appear so we are making a new segmented views array");
	
	//set up each of the views that the segment controls
	segmentViews = [[NSArray arrayWithObjects:[[BTUserHistoryTableViewController alloc] init],
					[[BTUserInventoryTableView alloc] init], nil] retain];
}

- (void)viewDidDisappear:(BOOL)animated {
	[super viewDidDisappear:animated];
	

}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

#pragma mark -
#pragma mark Segmente Control
-(void) segmentedControlChanged{
	[self loadView];
}

#pragma mark -
#pragma mark UITableView

-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
	if([indexPath row] == 0){
		return 60;
	}
		  
	return iphonescreenheight - 60 - navbarheight;
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
	[tableView setScrollEnabled:NO];
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
	return 2;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
	
	NSString *reuseIdentifier = [NSString stringWithFormat:@"%d", [indexPath row]];
	UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:reuseIdentifier];
	
	if (cell == nil) {
        cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:reuseIdentifier] autorelease];
	}
	
	switch ([indexPath row]) {
		case 0:
			
			[segmentedControl setFrame:CGRectMake((iphonescreenwidth-200)/2, 10, 200, 40)];
			[cell addSubview:segmentedControl];
			break;
		case 1:
			NSLog(@"");
			UITableViewController *current = [segmentViews objectAtIndex:[segmentedControl selectedSegmentIndex]];
			[cell addSubview:[current view]];
			//}
			break;
		default:
			break;
	}
	cell.selectionStyle = UITableViewCellSelectionStyleNone;

    return cell;
}


@end
