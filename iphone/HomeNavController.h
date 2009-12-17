//
//  HomeNavController.h
//  BoobyTrap3
//
//  Created by Roderic Campbell on 10/11/09.
//  Copyright 2009 Slide. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "HomeTableViewController.h"

@interface HomeNavController : UINavigationController {
	IBOutlet HomeTableViewController *homeTableViewController;
}
//@property (nonatomic, retain) HomeTableViewController *homeTableViewController;
//-(IBAction) logout;
@end
