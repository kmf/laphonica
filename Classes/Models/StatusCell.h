//
//  StatusCell.h
//  modentica2
//
//  Created by Mark Bockenstedt on 2/20/09.
//  Copyright 2009 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>


@interface StatusCell : UITableViewCell
{
    IBOutlet UILabel *usernameLabel;
    IBOutlet UILabel *statusLabel;
    IBOutlet UITextView *statusTextView;
    IBOutlet UILabel *timestampLabel;
    IBOutlet UIImageView *avatarImageView;
    IBOutlet UIImageView *favoriteImageView;
    
    NSString *statusID;
}

// Properties
@property (nonatomic, retain) IBOutlet UILabel *usernameLabel;
@property (nonatomic, retain) IBOutlet UILabel *statusLabel;
@property (nonatomic, retain) IBOutlet UITextView *statusTextView;
@property (nonatomic, retain) IBOutlet UILabel *timestampLabel;
@property (nonatomic, retain) IBOutlet UIImageView *avatarImageView;
@property (nonatomic, retain) UIImageView *favoriteImageView;

@property (nonatomic, assign) NSString *statusID;

// Methods
- (NSString *) getCellID;
- (void) setData: (NSDictionary *) status forRow: (NSUInteger) row;
- (void) setData: (NSDictionary *) status forRow: (NSUInteger) row forDirectMessage: (BOOL) forDirectMessage;
- (void) setData: (NSDictionary *) status forRow: (NSUInteger) row forSearch: (BOOL) forSearch;
- (void) setProfileImage: (NSString *) profileImageURLString;

@end
