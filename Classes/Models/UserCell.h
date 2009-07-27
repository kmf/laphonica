//
//  UserCell.h
//  modentica2
//
//  Created by Mark Bockenstedt on 3/2/09.
//  Copyright 2009 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>


@interface UserCell : UITableViewCell
{
    IBOutlet UILabel *fullNameLabel;
    IBOutlet UILabel *userInfoLabel;
    IBOutlet UIImageView *avatarImageView;
}

// Properties
@property (nonatomic, retain) IBOutlet UILabel *fullNameLabel;
@property (nonatomic, retain) IBOutlet UILabel *userInfoLabel;
@property (nonatomic, retain) IBOutlet UIImageView *avatarImageView;


// Methods
- (void) setData: (NSDictionary *) user forRow: (NSUInteger) row;
- (void) setProfileImage: (NSString *) profileImageURLString;

@end
