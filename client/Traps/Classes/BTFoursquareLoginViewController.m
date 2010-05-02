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
#import "BTUserProfile.h"
#import <JSON/JSON.h>
#import "MPOAuthAuthenticationMethodOAuth.h"

//#import "MPOAuthAPI.h"


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

-(void) authorize{
	//[_oauthAPI discardCredentials];

	if (!_oauthAPI) {
		NSLog(@"setting creds");
		NSDictionary *credentials = [NSDictionary dictionaryWithObjectsAndKeys:	
									 oauth_key, kMPOAuthCredentialConsumerKey,
									 oauth_secret, kMPOAuthCredentialConsumerSecret,
									 [unameTextField text], kMPOAuthCredentialUsername,
									 [passwordTextField text], kMPOAuthCredentialPassword,
									 nil];
		NSLog(@"authenticationURL is: %@ andBaseURL is %@ %@" foursquareAuthUrl, foursquareApiBase, foursquareApiBase);
		NSLog(@"base is %@", foursquareApiBase);
		_oauthAPI = [[MPOAuthAPI alloc] initWithCredentials:credentials
										  authenticationURL:[NSURL URLWithString:foursquareAuthUrl]
												 andBaseURL:[NSURL URLWithString:foursquareApiBase]];
		
		[(MPOAuthAuthenticationMethodOAuth *)[_oauthAPI authenticationMethod] setDelegate:(id <MPOAuthAuthenticationMethodOAuthDelegate>)[UIApplication sharedApplication].delegate];
	} else {
		NSLog(@"the creds were already set");
		[_oauthAPI authenticate];
	}
}


-(void)foursquareCallback:(id)results{
	NSLog(@"foursquare returned");
	
	if ([results isKindOfClass:[NSError class]]) {
		NSLog(@"test: response: error!!!: %@", results);
		
		int returnCode = [results code];
		NSLog(@"code %d", returnCode);
		switch (returnCode) {
			case 401:
				NSLog(@"return 401: Unauthorized access. Try again");
				UIAlertView *alert;
				NSString *alertStatement = invalidloginalertstatement;
				alert = [[UIAlertView alloc] initWithTitle:@"Bad username/password" message:alertStatement delegate:self cancelButtonTitle:@"Ok" otherButtonTitles:nil]; 
				[alert show];
				[alert release];
				[loginButton setEnabled:TRUE];
				break;
			case 501:
				NSLog(@"Not implemented on Foursquare's side. Hmmm, that is problematic");
				break;
			case 400:
				NSLog(@"rate limit error again");
				break;
			default:
				NSLog(@" some other kind of error %d", [results code]);
				break;
		}
	}
	else{
		//Success
		SBJSON *parser = [SBJSON new];
		NSString *responseString = [[NSString alloc] initWithData:results encoding:NSUTF8StringEncoding];
		
		NSDictionary* webRequestResults = [parser objectWithString:responseString error:NULL];
		NSLog(@"foursquare returned %@", webRequestResults) ;
		
		//Save the uname/password in the model
		NSString *sourceString = [NSString stringWithFormat:@"%@:%@", [unameTextField text],[passwordTextField text]];
		NSData *sourceData = [sourceString dataUsingEncoding:NSUTF8StringEncoding];
		
		NSString *base64EncodedString = [sourceData base64EncodedString];
		NSString *fullEncoded = [NSString stringWithFormat:@"Basic %@", base64EncodedString];

		[[BTUserProfile sharedBTUserProfile] setUserBase64EncodedPassword:fullEncoded];		
		
		//Send the uname/password to django
		NSLog(@"send back to %@", [self.parentViewController class]);
		
		//Put it away
		[self.parentViewController dismissModalViewControllerAnimated:YES];
		
		
	}
		return;
}

	



- (UITableViewCell *) getTopCell:(NSString *)cellIdentifier{

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
	
	UITableViewCell *cell = [[[UITableViewCell alloc] initWithFrame:loginCellFrame 
													reuseIdentifier:cellIdentifier] autorelease];
	
	unameTextField = [[[UITextField alloc] initWithFrame:unameTextBoxFrame] autorelease];
	[unameTextField setBorderStyle:UITextBorderStyleRoundedRect];
	[unameTextField setAutocorrectionType:UITextAutocorrectionTypeNo];
	[cell.contentView addSubview:unameTextField];
	//[unameTextField release];
	
	passwordTextField = [[[UITextField alloc] initWithFrame:passwordTextBoxFrame] autorelease];
	[passwordTextField setBorderStyle:UITextBorderStyleRoundedRect];
	[passwordTextField setSecureTextEntry:TRUE];
	[cell.contentView addSubview:passwordTextField];
	//[passwordTextField release];
	
	loginButton = [UIButton buttonWithType:UIButtonTypeRoundedRect];
	[loginButton setBackgroundImage:[UIImage imageNamed:@"signinwith-foursquare.png"] forState:UIControlStateNormal];
	[loginButton setBackgroundImage:[UIImage imageNamed:@"signinwith-foursquare.png"] forState:UIControlStateDisabled];
	[loginButton setFrame:loginButtonFrame];
	//[loginButton release];
	
	//listen for clicks
	[loginButton addTarget:self action:@selector(authorize) 
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
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil){

		if([indexPath row] == 1) {
			cell =  [self getLoginInfoCell:CellIdentifier];

		}
		else if([indexPath row] == 0){
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
	
	//disable clicks
	cell.selectionStyle = UITableViewCellSelectionStyleNone;
	
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

