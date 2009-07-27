//
//  UserCell.m
//  modentica2
//
//  Created by Mark Bockenstedt on 3/2/09.
//  Copyright 2009 __MyCompanyName__. All rights reserved.
//

#import "UserCell.h"
#import "Utilities.h"

#define TMP [NSHomeDirectory() stringByAppendingPathComponent: @"tmp"]


@implementation UserCell

@synthesize fullNameLabel, userInfoLabel, avatarImageView;

- (id) initWithFrame: (CGRect) frame
     reuseIdentifier: (NSString *) reuseIdentifier
{
    if (self = [super initWithFrame: frame reuseIdentifier: reuseIdentifier])
    {
    }
    
    return self;
}

- (void) setData: (NSDictionary *) user
          forRow: (NSUInteger) row
{
    // Add the avatar
    self.avatarImageView.image = [UIImage imageNamed: @"profileImageSmall.png"];
    
    // Add the user's name
    self.fullNameLabel.text = [user objectForKey: @"name"];
    self.fullNameLabel.font = [UIFont boldSystemFontOfSize: 16];
    
    // Add the user's info
    NSString *userInfo = [NSString stringWithFormat: @"%@ / %@ followers", 
                            [user objectForKey: @"screen_name"], 
                            [user objectForKey: @"followers_count"]];
    self.userInfoLabel.text = userInfo;
    self.userInfoLabel.font = [UIFont systemFontOfSize: 14];
    
    if(row % 2 == 0) // zebra stripe rows
    {
        UIView *bg = [[UIView alloc] initWithFrame: self.frame];
        bg.backgroundColor = [[UIColor alloc] initWithRed: 0.93 green: 0.95 blue: 0.97 alpha: 1.0];
        self.backgroundView = bg;
        [bg release];
    }
}

- (void) setProfileImage: (NSString *) profileImageURLString
{
    // Fetch from TMP
    NSString *filename = [profileImageURLString stringByReplacingOccurrencesOfString: @"http://avatar.identi.ca/" withString: @""];
    NSString *uniquePath = [TMP stringByAppendingPathComponent: filename];
    if([[NSFileManager defaultManager] fileExistsAtPath: uniquePath])
    {
        //UIImage *image = [[Utilities alloc] makeRoundCornerImage: [UIImage imageWithContentsOfFile: uniquePath]];
        UIImage *image = [UIImage imageWithContentsOfFile: uniquePath];
        
        self.avatarImageView.image = image;
    }
}


- (void)setSelected:(BOOL)selected animated:(BOOL)animated {

    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}


- (void)dealloc {
    [super dealloc];
}


@end
