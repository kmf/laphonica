//
//  PikchurAccountViewController.m
//  modentica2
//
//  Created by Mark Bockenstedt on 3/11/09.
//  Copyright 2009 __MyCompanyName__. All rights reserved.
//

#import "PikchurAccountViewController.h"
#import "PikchurAPI.h"

@implementation PikchurAccountViewController

@synthesize serviceChooserButton, servicePickerView, servicePickerChoices, usernameTextField, passwordTextField, pickerVisible;

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

- (void) viewDidLoad
{
    [super viewDidLoad];
    
    // Attempt to retrieve stored credentials
    NSString *username = [[NSUserDefaults standardUserDefaults] stringForKey: @"pikchur_username"];
    NSString *password = [[NSUserDefaults standardUserDefaults] stringForKey: @"pikchur_password"];
    NSString *service =  [[NSUserDefaults standardUserDefaults] stringForKey: @"pikchur_service"];
    
    // Set current info
    usernameTextField.text = username;
    passwordTextField.text = password;
    
    if([service length] > 0)
    {
        [serviceChooserButton setTitle: service forState: UIControlStateNormal];
        [serviceChooserButton setTitle: service forState: UIControlStateSelected];
    }
    
    // Populate service options
    servicePickerChoices = [[NSArray arrayWithObjects: 
                                @"Pikchur", @"Identica", @"Twitter", @"Jaiku", @"Tumblr", 
                                @"FriendFeed", @"Plurk", @"Rejaw", @"Koornk", @"Brightkite", nil] retain];
    
    // Add save button
    UIBarButtonItem *saveButton = [[[UIBarButtonItem alloc] 
                                    initWithTitle: @"Save" 
                                    style: UIBarButtonItemStyleBordered 
                                    target: self
                                    action: @selector(saveSettings:)] autorelease]; 
    
    self.navigationItem.title = @"Pikchur Settings";
    self.navigationItem.rightBarButtonItem = saveButton;
}

- (void) saveSettings: (id) sender
{
    NSString *username = usernameTextField.text;
    NSString *password = passwordTextField.text;
    NSString *service = serviceChooserButton.currentTitle;
    
    // Verify they're all filled in
    if([username length] == 0 || [password length] == 0 || [service length] == 0)
    {
        // Show alert
        NSString *msg = @"You've gotta fill in your info";
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle: @"Error" message: msg  delegate:self cancelButtonTitle: nil otherButtonTitles: @"OK", nil];
        [alert show];	
        [alert release];
    }
    else
    {
        NSString *authKey = [[PikchurAPI alloc] auth: username password: password service: service];
        if(authKey)
        {
            // Store info into preferences
            NSUserDefaults *standardUserDefaults = [NSUserDefaults standardUserDefaults];
            if(standardUserDefaults)
            {
                [standardUserDefaults setObject: username forKey: @"pikchur_username"];
                [standardUserDefaults setObject: password forKey: @"pikchur_password"];
                [standardUserDefaults setObject: service forKey: @"pikchur_service"];
                [standardUserDefaults synchronize];
            }
            
            // go back
            [self.navigationController popViewControllerAnimated: YES];
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

- (void) showPicker: (id) sender
{
    if(!pickerVisible) // show picker
    {
        pickerVisible = YES;
        
        // Build the picker
        servicePickerView = [[UIPickerView alloc] initWithFrame: CGRectZero];
        CGSize pickerSize = [servicePickerView sizeThatFits: CGSizeZero];
        servicePickerView.frame = CGRectMake(0, 151, 320, pickerSize.height);
        [servicePickerView setDelegate: self];
        [servicePickerView setShowsSelectionIndicator: YES];
        servicePickerView.autoresizingMask = UIViewAutoresizingFlexibleWidth;
        [self.view addSubview: servicePickerView];
        
        // move to currently stored service
        NSString *currentService;
        if(![serviceChooserButton.currentTitle isEqualToString: @"Choose"] && [serviceChooserButton.currentTitle length] > 0)
            currentService = serviceChooserButton.currentTitle;
        else
            currentService = [[NSUserDefaults standardUserDefaults] objectForKey: @"pikchur_service"];
        
        
        NSInteger currentIndex = [servicePickerChoices indexOfObject: currentService];
        [servicePickerView selectRow: currentIndex inComponent: 0 animated: NO];
        
        // change title of button
        [serviceChooserButton setTitle: @"Press When Done" forState: UIControlStateNormal];
    }
    else // hide picker
    {
        pickerVisible = NO;
        
        [servicePickerView removeFromSuperview];
        
        NSString *chosenService = [servicePickerChoices objectAtIndex: [servicePickerView selectedRowInComponent: 0]];
        
        [serviceChooserButton setTitle: chosenService forState: UIControlStateNormal];
        [serviceChooserButton setTitle: chosenService forState: UIControlStateSelected];
    }
}

- (NSInteger) numberOfComponentsInPickerView: (UIPickerView *) pickerView
{
    return 1;
}

- (NSInteger) pickerView: (UIPickerView *) pickerView
 numberOfRowsInComponent: (NSInteger) compoonent
{
    return [servicePickerChoices count];
}

- (NSString *) pickerView: (UIPickerView *) pickerView
              titleForRow: (NSInteger) row
             forComponent: (NSInteger) component
{
    return [servicePickerChoices objectAtIndex: row];
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


- (void) dealloc
{
    [servicePickerChoices dealloc];
    [super dealloc];
}


@end
