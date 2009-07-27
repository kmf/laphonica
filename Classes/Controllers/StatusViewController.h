//
//  StatusViewController.h
//  modentica2
//
//  Created by Mark Bockenstedt on 2/20/09.
//  Copyright 2009 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface StatusViewController : UIViewController <UIActionSheetDelegate, UIWebViewDelegate>
{
    NSDictionary *status;
    NSString *statusID;
    NSString *username;
    BOOL *isFavorite;
    NSString *inReplyToID;
    NSString *clientURL;
    NSMutableArray *links;
    
    IBOutlet UILabel *fullNameLabel;
    IBOutlet UILabel *screenNameLabel;
    IBOutlet UIImageView *avatarImageView;
    IBOutlet UIWebView *statusWebView;
    IBOutlet UILabel *timestampLabel;
    IBOutlet UIButton *clientButton;
    IBOutlet UIButton *inReplyToButton;
    
    IBOutlet UIBarButtonItem *retweetButton;
    IBOutlet UIBarButtonItem *replyButton;
    IBOutlet UIBarButtonItem *deleteButton;
    IBOutlet UIButton *favoriteButton;
    IBOutlet UIButton *goToProfileButton;
}

// Properties
@property (nonatomic, retain) NSDictionary *status;
@property (nonatomic, retain) NSString *statusID;
@property (nonatomic, retain) NSString *username;
@property (nonatomic, assign) BOOL *isFavorite;
@property (nonatomic, assign) NSString *inReplyToID;
@property (nonatomic, retain) NSString *clientURL;
@property (nonatomic, retain) NSMutableArray *links;

@property (nonatomic, retain) UILabel *fullNameLabel;
@property (nonatomic, retain) UILabel *screenNameLabel;
@property (nonatomic, retain) UIImageView *avatarImageView;
@property (nonatomic, retain) UIWebView *statusWebView;
@property (nonatomic, retain) UILabel *timestampLabel;
@property (nonatomic, retain) UIButton *clientButton;
@property (nonatomic, retain) UIButton *inReplyToButton;

@property (nonatomic, retain) UIBarButtonItem *retweetButton;
@property (nonatomic, retain) UIBarButtonItem *replyButton;
@property (nonatomic, retain) UIBarButtonItem *deleteButton;
@property (nonatomic, retain) UIButton *favoriteButton;
@property (nonatomic, retain) UIButton *goToProfileButton;


// Methods
- (IBAction) goToProfile: (id) sender;
- (IBAction) composeRetweet;
- (IBAction) composeReply;
- (IBAction) toggleFavoriteStatus: (id) sender;
- (IBAction) viewReply: (id) sender;
- (IBAction) loadWebPage: (id) sender;
- (IBAction) deleteStatusUpdate: (id) sender;

- (void) setCellID: (NSString *) cellID;
- (id) initWithNibName: (NSString *) nibNameOrNil bundle: (NSBundle *) nibBundleOrNil showStatus: (NSString *) statusIDToShow;
- (void) updateFavoriteStatus: (BOOL) setAsFavorite;
- (void) openWebView: (NSString *) href;
- (void) parseTextForLinks: (NSString *) statusText;

@end
