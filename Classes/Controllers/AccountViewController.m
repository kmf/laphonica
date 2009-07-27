//
//  SettingsViewController.m
//  modentica2
//
//  Created by Mark Bockenstedt on 2/6/09.
//  Copyright 2009 __MyCompanyName__. All rights reserved.
//

#import "AccountViewController.h"
#import "FriendViewController.h"
#import "IdenticaAPI.h"

@implementation AccountViewController

@synthesize usernameTextField, passwordTextField, serverTextField, updateNumberTextField;

- (void) viewDidLoad
{
    [super viewDidLoad];
    
    // Attempt to retrieve stored credentials
    NSString *username = [[NSUserDefaults standardUserDefaults] stringForKey: @"username"];
    NSString *password = [[NSUserDefaults standardUserDefaults] stringForKey: @"password"];
    NSString *server =   [[NSUserDefaults standardUserDefaults] stringForKey: @"domain"];
    NSString *updates =  [[NSUserDefaults standardUserDefaults] stringForKey: @"updates"];
    
    usernameTextField.text = username;
    passwordTextField.text = password;
    serverTextField.text = server;
    updateNumberTextField.text = updates;
    
    UIBarButtonItem *saveButton = [[[UIBarButtonItem alloc] 
                                    initWithTitle: @"Save" 
                                    style: UIBarButtonItemStyleBordered 
                                    target: self
                                    action: @selector(saveSettings:)] autorelease]; 
    
    self.navigationItem.title = @"Account Settings";
    self.navigationItem.rightBarButtonItem = saveButton;
}

- (void) saveSettings: (id) sender
{
    NSString *username = usernameTextField.text;
    NSString *password = passwordTextField.text;
    NSString *server = serverTextField.text;
    //NSString *updates = updateNumberTextField.text;
    
    // Verify they're all filled in
    if([username length] == 0 || [password length] == 0 || [server length] == 0)
    {
        // Show alert
        NSString *msg = @"You've gotta fill in your info";
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle: @"Error" message: msg  delegate:self cancelButtonTitle: nil otherButtonTitles: @"OK", nil];
        [alert show];	
        [alert release];
    }
    else
    {
        NSLog(@"Verifying Credentials");
        IdenticaAPI *API = [IdenticaAPI alloc];
        BOOL success = [API loginAs:username withPass:password onServer:server];
        if(success)
        {
            NSLog(@"Successfully authenticated using given credentials");
            
            // Store info into preferences
            NSUserDefaults *standardUserDefaults = [NSUserDefaults standardUserDefaults];
            if(standardUserDefaults)
            {
                [standardUserDefaults setObject:username forKey:@"username"];
                [standardUserDefaults setObject:password forKey:@"password"];
                [standardUserDefaults setObject:server forKey:@"domain"];
                [standardUserDefaults synchronize];
            }
            
            // go back
        }
        else
        {
            // show alert
            NSString *msg = @"The credentials you've entered are invalid. Please try again.";
            UIAlertView *alert = [[UIAlertView alloc] initWithTitle: @"Error" message: msg  delegate:self cancelButtonTitle: nil otherButtonTitles: @"OK", nil];
            [alert show];	
            [alert release];
        }
    }
}

- (void) loadMoreView: (id) sender
{
    
}

- (void) loadFriendView: (id) sender
{

}

/*
// The designated initializer. Override to perform setup that is required before the view is loaded.
- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil {
    if (self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil]) {
        // Custom initialization
    }
    return self;
}
*/

/*
// Implement loadView to create a view hierarchy programmatically, without using a nib.
- (void)loadView {
}
*/

/*
// Override to allow orientations other than the default portrait orientation.
- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
    // Return YES for supported orientations
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}
*/

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning]; // Releases the view if it doesn't have a superview
    // Release anything that's not essential, such as cached data
}


- (void)dealloc {
    [super dealloc];
}


@end
