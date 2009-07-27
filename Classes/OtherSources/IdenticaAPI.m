//
//  api.m
//  Modentica
//
//  Created by Mark Bockenstedt on 1/28/09.
//  Copyright 2009 __MyCompanyName__. All rights reserved.
//

#import "IdenticaAPI.h"
#import "JSON/JSON.h"
#import "StringUtil.h"

@implementation IdenticaAPI

@synthesize username, password, userID, apiBase;


- (BOOL) verifySavedCredentials
{
    NSDictionary *retval = (NSDictionary *)[self post: @"/account/verify_credentials.json" args: @""];
    if([retval objectForKey: @"error"])
        return false;
    else
        return true;
}

- (BOOL) loginAs: (NSString*) user
        withPass: (NSString*) passwd
        onServer: (NSString*) server
{
    // Format request
    NSString *requestBase = [NSString stringWithFormat: @"https://%@/api/account/verify_credentials.json", server];
    NSMutableURLRequest *request = [[NSMutableURLRequest alloc] initWithURL: [NSURL URLWithString: requestBase]];
    
    // Add Authentication
    NSString *auth = [NSString stringWithFormat: @"%@:%@", user, passwd];
    NSString* basicauth = [NSString stringWithFormat: @"Basic %@", [NSString base64encode: auth]];
    [request setValue: basicauth forHTTPHeaderField: @"Authorization"];
    [request setHTTPMethod: @"POST"];
    
    // Perform request and get JSON back as an NSData oject
    NSData *response = [NSURLConnection sendSynchronousRequest: request returningResponse: NULL error: NULL];
    
    // Get JSON as an NSString from NSData Response
    NSString *json_string = [[NSString alloc] initWithData:response encoding: NSUTF8StringEncoding];
    
    // Parse the JSON response into an object
    NSDictionary *retval = [[SBJSON alloc] objectWithString: json_string error: nil];
    NSLog(@"retval: %@", retval);
    
    if([retval objectForKey: @"authorized"])
    {
        self.username = user;
        self.password = passwd;
        self.apiBase = [NSString stringWithFormat:@"%@/api", server];
        
        return true;
    }
    
    return false;
}



/*
 ###################################################
 
 STATUS METHODS
  - GetPublicTimeline
  - GetFriendsTimeline
  - GetUserTimeline
  - ShowStatus
  - UpdateStatus
  - GetReplies
  - DestroyStatus

 ###################################################
 */

/*
 * Send a request for the public timeline
 * Returns the last 20 updates by default
 *
 * @param int page_number
 * @return NSArray
 */
- (NSMutableArray *) GetPublicTimeline: (NSInteger) page_number
{
    NSString *postArgs = [NSString stringWithFormat: @"?page=%i", page_number];
    
    return [self get: @"/statuses/public_timeline.json" args: postArgs];
}

/*
 * Send a request for the timeline of authenticating user's friends
 *
 * @param int count, int since_id, int page_number
 * @return NSArray
 */
- (NSMutableArray *) GetFriendsTimeline: (NSInteger) page_number
                               since_id: (NSInteger) since_id
{
    NSString *count = [[NSUserDefaults standardUserDefaults] objectForKey: @"initialLoad"];
    NSString *postArgs = [NSString stringWithFormat: @"count=%@", count];
    
    if(page_number > 1)
        postArgs = [postArgs stringByAppendingString:[NSString stringWithFormat:@"&page=%i",page_number]];
    
    if(since_id > 0)
        postArgs = [postArgs stringByAppendingString:[NSString stringWithFormat:@"&since_id=%i", since_id]];
    
    return (NSMutableArray *)[self post: @"/statuses/friends_timeline.json" args: postArgs];
}

/*
 * Send a request for the timeline of a specified user
 * 
 * @param NSString user, int count, int since_id, int page_number
 * @return NSArray
 */
- (NSMutableArray *) GetUserTimeline: (NSString*) user
                                page: (NSInteger) page_number
                            since_id: (NSInteger) since_id 
{
    NSString* url = [NSString stringWithFormat: @"/statuses/user_timeline/%@.json", user];
    
    NSString *count = [[NSUserDefaults standardUserDefaults] objectForKey: @"initialLoad"];
    NSString *postArgs = [NSString stringWithFormat: @"count=%@", count];
    
    if(page_number > 1)
        postArgs = [postArgs stringByAppendingString: [NSString stringWithFormat:@"&page=%i", page_number]];
    
    if(since_id > 0)
        postArgs = [postArgs stringByAppendingString: [NSString stringWithFormat:@"&since_id=%i", since_id]];
    
    return [self post: url args: postArgs];
}

/*
 * Returns a single status, specified by the id parameter.  The status's author will be returned inline.
 *
 * @param NSString status_id
 * @return NSArray
 */
- (NSDictionary *) ShowStatus: (NSString *) status_id
{
    NSString* url = [NSString stringWithFormat: @"/statuses/show/%@.json", status_id];
    return (NSDictionary *)[self get: url args: @""];
}

/*
 * Updates the authenticating user's status. Request must be a POST.
 * A status update with text identical to the authenticating user's current status will be ignored.
 *
 * @param NSString status*, int reply_to_id
 * @return NSDictionary
 */
- (NSDictionary *) UpdateStatus: (NSString *) status
                 inReplyTo: (NSString *) reply_to_id
{
    // URL Encode the status
    NSString *encodedStatus = [status stringByAddingPercentEscapesUsingEncoding: NSASCIIStringEncoding];
    //NSString *encodedStatus = [status stringByAddingPercentEscapesUsingEncoding: NSUTF8StringEncoding];
    
    NSString *postArgs = [@"status=" stringByAppendingString: encodedStatus];
    
    if([reply_to_id length] > 0)
    {
        NSString *reply_to_string = [NSString stringWithFormat: @"&in_reply_to_status_id=%@", reply_to_id];
        postArgs = [postArgs stringByAppendingString: reply_to_string];
    }
    
    // Add app signature
    postArgs = [postArgs stringByAppendingString: @"&source=modentica"];
    
    NSDictionary *retval = (NSDictionary *)[self post: @"/statuses/update.json" args: postArgs];
    
    // Figure out if it succeeded
    if([retval objectForKey: @"id"])
    {
        return retval;
    }
    else
    {
            /*
        NSLog(@"Failed to send update");
        NSString *title = @"Error";
        NSString *message = @"Something bad happened and we couldn't post your update";
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle: title message: message delegate: self cancelButtonTitle:nil otherButtonTitles:@"OK",nil];
        [alert show];
             */
        return false;
    }
}

/*
 * Returns the 20 most recent @replies (status updates prefixed with @username) for the authenticating user.
 *
 * @return NSArray
 */
- (NSArray *) GetReplies: (NSInteger) page_number
                since_id: (NSInteger) since_id
{
    NSString *count = [[NSUserDefaults standardUserDefaults] objectForKey: @"initialLoad"];
    NSString *postArgs = [NSString stringWithFormat: @"count=%@", count];
    
    if(page_number > 1)
        postArgs = [postArgs stringByAppendingString:[NSString stringWithFormat:@"&page=%i",page_number]];
    
    if(since_id > 0)
        postArgs = [postArgs stringByAppendingString:[NSString stringWithFormat:@"&since_id=%i", since_id]];
    
    return [self post: @"/statuses/replies.json" args: postArgs];
    
}

/*
 * Destroys the status specified by the required ID parameter.  The authenticating user must be the author of the specified status.
 *
 * @param NSString status_id*
 * @return BOOL
 */
- (BOOL) DestroyStatus: (NSString *) status_id
{
    status_id = nil;
    NSString* url = [NSString stringWithFormat: @"/statuses/destroy/%@.json", status_id];
    
    NSDictionary *retval = (NSDictionary *)[self post: url args: @""];
    
    // Determine success
    if([retval objectForKey: @"text"])
       return true;
    else
        return false;
}



/*
 ###################################################
 
 USER METHODS
  - GetFriends
  - GetFollowers
  - GetUser
  - GetUserIDFromUsername
 
 ###################################################
 */

/*
 * Returns the authenticating user's friends, each with current status inline.
 * It's also possible to request another user's recent friends list via the id parameter.
 *
 * @param NSString user, int page_number
 * @return NSMutableArray
 */
- (NSMutableArray *) GetFriends: (NSString*) user
                           page: (NSInteger) page_number
{
    NSString *url = [NSString stringWithFormat: @"/statuses/friends/%@.json", user];
    NSString *postArgs = [NSString stringWithFormat: @"?page=%i", page_number];
    
    return [self get: url args: postArgs];
}

/*
 * Returns the authenticating user's followers, each with current status inline.
 *
 * @param NSString user, int page_number
 * @return NSMutableArray
 */
- (NSMutableArray *) GetFollowers: (NSString *) user
                             page: (NSInteger) page_number
{
    NSString* url = [NSString stringWithFormat: @"/statuses/followers/%@.json", user];
    NSString *postArgs = [NSString stringWithFormat: @"?page=%i", page_number];
    
    return [self get: url args: postArgs];
}

/*
 * Returns extended information of a given user, specified by ID or screen name as per the required id parameter.
 *
 * @param NSString user*
 * @return NSDictionary
 */
- (NSDictionary *) GetUser: (NSString*) user
{
    NSString *url = [NSString stringWithFormat: @"/users/show/%@.json", user];
    
    NSMutableDictionary *userData = (NSMutableDictionary *)[self get: url args: @""];
    if([userData objectForKey: @"error"])
    {
        return nil;
    }
    else
    {
        // Add large profile image URL
        NSString *smallProfileImageURL = [userData objectForKey: @"profile_image_url"];
        NSString *largeProfileImageURL = [smallProfileImageURL stringByReplacingOccurrencesOfString: @"-48-" withString: @"-96-"];
        [userData setObject: largeProfileImageURL forKey: @"large_profile_image_url"];
        
        //[userData setObject: [NSString stringWithFormat: @"%@", [userData objectForKey: @"location"]] forKey: @"location"];
        
        return (NSDictionary *)userData;
    }
}

- (NSString*) GetUserIDFromUsername: (NSString*) uname
{
    NSDictionary *user = (NSDictionary *)[self GetUser: username];
    
    return [user objectForKey: @"id"];
}

- (NSString *) GetUsernameFromUserID: (int) user_id
{
    NSString *url = [NSString stringWithFormat: @"/users/show/%i.json", user_id];
    
    NSDictionary *userData = (NSDictionary *)[self get: url args: @""];
    
    return [userData objectForKey: @"screen_name"];
}



/*
 ###################################################
 
 DIRECT MESSAGE METHODS
 - GetInbox
 - GetOutbox
 - SendDirectMessageTo
 
 ###################################################
 */

/*
 * Returns a list of the 20 most recent direct messages sent to the authenticating user.
 *
 * @param int page_number, int since_id
 * @return NSMutableArray
 */
- (NSMutableArray *) GetInbox: (NSInteger) page_number
                     since_id: (NSInteger) since_id
{
    NSString *count = [[NSUserDefaults standardUserDefaults] objectForKey: @"initialLoad"];
    NSString *postArgs = [NSString stringWithFormat: @"count=%@", count];
    
    if(page_number > 1)
        postArgs = [postArgs stringByAppendingString: [NSString stringWithFormat: @"&page%i", page_number]];
    
    if(since_id > 0)
        postArgs = [postArgs stringByAppendingString: [NSString stringWithFormat: @"&since_id=%i", since_id]];
    
    return [self post: @"/direct_messages.json" args: postArgs];
    
}

/*
 * Returns a list of the 20 most recent direct messages sent by the authenticating user.
 *
 * @param int page_number, int since_id
 * @return NSMutableArray
 */
- (NSMutableArray *) GetOutbox: (NSInteger) page_number
                      since_id: (NSInteger) since_id
{
    NSString *count = [[NSUserDefaults standardUserDefaults] objectForKey: @"initialLoad"];
    NSString *postArgs = [NSString stringWithFormat: @"count=%@", count];
    
    if(page_number > 1)
        postArgs = [postArgs stringByAppendingString: [NSString stringWithFormat: @"&page%i", page_number]];
    
    if(since_id > 0)
        postArgs = [postArgs stringByAppendingString: [NSString stringWithFormat: @"&since_id=%i", since_id]];
    
    return [self post: @"/direct_messages/sent.json" args: postArgs];
}

/*
 * Sends a new direct message to the specified user from the authenticating user.
 * Requires both the user and text parameters below. Request must be a POST.
 */
- (BOOL) SendDirectMessageTo: (NSString*) recipient
                        text: (NSString*) text
{
    // URL Encode the message
    text = [text stringByAddingPercentEscapesUsingEncoding: NSUTF8StringEncoding];
    
    NSString *postArgs = [@"?user=" stringByAppendingString: recipient];
    postArgs = [postArgs stringByAppendingString:[@"&text=%@" stringByAppendingString: text]];
    
    NSArray *retval = [self post: @"/direct_messages/new.json" args: postArgs];
    // Figure out if it succeeded
    if(retval) {}
    
    return true;
}



/*
 ###################################################
 
 FRIENDSHIP METHODS
  - SubscribeUser
  - UnsubscribeUser
  - FriendshipExists
 
 ###################################################
 */

/*
 * Befriends the user specified in the ID parameter as the authenticating user. 
 * Returns the befriended user in the requested format when successful.  Returns a string describing the failure condition when unsuccessful.
 *
 * @param NSString recipient*
 * @return BOOL
 */
- (BOOL) SubscribeUser: (NSString*) recipient
{
    NSString* url = [NSString stringWithFormat: @"/friendships/create/%@.json", recipient];
    
    NSDictionary *retval = (NSDictionary *)[self post: url args: @""];
    
    // Determine success
    if([retval objectForKey: @"id"])
        return true;
    else
        return false;
    
}

/*
 * Discontinues friendship with the user specified in the ID parameter as the authenticating user.
 * Returns the un-friended user in the requested format when successful. Returns a string describing the failure condition when unsuccessful.
 *
 * @param NSString recipient*
 * @return BOOL
 */
- (BOOL) UnsubscribeUser: (NSString*) recipient
{
    NSString* url = [NSString stringWithFormat: @"/friendships/destroy/%@.json", recipient];
    
    NSDictionary *retval = (NSDictionary *)[self post: url args: @""];
    
    // Determine success
    if([retval objectForKey: @"id"])
        return true;
    else
        return false;
}

/*
 * Tests if a friendship exists between two users.
 *
 * @param NSString recipient*
 * @return BOOL
 */
- (BOOL) FriendshipExists: (NSString*) recipient
{
    NSString* url = @"/friendships/exists.json";
    NSString *user = [[NSUserDefaults standardUserDefaults] objectForKey: @"username"];
    NSString *postArgs = [NSString stringWithFormat: @"user_a=%@&user_b=%@", user, recipient];
    
    NSString *retval = (NSString *)[self post: url args: postArgs];
    
    return [retval isEqualToString: @"\"true\""];
}



/*
 ###################################################
 
 FAVORITE METHODS
 - GetFavorites
 - AddFavorite
 
 ###################################################
 */

/*
 * Returns the 20 most recent favorite statuses for the authenticating user or user specified by the ID parameter in the requested format.
 *
 * @param NSString user*, int page_number
 * @return NSMutableArray
 */
- (NSMutableArray *) GetFavorites: (NSString*) user
                             page: (NSInteger) page_number
{
    NSString* url = [NSString stringWithFormat:@"/favorites/%@.json", user];
    
    NSString *count = [[NSUserDefaults standardUserDefaults] objectForKey: @"initialLoad"];
    NSString *postArgs = [NSString stringWithFormat: @"?count=%@", count];
    
    if(page_number > 1)
        postArgs = [postArgs stringByAppendingString:[NSString stringWithFormat:@"&page=%i", page_number]];
    
    return [self post: url args: postArgs];
}

/*
 * Favorites the status specified in the ID parameter as the authenticating user.
 *
 * @param NSString status_id*
 * @return BOOL
 */
- (BOOL) AddFavorite: (NSString *) status_id
{
    NSString *url = [NSString stringWithFormat: @"/favorites/create/%@.json", status_id];
    NSDictionary *retval = (NSDictionary *)[self post: url args: @""];
    
    // Determine success
    return ([[retval objectForKey: @"favorited"] isEqualToString: @"true"]);
}

/*
 * Un-favorites the status specified in the ID parameter as the authenticating user.
 *
 * @param NSString status_id*
 * @return BOOL
 */
- (BOOL) DestroyFavorite: (NSString *) status_id
{
    NSString *url = [NSString stringWithFormat: @"/favorites/destroy/%@.json", status_id];
    NSDictionary *retval = (NSDictionary *)[self post: url args: @""];
    
    // Determine success
    return ([[retval objectForKey: @"favorited"] isEqualToString: @"false"]);
}



/*
 ###################################################
 
 BLOCK METHODS
 - BlockUser
 - UnblockUser
 
 ###################################################
 */

/*
 * Blocks the user specified in the ID parameter as the authenticating user.
 *
 * @param NSString user*
 * @return BOOL
 */
- (BOOL) BlockUser: (NSString*) user
{
    NSString* url = [NSString stringWithFormat:@"/blocks/create/%@.json", user];
    NSDictionary *retval = (NSDictionary *)[self post: url args: @""];
    
    // Determine success
    if(retval) {}
    
    return true;
}

/*
 * Un-blocks the user specified in the ID parameter as the authenticating user.
 *
 * @param NSString user*
 * @return BOOL
 */
- (BOOL) UnblockUser: (NSString*) user
{
    NSString* url = [NSString stringWithFormat:@"/blocks/destroy/%@.json", user];
    NSDictionary *retval = (NSDictionary *)[self post: url args: @""];
    
    // Determine success
    if(retval) {}
    
    return true;
}


/*
 ###################################################
 
 SEARCH METHODS
 - Search: query
 
 ###################################################
 */

/*
 * Send a request for the timeline of a specified user
 * 
 * @param NSString user, int count, int since_id, int page_number
 * @return NSArray
 */
- (NSMutableArray *) Search: (NSString*) query
                       page: (NSInteger) page_number
{
    NSString *count = [[NSUserDefaults standardUserDefaults] objectForKey: @"initialLoad"];
    NSString *postArgs = [NSString stringWithFormat: @"?q=%@&rpp=%@", query, count];
    
    if(page_number > 1)
        postArgs = [postArgs stringByAppendingString: [NSString stringWithFormat:@"&page=%i", page_number]];
    
    NSDictionary *results = (NSDictionary *)[self get: @"/search.json" args: postArgs];
    
    return (NSMutableArray *)[results objectForKey: @"results"];
}



/*
 ###################################################
 
 JSON CALL METHODS
  - get: args:
  - post: args:
 
 ###################################################
 */
- (NSMutableArray *) get: (NSString *) action
                    args: (NSString *) args
{
    // Get server
    NSString *server = [[NSUserDefaults standardUserDefaults] stringForKey: @"domain"];
    
    // Format request
    NSString *requestBase = [NSString stringWithFormat: @"https://%@/api%@%@", server, action, args];
    NSLog(@"Action (GET): %@", requestBase);
    NSMutableURLRequest *request = [[NSMutableURLRequest alloc] initWithURL: [NSURL URLWithString: requestBase]];    
    [request setHTTPMethod: @"GET"];
    //[request setHTTPBody: [NSData dataWithBytes: [args UTF8String] length: [args length]]];
    
    // Perform request and get JSON back as an NSData oject
    NSData *response = [NSURLConnection sendSynchronousRequest: request returningResponse: nil error: nil];
    
    // Get JSON as an NSString from NSData Response
    NSString *json_string = [[NSString alloc] initWithData: response encoding: NSUTF8StringEncoding];
    //NSLog(@"Response: %@\n\n", json_string);
    
    return [[SBJSON alloc] objectWithString: json_string error: nil]; 
}

- (NSMutableArray *) post: (NSString *) action
                     args: (NSString *) args
{
    // Get credentials
    NSString *user   = [[NSUserDefaults standardUserDefaults] stringForKey: @"username"];
    NSString *passwd = [[NSUserDefaults standardUserDefaults] stringForKey: @"password"];
    NSString *server = [[NSUserDefaults standardUserDefaults] stringForKey: @"domain"];
    
    // Format request
    NSString *requestBase = [NSString stringWithFormat: @"https://%@/api%@", server, action];
    NSLog(@"Action (POST): %@", requestBase);
    NSLog(@"POST Args: %@", args);
    NSMutableURLRequest *request = [[NSMutableURLRequest alloc] initWithURL: [NSURL URLWithString: requestBase]];
    
    // Add Authentication
    NSString *auth = [NSString stringWithFormat: @"%@:%@", user, passwd];
    NSString* basicauth = [NSString stringWithFormat: @"Basic %@", [NSString base64encode: auth]];
    [request setValue: basicauth forHTTPHeaderField: @"Authorization"];
    [request setHTTPMethod: @"POST"];
    [request setHTTPBody: [NSData dataWithBytes: [args UTF8String] length: [args length]]];
    
    NSData *response = [NSURLConnection sendSynchronousRequest: request returningResponse: nil error: nil];
    
    // Get JSON as an NSString from NSData Response
    NSString *json_string = [[NSString alloc] initWithData: response encoding: NSUTF8StringEncoding];
    //NSLog(@"Response: %@\n\n", json_string);

    if([action isEqualToString: @"/friendships/exists.json"])
        return (NSString *)json_string;
    
    // Parse the JSON response into an object
    return [[SBJSON alloc] objectWithString: json_string error: nil];
}


- (void) dealloc
{
    [username dealloc];
    [password dealloc];
    [apiBase dealloc];
    [userID dealloc];
    [super dealloc];
}


@end