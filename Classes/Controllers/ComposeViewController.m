//
//  ComposeViewController.m
//  modentica2
//
//  Created by Mark Bockenstedt on 2/21/09.
//  Copyright 2009 __MyCompanyName__. All rights reserved.
//

#import "ComposeViewController.h"
#import "LoadingView.h"

#import "IdenticaAPI.h"
#import "PikchurAPI.h"


@implementation ComposeViewController

@synthesize statusTextView, characterCountLabel, statusTextLabel, clearButtonItem, cameraButtonItem, imagePickerView;
@synthesize statusUpdateText, replyToStatusID, replyToUserName, actionSheetUsed, loadingView, candidateImage, toolbar;

// The designated initializer. Override to perform setup that is required before the view is loaded.
- (id) initWithNibName: (NSString *) nibNameOrNil
                bundle: (NSBundle *) nibBundleOrNil
{
    if (self = [super initWithNibName: nibNameOrNil bundle: nibBundleOrNil])
    {
        // Add send button
        UIBarButtonItem *sendButton = [[[UIBarButtonItem alloc] 
                                        initWithTitle: @"Send" 
                                        style: UIBarButtonItemStyleDone
                                        target: self
                                        action: @selector(sendUpdate:)] autorelease]; 
        self.navigationItem.rightBarButtonItem = sendButton;
        self.navigationItem.rightBarButtonItem.enabled = NO;
        
        // Change left bar button
        UIBarButtonItem *cancelButton = [[UIBarButtonItem alloc] 
                                         initWithTitle: @"Cancel" 
                                         style: UIBarButtonItemStylePlain
                                         target: self
                                         action: @selector(goBack:)];
        
        self.navigationItem.leftBarButtonItem = cancelButton;
        [cancelButton release];
        
        // Change title
        self.navigationItem.title = @"New Update";
        
        // Set up some vars
        self.statusUpdateText = @"";
        self.replyToUserName = @"";
        self.actionSheetUsed = 0;
        
        // Set delegate
        [statusTextView setDelegate: self];
        statusTextView.autocapitalizationType = UITextAutocapitalizationTypeNone;
    }
    
    return self;
}

// Implement viewDidLoad to do additional setup after loading the view, typically from a nib.
- (void) viewDidLoad
{
    [super viewDidLoad];
    
    // Is there a saved draft?
    NSString *savedDraft = [[NSUserDefaults standardUserDefaults] objectForKey: @"draft"];
    
    // If the text was prefilled, use that first
    if([self.statusUpdateText length] > 0)
        statusTextView.text = self.statusUpdateText;
    
    // Recall the saved draft
    else if([savedDraft length] > 0)
        statusTextView.text = savedDraft;
    
    // Pop up the keyboard
    [statusTextView becomeFirstResponder];
    
    // Update character counter
    int charactersRemaining = 140 - [statusTextView.text length];
    characterCountLabel.text = [NSString stringWithFormat: @"%d", charactersRemaining];
    
    // enable the send button
    if(charactersRemaining < 140)
        self.navigationItem.rightBarButtonItem.enabled = YES;
    
    // Push the cursor to the end
    
    // Make sure the toolbar is visible - it doesn't show up when replying
    toolbar.frame = CGRectMake(0, 250, 320, 44);
}

- (void) textViewDidChange: (UITextView *) textView
{
    int length = [statusTextView.text length];
    
    length = 140 - length;
    if(length == 140 || length < 0)
        self.navigationItem.rightBarButtonItem.enabled = NO;
    else
        self.navigationItem.rightBarButtonItem.enabled = YES;
    
    // Update the character counter
    characterCountLabel.text = [NSString stringWithFormat: @"%d", length];
    
    // Scroll to top
    [statusTextView setContentOffset: CGPointMake(0, 0) animated: NO];
}


- (void) sendUpdate: (id) sender
{
    // Let's post something
    NSString *statusText = statusTextView.text;
    NSLog(@"Sending update \"%@\"", statusText);
    
    NSString *replyID = [self.replyToStatusID stringValue];
    
    // Length is controlled by the enabling/disabling of the send button in textViewDidChange
    NSDictionary *newStatus = [[IdenticaAPI alloc] UpdateStatus: statusText inReplyTo: replyID];
    if(newStatus)
    {
        // Add it to the parent
        [[NSNotificationCenter defaultCenter] postNotificationName: @"messageComposed" object: newStatus];
        
        // Go back
        [self.navigationController popViewControllerAnimated: YES];
    }
    else
    {
        // Display an alert
        NSString *msg = @"Unable to send update, please try again later.";
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle: @"Error" message: msg  delegate: self cancelButtonTitle: nil otherButtonTitles: @"OK", nil];
        [alert show];	
        [alert release];
    }
}

- (void) goBack: (id) sender
{
    // If there's text, ask the user if they want to save it
    if([statusTextView.text length] > 0)
    {
        self.actionSheetUsed = 1;
        // Push UIActionSheet
        UIActionSheet *actionSheet = [[UIActionSheet alloc]
                                      initWithTitle: nil
                                      delegate: self
                                      cancelButtonTitle: @"Cancel"
                                      destructiveButtonTitle: nil
                                      otherButtonTitles: @"Save Draft", @"Don't Save", nil];
        [actionSheet setDelegate: self];
        [actionSheet showInView: self.view];
        [actionSheet release];
    }
    else
    {
        NSUserDefaults *standardUserDefaults = [NSUserDefaults standardUserDefaults];
        [standardUserDefaults setObject: @"" forKey: @"draft"];
        
        // Go back
        [self.navigationController popViewControllerAnimated: YES];
    }
}

- (void) clearTextBox: (id) sender
{
    self.statusTextView.text = @"";
}

- (void) selectImage: (id) sender
{
    // Bring up a UIActionSheet
    UIActionSheet *actionSheet;
    
    UIDevice *device = [UIDevice alloc];
    
    if([device.model rangeOfString: @"iPhone"].location != NSNotFound) // for iPhones
    {
        actionSheet = [[UIActionSheet alloc]
                       initWithTitle: @"Choose Source"
                        delegate: self
                        cancelButtonTitle: @"Cancel"
                        destructiveButtonTitle: nil
                        otherButtonTitles: @"Take New Photo", @"Choose Existing Photo", nil];
    }
    else // For iPods
    {
        actionSheet = [[UIActionSheet alloc]
                       initWithTitle: @"Choose Source"
                       delegate: self
                       cancelButtonTitle: @"Cancel"
                       destructiveButtonTitle: nil
                       otherButtonTitles: @"Choose Existing Photo", nil];
    }

    [actionSheet showInView: self.view];
    [actionSheet release];
}

- (void) imagePickerController: (UIImagePickerController *) picker
        didFinishPickingImage: (UIImage *) image
                  editingInfo: (NSDictionary *) editingInfo
{
    [[picker parentViewController] dismissModalViewControllerAnimated: YES];
    [picker release];
    
    self.candidateImage = image;
    
    [self beginImageUpload];
    
    [statusTextView becomeFirstResponder];
}

- (void) beginImageUpload
{
    self.loadingView = [[LoadingView alloc] initWithTitle: @"Uploading Image" message: @"Please wait..."];
    [self.loadingView startAnimating];
    [NSThread detachNewThreadSelector: @selector(uploadImage) toTarget: self withObject: nil];
}

- (void) uploadImage
{
    NSAutoreleasePool *pool = [[NSAutoreleasePool alloc] init];
    [self performSelectorOnMainThread: @selector(finishUploadingImage) withObject: nil waitUntilDone: NO];
    [pool release];
}

- (void) finishUploadingImage
{
    NSLog(@"uploading image");
    
    // start upload
    NSDictionary *result = [[PikchurAPI alloc] post: self.candidateImage];
    
    [self.loadingView dismissWithClickedButtonIndex: 0 animated: YES];
    [self.loadingView release];
    
    NSLog(@"upload result: %@", result);
    if([[result objectForKey: @"type"] isEqualToString: @"ERROR"])
    {
        // Display an alert
        NSString *msg = @"Unable to upload image, please try again later.";
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle: @"Error" message: msg  delegate: self cancelButtonTitle: nil otherButtonTitles: @"OK", nil];
        [alert show];	
        [alert release];
    }
    else
    {
        // save the text so when the view reappears, it'll put in the text
        NSString *pikchurURL = [[result objectForKey: @"post"] objectForKey: @"url"];
        
        NSString *newStatus = [NSString stringWithFormat: @"%@ %@", statusTextView.text, pikchurURL];
        
        NSUserDefaults *standardUserDefaults = [NSUserDefaults standardUserDefaults];
        [standardUserDefaults setObject: newStatus forKey: @"draft"];
        [standardUserDefaults synchronize];
    }
}

- (void) imagePickerControllerDidCancel: (UIImagePickerController *) picker
{
    [[picker parentViewController] dismissModalViewControllerAnimated: YES];
    [picker release];
}

- (void) prefillText: (NSString *) text
{
    self.statusUpdateText = text;
}

- (void) setReplyToStatusID: (NSString *) statusID
                   userName: (NSString *) userName
{
    NSLog(@"Setting reply parameters: %@, %@", statusID, userName);
    self.replyToStatusID = statusID;
    self.replyToUserName = userName;
}

- (void) actionSheet: (UIActionSheet *) actionSheet
clickedButtonAtIndex: (NSInteger) buttonIndex
{
    if([actionSheet.title isEqualToString: @"Choose Source"])
    {
        NSString *buttonTitle = (NSString *)[actionSheet buttonTitleAtIndex: buttonIndex];
        
        if([buttonTitle isEqualToString: @"Take New Photo"])
        {
            UIImagePickerController *picker = [[UIImagePickerController alloc]init];
            picker.sourceType = UIImagePickerControllerSourceTypeCamera;
            picker.allowsImageEditing = NO;
            picker.delegate = self;
            
            [self presentModalViewController: picker animated:YES];
        }
        else if([buttonTitle isEqualToString: @"Choose Existing Photo"])
        {
            UIImagePickerController *picker = [[UIImagePickerController alloc]init];
            picker.sourceType = UIImagePickerControllerSourceTypePhotoLibrary;
            picker.allowsImageEditing = NO;
            picker.delegate = self;
            
            [self presentModalViewController: picker animated:YES];
        }
    }
    else
    {
        NSString *buttonTitle = (NSString *)[actionSheet buttonTitleAtIndex: buttonIndex];
        NSString *enteredText = statusTextView.text;
    
        if([buttonTitle isEqualToString: @"Save Draft"])
        {
            NSUserDefaults *standardUserDefaults = [NSUserDefaults standardUserDefaults];
            [standardUserDefaults setObject: enteredText forKey: @"draft"];
            [standardUserDefaults synchronize];
        
            [self.navigationController popViewControllerAnimated: YES];
        }
        else if([buttonTitle isEqualToString: @"Don't Save"])
        {
            NSUserDefaults *standardUserDefaults = [NSUserDefaults standardUserDefaults];
            [standardUserDefaults setObject: @"" forKey: @"draft"];
            
            [self.navigationController popViewControllerAnimated: YES];
        }
    }
}

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


- (void) viewDidAppear: (BOOL) animated
{
    NSInteger length = [statusTextView.text length];
    statusTextView.selectedRange = NSMakeRange(length, 0);
    
    [statusTextView becomeFirstResponder];
}


- (void) didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning]; // Releases the view if it doesn't have a superview
    // Release anything that's not essential, such as cached data
}


- (void) dealloc
{
    [super dealloc];
}


@end
