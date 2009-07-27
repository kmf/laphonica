//
//  LoginViewController.m
//  modentica2
//
//  Created by Mark Bockenstedt on 2/6/09.
//  Copyright 2009 __MyCompanyName__. All rights reserved.
//

#import "LoginViewController.h"
#import "FriendViewController.h"
#import "IdenticaAPI.h"

@implementation LoginViewController

@synthesize usernameTextField, passwordTextField, serverTextField;

- (void) saveSettings: (id) sender
{
    NSString *username = usernameTextField.text;
    NSString *password = passwordTextField.text;
    NSString *server = serverTextField.text;
    
    // Verify they're all filled in
    if([username length] == 0 || [password length] == 0 || [server length] == 0)
    {
        NSLog(@"Nothing was entered");
    }
    else
    {
        NSLog(@"Verifying Credentials");
        IdenticaAPI *API = [IdenticaAPI alloc];
        BOOL success = [API loginAs: username withPass: password onServer: server];
        if(success)
        {
            // Store info into preferences
            NSDictionary *user = (NSDictionary *)[API GetUser: username];
            
            NSUserDefaults *standardDefaults = [NSUserDefaults standardUserDefaults];
            [standardDefaults setObject: username forKey: @"username"];
            [standardDefaults setObject: password forKey: @"password"];
            [standardDefaults setObject: server forKey: @"domain"];
            [standardDefaults setObject: [user objectForKey: @"utc_offset"] forKey: @"utc_offset"];
            [standardDefaults synchronize];
            
            [self loadFriendView];
        }
        else
        {
        }
    }
}
- (void) loadMoreView: (id) sender
{
    
}

- (void) loadFriendView
{
    NSLog(@"Loading Friend View");
    UIWindow *window;
    FriendViewController *friendView = [[FriendViewController alloc] initWithNibName: @"FriendView" bundle: [NSBundle mainBundle]];
    UIView *thisView = friendView.view;
    [UIView beginAnimations: nil context: NULL];
    [UIView setAnimationDuration: 1];
    [UIView setAnimationTransition: UIViewAnimationTransitionFlipFromRight forView: window cache: YES];
    [friendView viewWillAppear: YES];
    [window addSubview: thisView];
    [friendView viewDidAppear: YES];
    [UIView commitAnimations];
    [thisView release];
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

// Implement viewDidLoad to do additional setup after loading the view, typically from a nib.
- (void) viewDidLoad
{
    [super viewDidLoad];
    
    // Attempt to retrieve stored credentials
    NSUserDefaults *standardUserDefaults = [NSUserDefaults standardUserDefaults];
    NSString *username = [standardUserDefaults objectForKey:@"username"];
    NSString *password = [standardUserDefaults objectForKey:@"password"];
    NSString *server =   [standardUserDefaults objectForKey:@"domain"];
    
    [usernameTextField setText: username];
    [passwordTextField setText: password];
    [serverTextField setText: server];
    
    [usernameTextField becomeFirstResponder];
}

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
