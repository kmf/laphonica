//
//  StatusCell.m
//  modentica2
//
//  Created by Mark Bockenstedt on 2/20/09.
//  Copyright 2009 __MyCompanyName__. All rights reserved.
//

#import "StatusCell.h"
#import "StatusViewController.h"
#import "Utilities.h"

@implementation StatusCell

@synthesize avatarImageView, usernameLabel, statusLabel, statusTextView, timestampLabel, favoriteImageView;
@synthesize statusID;

- (id) initWithFrame: (CGRect) frame 
     reuseIdentifier: (NSString *) reuseIdentifier
{
    if(self = [super initWithFrame: frame reuseIdentifier: reuseIdentifier])
    {
        // Initialization code
    }
    
    return self;
}

- (NSString *) getCellID
{
	return statusID;
}

- (void) setData: (NSDictionary *) status
          forRow: (NSUInteger) row
{
    // Add the avatar
    avatarImageView.image = [UIImage imageWithContentsOfFile: @"profileImageSmall.png"];
    
    // Add the username
    usernameLabel.text = [[status objectForKey: @"user"] objectForKey: @"screen_name"];
    usernameLabel.font = [UIFont boldSystemFontOfSize: 14];
    
    // Add the status text
    statusLabel.text = [status objectForKey: @"text"];
    statusLabel.font = [UIFont systemFontOfSize: 11];
    
    // Add the timestamp
    timestampLabel.text = [[Utilities alloc] formatTimestamp:[status objectForKey: @"created_at"]];
    
    // Set the status ID for the cell
    statusID = [status objectForKey: @"id"];
    
    // Set favorite status
    if([[status objectForKey: @"favorited"] isEqualToString: @"true"])
        favoriteImageView.hidden = NO;
    
    // Color the cell
    NSUserDefaults *standardUserDefaults = [NSUserDefaults standardUserDefaults];
    NSString *loggedInUser = [standardUserDefaults objectForKey: @"username"];
    NSString *loggedInUserHandle = [NSString stringWithFormat: @"@%@", loggedInUser];
    
    if([self.usernameLabel.text isEqualToString: loggedInUser]) // My update
    {
        /*
        UIView *bg = [[UIView alloc] initWithFrame: self.frame];
        bg.backgroundColor = [[UIColor alloc] initWithRed: 0.73 green: 0.86 blue: 0.97 alpha: 1.0];
        self.backgroundView = bg;
        [bg release];
         */
        self.contentView.backgroundColor = [[UIColor alloc] initWithRed: 0.73 green: 0.86 blue: 0.97 alpha: 1.0];
    }
    else if([self.statusLabel.text rangeOfString: loggedInUserHandle].location != NSNotFound) // This is a reply to me
    {
        /*
        UIView *bg = [[UIView alloc] initWithFrame: self.frame];
        bg.backgroundColor = [[UIColor alloc] initWithRed: 0.77 green: 0.97 blue: 0.77 alpha: 1.0];
        self.backgroundView = bg;
        [bg release];
         */
        self.contentView.backgroundColor = [[UIColor alloc] initWithRed: 0.77 green: 0.97 blue: 0.77 alpha: 1.0];
    }
    else if(row % 2 == 0) // zebra stripe updates
    {
        /*
        UIView *bg = [[UIView alloc] initWithFrame: self.frame];
        bg.backgroundColor = [[UIColor alloc] initWithRed: 0.93 green: 0.95 blue: 0.97 alpha: 1.0];
        self.backgroundView = bg;
        [bg release];
         */
        self.contentView.backgroundColor = [[UIColor alloc] initWithRed: 0.93 green: 0.95 blue: 0.97 alpha: 1.0];
    }
}

- (void) setData: (NSDictionary *) status
          forRow: (NSUInteger) row
forDirectMessage: (BOOL) forDirectMessage
{
    // Add the avatar
    avatarImageView.frame = CGRectMake(6, 6, 48, 48);
    avatarImageView.image = [UIImage imageWithContentsOfFile: @"profileImageSmall.png"];
    
    // Add the username
    usernameLabel.text = [NSString stringWithFormat: @"to: %@", [[status objectForKey: @"recipient"] objectForKey: @"screen_name"]];
    usernameLabel.font = [UIFont boldSystemFontOfSize: 14];
    
    // Add the status text
    statusLabel.text = [status objectForKey: @"text"];
    statusLabel.font = [UIFont systemFontOfSize: 12];
    
    // Add the timestamp
    timestampLabel.text = [[Utilities alloc] formatTimestamp:[status objectForKey: @"created_at"]];
    
    // Set the status ID for the cell
    statusID = [status objectForKey: @"id"];
    
    if(row % 2 == 0) // zebra stripe updates
    {
        /*
        UIView *bg = [[UIView alloc] initWithFrame: self.frame];
        bg.backgroundColor = [[UIColor alloc] initWithRed: 0.93 green: 0.95 blue: 0.97 alpha: 1.0];
        self.backgroundView = bg;
        [bg release];
         */
        self.contentView.backgroundColor = [[UIColor alloc] initWithRed: 0.93 green: 0.95 blue: 0.97 alpha: 1.0];
    }
}

- (void) setData: (NSDictionary *) status
          forRow: (NSUInteger) row
       forSearch: (BOOL) forSearch
{
    // Add the avatar
    avatarImageView.frame = CGRectMake(6, 6, 48, 48);
    avatarImageView.image = [UIImage imageWithContentsOfFile: @"profileImageSmall.png"];
    
    // Add the username
    usernameLabel.text = [status objectForKey: @"from_user"];
    usernameLabel.font = [UIFont boldSystemFontOfSize: 14];
    
    // Add the status text
    statusLabel.text = [status objectForKey: @"text"];
    statusLabel.font = [UIFont systemFontOfSize: 12];
    
    // Add the timestamp
    timestampLabel.text = [[Utilities alloc] formatTimestamp: [status objectForKey: @"created_at"]];
    
    // Set the status ID for the cell
    statusID = [status objectForKey: @"id"];
    
    if(row % 2 == 0) // zebra stripe updates
        self.contentView.backgroundColor = [[UIColor alloc] initWithRed: 0.93 green: 0.95 blue: 0.97 alpha: 1.0];
}

- (void) setProfileImage: (NSString *) profileImageURLString
{
    avatarImageView.image = [[Utilities alloc] getCachedImage: profileImageURLString defaultToSmall: YES];
}


- (void) setSelected: (BOOL)selected
            animated: (BOOL) animated
{

    [super setSelected: selected animated: animated];
    
    /*
    if(selected)
    {
        StatusViewController *statusViewController = [[StatusViewController alloc] initWithNibName: @"StatusView" bundle: nil withStatusID: self.statusID];
        [self.navigationController pushViewController: statusViewController];
        [statusViewController release];
    }
     */
}

- (void) dealloc
{
    [super dealloc];
}


@end
