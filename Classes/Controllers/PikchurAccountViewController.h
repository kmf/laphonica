//
//  PikchurAccountViewController.h
//  modentica2
//
//  Created by Mark Bockenstedt on 3/11/09.
//  Copyright 2009 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>


@interface PikchurAccountViewController : UIViewController <UIPickerViewDelegate>
{
    IBOutlet UIButton *serviceChooserButton;
    IBOutlet UITextField *usernameTextField;
    IBOutlet UITextField *passwordTextField;
    
    UIPickerView *servicePickerView;
    NSArray *servicePickerChoices;
    BOOL pickerVisible;
}

@property (nonatomic, retain) UIButton *serviceChooserButton;
@property (nonatomic, retain) UITextField *usernameTextField;
@property (nonatomic, retain) UITextField *passwordTextField;

@property (nonatomic, retain) UIPickerView *servicePickerView;
@property (nonatomic, retain) NSArray *servicePickerChoices;
@property (nonatomic, assign) BOOL pickerVisible;

- (IBAction) showPicker: (id) sender;

@end
