//
//  SettingsViewController.h
//  modentica2
//
//  Created by Mark Bockenstedt on 2/6/09.
//  Copyright 2009 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>


@interface AccountViewController : UIViewController
{
    IBOutlet UITextField *usernameTextField;
    IBOutlet UITextField *passwordTextField;
    IBOutlet UITextField *serverTextField;
    IBOutlet UITextField *updateNumberTextField;
}

@property (nonatomic, retain) UITextField *usernameTextField;
@property (nonatomic, retain) UITextField *passwordTextField;
@property (nonatomic, retain) UITextField *serverTextField;
@property (nonatomic, retain) UITextField *updateNumberTextField;

- (IBAction) saveSettings: (id) sender;


@end
