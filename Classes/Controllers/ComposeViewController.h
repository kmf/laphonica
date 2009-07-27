//
//  ComposeViewController.h
//  modentica2
//
//  Created by Mark Bockenstedt on 2/21/09.
//  Copyright 2009 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "LoadingView.h"


@interface ComposeViewController : UIViewController <UITextViewDelegate, UIActionSheetDelegate, UIPickerViewDelegate>
{
    IBOutlet UITextView *statusTextView;
    IBOutlet UILabel *characterCountLabel;
    IBOutlet UILabel *statusTextLabel;
    IBOutlet UIBarButtonItem *clearButtonItem;
    IBOutlet UIBarButtonItem *cameraButtonItem;
    IBOutlet UIToolbar *toolbar;
    UIPickerView *imagePickerView;
    
    NSString *statusUpdateText;
    NSString *replyToStatusID;
    NSString *replyToUserName;
    int actionSheetUsed;
    LoadingView *loadingView;
    UIImage *candidateImage;
}

@property (nonatomic, assign) UITextView *statusTextView;
@property (nonatomic, retain) UILabel *characterCountLabel;
@property (nonatomic, retain) UILabel *statusTextLabel;
@property (nonatomic, retain) UIBarButtonItem *clearButtonItem;
@property (nonatomic, retain) UIBarButtonItem *cameraButtonItem;
@property (nonatomic, retain) UIPickerView *imagePickerView;
@property (nonatomic, retain) UIToolbar *toolbar;

@property (nonatomic, retain) NSString *statusUpdateText;
@property (nonatomic, retain) NSString *replyToStatusID;
@property (nonatomic, retain) NSString *replyToUserName;
@property (nonatomic, assign) int actionSheetUsed;
@property (nonatomic, retain) LoadingView *loadingView;
@property (nonatomic, retain) UIImage *candidateImage;

- (IBAction) sendUpdate: (id) sender;
- (IBAction) goBack: (id) sender;
- (IBAction) clearTextBox: (id) sender;
- (IBAction) selectImage: (id) sender;

- (void) prefillText: (NSString *) text;
- (void) setReplyToStatusID: (NSString *) statusID userName: (NSString *) userName;

- (void) beginImageUpload;
- (void) uploadImage;
- (void) finishUploadingImage;

@end