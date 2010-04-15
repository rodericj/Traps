//
//  BTFoursquareLoginViewController.m
//  Traps
//
//  Created by Roderic Campbell on 4/12/10.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import "BTFoursquareLoginViewController.h"
#import "BTConstants.h"
#import "BTNetwork.h"

@implementation BTFoursquareLoginViewController

@synthesize viewDescription;

- (void)didReceiveMemoryWarning {
	// Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
	
	// Release any cached data, images, etc that aren't in use.
}

- (void)viewDidUnload {
	// Release any retained subviews of the main view.
	// e.g. self.myOutlet = nil;
}


#pragma mark Table view methods

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
	return foursquarerowheight;
}
// Customize the number of rows in the table view.
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
 	[tableView setSeparatorColor:[UIColor blackColor]];
	[tableView setScrollEnabled:NO];
	return 4;
}

-(void)loginToFoursquare{
	NSLog(@"login to foursquare");
	[loginButton setEnabled:FALSE];
	NSString *sourceString = [NSString stringWithFormat:@"%@:%@", [unameTextField text],[passwordTextField text]];
	
	NSData *sourceData = [sourceString dataUsingEncoding:NSUTF8StringEncoding];
	NSString *base64EncodedString = [sourceData base64EncodedString];
	NSLog(@"encoding %@", base64EncodedString);
	[[BTNetwork sharedNetwork] performHttpOperationWithResponseObject:self
													  methodSignature:NSStringFromSelector(@selector(foursquareCallback:))
															   method:@"GET"
															   domain:foursquareApi
														  relativeURL:@"v1/user/"
															   params:nil 
															  headers:[NSArray arrayWithObjects:base64EncodedString,@"Authorization"]];
	
	
}

-(void)foursquareCallback:(id)results{
	NSLog(@"foursquare returned");
	NSLog(@"foursquare returned with %@", results);
	
	
}
- (UITableViewCell *) getTopCell:(NSString *)cellIdentifier{
	NSLog(@"we are setting up the topCell");
	NSLog(@"the reusable identifier %@", cellIdentifier);

	CGRect topCellFrame = CGRectMake(0, 0, iphonescreenwidth, foursquarerowheight);
	CGRect topCellImageFrame = CGRectMake(0, 0, iphonescreenwidth, navbarheight);
	CGRect explanationLabelFrame = CGRectMake(0, 44, iphonescreenwidth, foursquarerowheight-navbarheight);
	UITableViewCell *cell = [[[UITableViewCell alloc] initWithFrame:topCellFrame 
													reuseIdentifier:cellIdentifier] autorelease];
	
	UIImageView *NavBarPic;
	NavBarPic = [[UIImageView alloc] initWithFrame:topCellImageFrame];
	NavBarPic.tag = 3;
	
	UIImage *navImage = [UIImage imageNamed:@"homeViewTopBanner.png"];
	[NavBarPic setImage:navImage];
	[cell.contentView addSubview:NavBarPic];
	[NavBarPic release];
	
	UILabel *lblTemp;
	lblTemp = [[UILabel alloc] initWithFrame:explanationLabelFrame];
	lblTemp.tag = 1;
	[lblTemp setBackgroundColor:[UIColor clearColor]];
	
	[lblTemp setText:viewDescription];
	[lblTemp setFont:[UIFont fontWithName:@"Helvetica" size:14]];
	[lblTemp setTextColor:[UIColor grayColor]];
	[lblTemp setNumberOfLines:4];
	[cell.contentView addSubview:lblTemp];
	[lblTemp release];
	
	return cell;
}
	
- (UITableViewCell *) getLoginInfoCell:(NSString *)cellIdentifier{
	NSLog(@"we are setting up the logininfocell");
	CGRect loginCellFrame = CGRectMake(0, 0, iphonescreenwidth, foursquarerowheight);
	CGRect unameTextBoxFrame = CGRectMake(iphonescreenwidth/3, 15, textboxwidth, textboxheight);
	CGRect passwordTextBoxFrame = CGRectMake(iphonescreenwidth/3, 50, textboxwidth, textboxheight);
	CGRect loginButtonFrame = CGRectMake(30, foursquarerowheight/4*3, foursquarebuttonwidth, foursquarebuttonheight);
	CGRect cancelButtonFrame = CGRectMake(foursquarebuttonwidth + 40, foursquarerowheight/4*3, 60, foursquarebuttonheight);
	CGRect unameLabel = CGRectMake(10, 15+textboxheight/2, 110, labelheight);
	CGRect passwordLabel = CGRectMake(10, 50+textboxheight/2, 140, labelheight);
	
	NSLog(@"the reusable identifier %@", cellIdentifier);
	UITableViewCell *cell = [[[UITableViewCell alloc] initWithFrame:loginCellFrame 
													reuseIdentifier:cellIdentifier] autorelease];
	
	unameTextField = [[[UITextField alloc] initWithFrame:unameTextBoxFrame] autorelease];
	[unameTextField setBorderStyle:UITextBorderStyleRoundedRect];
	[cell.contentView addSubview:unameTextField];
	//[unameTextField release];
	
	passwordTextField = [[[UITextField alloc] initWithFrame:passwordTextBoxFrame] autorelease];
	[passwordTextField setBorderStyle:UITextBorderStyleRoundedRect];
	[passwordTextField setSecureTextEntry:TRUE];
	[cell.contentView addSubview:passwordTextField];
	//[passwordTextField release];
	
	loginButton = [UIButton buttonWithType:UIButtonTypeRoundedRect];
	[loginButton setBackgroundImage:[UIImage imageNamed:@"signinwith-foursquare.png"] forState:UIControlStateNormal];
	[loginButton setFrame:loginButtonFrame];
	//[loginButton release];
	
	//listen for clicks
	[loginButton addTarget:self action:@selector(loginToFoursquare) 
		   forControlEvents:UIControlEventTouchUpInside];	
	
	//put button on View
	[cell.contentView addSubview:loginButton];
	
	UIButton *cancelButton = [UIButton buttonWithType:UIButtonTypeRoundedRect];
	[cancelButton setTitle:@"Cancel" forState:UIControlStateNormal];
	[cancelButton setFrame:cancelButtonFrame];
	[cell addSubview:cancelButton];
	
	UILabel *lblTemp;
	lblTemp = [[UILabel alloc] initWithFrame:unameLabel];
	lblTemp.tag = 1;
	[lblTemp setBackgroundColor:[UIColor clearColor]];
	
	[lblTemp setText:@"uname"];
	[lblTemp setFont:[UIFont fontWithName:@"Helvetica" size:14]];
	[lblTemp setTextColor:[UIColor grayColor]];
	[cell.contentView addSubview:lblTemp];
	[lblTemp release];
	
	lblTemp = [[UILabel alloc] initWithFrame:passwordLabel];
	lblTemp.tag = 2;
	[lblTemp setBackgroundColor:[UIColor clearColor]];
	
	[lblTemp setText:@"password"];
	[lblTemp setFont:[UIFont fontWithName:@"Helvetica" size:14]];
	[lblTemp setTextColor:[UIColor grayColor]];
	[cell.contentView addSubview:lblTemp];
	[lblTemp release];
	
	//[lblTemp release];
	
	return cell;
}



// Customize the appearance of table view cells.
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
	NSString *CellIdentifier = [NSString stringWithFormat:@"cell%d", [indexPath row]];
    NSLog(@"setting up the cell %d", [indexPath row]);
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil){
		NSLog(@"it is nil %d", [indexPath row]);

		if([indexPath row] == 1) {
			NSLog(@"setting up row 1");
			cell =  [self getLoginInfoCell:CellIdentifier];

		}
		else if([indexPath row] == 0){
			NSLog(@"setting up row 0 now");

			cell = [self getTopCell:CellIdentifier];
			[cell setUserInteractionEnabled:FALSE];

		}
		else {
			cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier] autorelease];
			[cell setUserInteractionEnabled:FALSE];

		}
	}
	
	UIView* backgroundView = [ [ [ UIView alloc ] initWithFrame:CGRectZero ] autorelease ];
	backgroundView.backgroundColor = [ UIColor blackColor ];
	cell.backgroundView = backgroundView;
    // Set up the cell...
	//[cell setText:@"blah"];
    return cell;
}


- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    // Navigation logic may go here. Create and push another view controller.
	// AnotherViewController *anotherViewController = [[AnotherViewController alloc] initWithNibName:@"AnotherView" bundle:nil];
	// [self.navigationController pushViewController:anotherViewController];
	// [anotherViewController release];
	NSLog(@"selected %d", [indexPath row]);
}

- (void)dealloc {
	[unameTextField release];
	[passwordTextField release];
    [super dealloc];
}


@end
