//
//  modentica2AppDelegate.m
//  modentica2
//
//  Created by Mark Bockenstedt on 2/6/09.
//  Copyright __MyCompanyName__ 2009. All rights reserved.
//

#import "modentica2AppDelegate.h"
#import "IdenticaAPI.h"

// View Controllers
#import "FriendViewController.h"
#import "ReplyViewController.h"
#import "MessageViewController.h"
#import "FavoriteViewController.h"
#import "LoginViewController.h"
#import "MoreViewController.h"

#import "LoadingView.h"
#import "Utilities.h"

@implementation modentica2AppDelegate

@synthesize window, tabBarController, loadingView;

- (void) applicationDidFinishLaunching: (UIApplication *) application
{
    /*
    // Test for internet connection
    NSString *theURL = @"http://www.google.com/";
    theURL = [theURL stringByAddingPercentEscapesUsingEncoding: NSUTF8StringEncoding];
    NSURLRequest *theRequest = [NSURLRequest requestWithURL: [NSURL URLWithString: theURL]];
    NSURLResponse *resp = nil;
    NSError *err = nil;
    NSDate *response = [NSURLConnection sendSynchronousRequest: theRequest returningResponse: &resp error: &err];
     */
    NSError *err = nil;
    
    if(err == nil)
    {
        // Load stored credentials
        NSString *username = [[NSUserDefaults standardUserDefaults] objectForKey: @"username"];
        NSString *password = [[NSUserDefaults standardUserDefaults] objectForKey: @"password"];
        NSString *server =   [[NSUserDefaults standardUserDefaults] objectForKey: @"domain"];
        
        NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
        [defaults setObject: @"-18000" forKey: @"utc_offset"];
        [defaults synchronize];
    
        // All three are entered
        if([username length] > 0 && [password length] > 0 && [server length] > 0)
        {
            //BOOL success = [[IdenticaAPI alloc] loginAs: username withPass: password onServer: server];
            BOOL success = [[IdenticaAPI alloc] verifySavedCredentials];
            if(success)
            {
                [window addSubview: tabBarController.view];
            }
            else
            {
                NSLog(@"Invalid credentials");
                NSString *title = @"Unable to login";
                NSString *message = @"The credentials we have stored are invalid. Please enter new credentials";
                UIAlertView *alert = [[UIAlertView alloc] initWithTitle: title message: message delegate: self cancelButtonTitle: nil otherButtonTitles: @"OK", nil];
                [alert show];
                [alert release];
            }
        }
        // We're missing data
        else
        {
            NSLog(@"No credentials found");
            [self loadSettingsView];
        }
    }
    else
    {
        NSLog(@"no network connection");
        NSString *title = @"No network connection";
        NSString *message = @"Please try again later";
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle: title message: message delegate: self cancelButtonTitle: nil otherButtonTitles: @"OK", nil];
        [alert show];
        [alert release];
    }
}

- (void) applicationWillTerminate: (NSNotification *) notification
{
    // Clean the temporary directory
    [[Utilities alloc] purgeCache];
}

-   (void) alertView: (UIAlertView *) alertView
clickedButtonAtIndex: (NSInteger) buttonIndex
{
    if(![alertView.title isEqualToString: @"No network connection"])
    {
        // Doesn't matter what button was clicked, we're going to do the same action regardless
        [window addSubview: tabBarController.view];
        [self loadSettingsView];
    }
}

- (void) loadSettingsView
{
    NSLog(@"Loading Settings View");
    LoginViewController *settingsView = [[LoginViewController alloc] initWithNibName:@"LoginView" bundle:[NSBundle mainBundle]];
    UIView *thisView = settingsView.view;
    [UIView beginAnimations:nil context:NULL];
    [UIView setAnimationDuration:1];
    [UIView setAnimationTransition: UIViewAnimationTransitionFlipFromRight forView:window cache:YES];
    [settingsView viewWillAppear:YES];
    [window addSubview:thisView];
    [settingsView viewDidAppear:YES];
    [UIView commitAnimations];
    [thisView release];
}


/*
// Optional UITabBarControllerDelegate method
- (void)tabBarController:(UITabBarController *)tabBarController didSelectViewController:(UIViewController *)viewController {
}
*/

/*
// Optional UITabBarControllerDelegate method
- (void)tabBarController:(UITabBarController *)tabBarController didEndCustomizingViewControllers:(NSArray *)viewControllers changed:(BOOL)changed {
}
*/


- (void)dealloc {
    [tabBarController release];
    [window release];
    [super dealloc];
}

@end

