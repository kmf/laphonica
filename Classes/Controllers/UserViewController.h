//
//  UserViewController.h
//  modentica2
//
//  Created by Mark Bockenstedt on 2/6/09.
//  Copyright 2009 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UserViewController : UIViewController <UITableViewDelegate>
{
    NSDictionary *userProfile;
    NSString *screenName;
    
    IBOutlet UIImageView *profileImageView;
    IBOutlet UILabel *usernameLabel;
    IBOutlet UILabel *locationLabel;
    IBOutlet UILabel *descriptionLabel;
    IBOutlet UIButton *websiteButton;
    IBOutlet UILabel *followersLabel;
    IBOutlet UILabel *memberSinceLabel;
    
    IBOutlet UITableView *userActions;
    IBOutlet UIButton *subscribeButton;
    IBOutlet UIButton *unsubscribeButton;
    IBOutlet UINavigationBar *titleBar;
}

@property (nonatomic, retain) NSDictionary *userProfile;
@property (nonatomic, assign) NSString *screenName;

@property (nonatomic, retain) UIImageView *profileImageView;
@property (nonatomic, retain) UILabel *usernameLabel;
@property (nonatomic, retain) UILabel *locationLabel;
@property (nonatomic, retain) UILabel *descriptionLabel;
@property (nonatomic, retain) UIButton *websiteButton;
@property (nonatomic, retain) UILabel *followersLabel;
@property (nonatomic, retain) UILabel *memberSinceLabel;

@property (nonatomic, retain) UITableView *userActions;
@property (nonatomic, retain) UIButton *subscribeButton;
@property (nonatomic, retain) UIButton *unsubscribeButton;
@property (nonatomic, retain) UINavigationBar *titleBar;

- (IBAction) UpdateSubscription: (id) sender;
- (IBAction) subscribe: (id) sender;
- (IBAction) unsubscribe: (id) sender;
- (IBAction) loadWebPage: (id) sender;

- (id) initWithNibName: (NSString *) nibNameOrNil bundle: (NSBundle *) nibBundleOrNil showUser: (NSString *) username;
- (id) initWithNibName: (NSString *) nibNameOrNil bundle: (NSBundle *) nibBundleOrNil withUser: (NSDictionary *) userInfo;

@end
