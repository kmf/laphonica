//
//  GoToUserViewController.h
//  modentica2
//
//  Created by Mark Bockenstedt on 2/6/09.
//  Copyright 2009 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>


@interface GoToUserViewController : UIViewController <UITextFieldDelegate>
{
    IBOutlet UITextField *usernameField;
}

@property (nonatomic, retain) UITextField *usernameField;

- (IBAction) GoToUser: (id) sender;

@end
