//
//  api.h
//  Modentica
//
//  Created by Mark Bockenstedt on 1/28/09.
//  Copyright 2009 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface IdenticaAPI : NSObject
{
    NSString* username;
    NSString* password;
    NSString* userID;
    NSString* apiBase;
}

// Properties
@property (retain) NSString* username;
@property (retain) NSString* password;
@property (retain) NSString* userID;
@property (retain) NSString* apiBase;

// General Methods
- (BOOL) verifySavedCredentials;
- (BOOL) loginAs: (NSString *) user withPass: (NSString *) passwd onServer: (NSString *) server;

// Status Methods
- (NSMutableArray *) GetPublicTimeline: (NSInteger) page_number;
- (NSMutableArray *) GetFriendsTimeline: (NSInteger) page_number since_id: (NSInteger) since_id;
- (NSMutableArray *) GetUserTimeline: (NSString*) user page: (NSInteger) page_number since_id: (NSInteger) since_id;
- (NSDictionary *) ShowStatus: (NSString *) status_id;
- (NSDictionary *) UpdateStatus: (NSString *) status inReplyTo: (NSString *) reply_to_id;
- (NSArray *) GetReplies: (NSInteger) page_number since_id: (NSInteger) since_id;
- (BOOL) DestroyStatus: (NSString *) status_id;

// User Methods
- (NSMutableArray *) GetFriends: (NSString *) user page: (NSInteger) page_number;
- (NSMutableArray *) GetFollowers: (NSString *) user page: (NSInteger) page_number;
- (NSDictionary *) GetUser: (NSString *) user;
- (NSString *) GetUserIDFromUsername: (NSString *) uname;
- (NSString *) GetUsernameFromUserID: (int) user_id;

// Direct Message Methods
- (NSMutableArray *) GetInbox: (NSInteger) page_number since_id: (NSInteger) since_id;
- (NSMutableArray *) GetOutbox: (NSInteger) page_number since_id: (NSInteger) since_id;

// Friendship Methods
- (BOOL) FriendshipExists: (NSString *) recipient;
- (BOOL) SubscribeUser: (NSString*) recipient;
- (BOOL) UnsubscribeUser: (NSString*) recipient;

// Favorite Methods
- (NSMutableArray *) GetFavorites: (NSString *) user page: (NSInteger) page_number;
- (BOOL) AddFavorite: (NSString *) status_id;
- (BOOL) DestroyFavorite: (NSString *) status_id;

// Search Methods
- (NSMutableArray *) Search: (NSString *) query page: (NSInteger) page_number;

// JSON Methods
- (NSMutableArray *) post: (NSString *) action args: (NSString *) args;
- (NSMutableArray *) get: (NSString *) action args: (NSString *) args;

@end
