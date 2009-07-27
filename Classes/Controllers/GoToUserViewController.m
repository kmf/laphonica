//
//  GoToUserViewController.m
//  modentica2
//
//  Created by Mark Bockenstedt on 2/6/09.
//  Copyright 2009 __MyCompanyName__. All rights reserved.
//

#import "GoToUserViewController.h"
#import "UserViewController.h"
#import "IdenticaAPI.h"

@implementation GoToUserViewController

@synthesize usernameField;

// The designated initializer. Override to perform setup that is required before the view is loaded.
- (id) initWithNibName: (NSString *) nibNameOrNil
                bundle: (NSBundle *) nibBundleOrNil
{
    if (self = [super initWithNibName: nibNameOrNil bundle: nibBundleOrNil])
    {
        self.navigationItem.title = @"Go to User";
    }
    return self;
}

- (void) GoToUser: (id) sender
{
    // Check to see if the user exists
    NSDictionary *userData = (NSDictionary *)[[IdenticaAPI alloc] GetUser: usernameField.text];
    if(userData)
    {
        // Close the keyboard
        [usernameField resignFirstResponder];
        
        // Load 'User View'
        UserViewController *userViewController = [[UserViewController alloc] initWithNibName: @"UserView" bundle: nil withUser: userData];
        userViewController.hidesBottomBarWhenPushed = YES;
        [self.navigationController pushViewController: userViewController animated: YES];
        [userViewController release];
    }
    else
    {
        // Show alert
        NSString *message = @"No user exists with that name. Please try again.";
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle: @"Error" message: message delegate: self cancelButtonTitle: nil otherButtonTitles: @"OK", nil];
        [alert show];
        [alert release];
        usernameField.text = @"";
    }
}

- (void) viewDidAppear: (BOOL) animated
{
    [super viewDidAppear: animated];
    
    [usernameField becomeFirstResponder];
}

- (BOOL) textFieldShouldReturn: (UITextField *) textField
{
    [textField resignFirstResponder];
    return YES;
}


- (void) didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning]; // Releases the view if it doesn't have a superview
    // Release anything that's not essential, such as cached data
}


- (void) dealloc
{
    [usernameField dealloc];
    [super dealloc];
}


@end
