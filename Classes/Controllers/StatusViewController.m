//
//  StatusViewController.m
//  modentica2
//
//  Created by Mark Bockenstedt on 2/20/09.
//  Copyright 2009 __MyCompanyName__. All rights reserved.
//

#import "StatusViewController.h"

#import "ComposeViewController.h"
#import "ImageViewController.h"
#import "SearchViewController.h"
#import "UserViewController.h"
#import "WebViewController.h"

#import "IdenticaAPI.h"
#import "Utilities.h"
#import "REString.h"

#define TMP [NSHomeDirectory() stringByAppendingPathComponent: @"tmp"]
#define urlRegexp @"(((http(s?))\\:\\/\\/)([-0-9a-zA-Z]+\\.)+[a-zA-Z]{2,6}(\\:[0-9]+)?(\\/[-0-9a-zA-Z_#!:.?+=&%@~*\\';,/$]*)?)"
#define endRegexp  @"[.,;:]$"

@implementation StatusViewController

@synthesize status, statusID, username, fullNameLabel, screenNameLabel, avatarImageView, statusWebView, timestampLabel, clientButton, inReplyToButton;
@synthesize retweetButton, favoriteButton, replyButton, deleteButton, goToProfileButton, isFavorite, inReplyToID, clientURL, links;

- (id) initWithNibName: (NSString *) nibNameOrNil
                bundle: (NSBundle *) nibBundleOrNil
            showStatus: (NSString *) statusIDToShow
{
    if (self = [super initWithNibName: nibNameOrNil bundle: nibBundleOrNil])
    {
        self.status = (NSDictionary *)[[IdenticaAPI alloc] ShowStatus: statusIDToShow];
        
        self.statusID = statusIDToShow;
        self.username = @"";
        self.isFavorite = NO;
        self.inReplyToID = @"";
        self.clientURL = @"";
    }
    
    return self;
}

// Implement viewDidLoad to do additional setup after loading the view, typically from a nib.
- (void) viewDidLoad
{
    [super viewDidLoad];
    
    // Set the username
    NSString *theUsername = [[self.status objectForKey: @"user"] objectForKey: @"screen_name"];
    self.username = theUsername;
    
    // Set the full name
    self.fullNameLabel.text = [[self.status objectForKey: @"user"] objectForKey: @"name"];
    self.fullNameLabel.font = [UIFont boldSystemFontOfSize: 18];
    
    // Set the username label
    self.screenNameLabel.text = [NSString stringWithFormat: @"@%@", theUsername];
    self.screenNameLabel.font = [UIFont systemFontOfSize: 14];
    
    // Parse & set the status
    NSString *statusText = [self.status objectForKey: @"text"];
    
    // Find all links - stored in self.links
    [self parseTextForLinks: statusText];
        
    // Set the status
    //self.statusLabel.text = statusText;
    //self.statusLabel.font = [UIFont systemFontOfSize: 14];
    
    NSString *richText = statusText;
    NSString *domain = [[NSUserDefaults standardUserDefaults] stringForKey: @"domain"];
    statusWebView.frame = CGRectMake(10.0f, 73.0f, 281.0f, 82.0f);
    for(NSString *link in self.links)
    {
        NSString *firstCharacter = [link substringToIndex: 1];
        
        if([firstCharacter isEqualToString: @"@"]) // username
        {
            NSString *url = [NSString stringWithFormat: @"<a href=\"mod://user/%@\">%@</a>", link, link];
            richText = [richText stringByReplacingOccurrencesOfString: link withString: url];
        }
        else if([firstCharacter isEqualToString: @"#"]) // hashtag
        {
            NSString *url = [NSString stringWithFormat: @"<a href=\"mod://tag/%@\">%@</a>", link, link];
            richText = [richText stringByReplacingOccurrencesOfString: link withString: url];
        }
        else if([firstCharacter isEqualToString: @"!"]) // group name
        {
            NSString *url = [NSString stringWithFormat: @"<a href=\"mod://group/%@\">%@</a>", link, link];
            richText = [richText stringByReplacingOccurrencesOfString: link withString: url];
        }
        else // URL
        {
            NSString *userURL = [NSString stringWithFormat: @"<a href=\"%@\">%@</a>", link, link];
            richText = [richText stringByReplacingOccurrencesOfString: link withString: userURL];
        }
    }
    
    NSString *html = [NSString stringWithFormat: @"\
<html>\
<head>\
    <style type=\"text/css\">\
    body { margin: 0; padding: 0; font-size: 1em; }\
    a { text-decoration: none; color: blue; font-weight: bold; }\
    </style>\
</head>\
<body>\
%@\
</body>\
</html>", richText];
    
    [statusWebView loadHTMLString: html baseURL: nil ];
    
    // Format & set the timestamp
    self.timestampLabel.text = [[Utilities alloc] formatTimestamp: [self.status objectForKey: @"created_at"] forStatusView: YES];
    
    // Parse out the source
    NSString *sourcetmp = [self.status objectForKey: @"source"];
    NSMutableArray *sourceLinks = [NSMutableArray array];
    NSMutableArray *sourceArray = [NSMutableArray array];
    
    while([sourcetmp matches: urlRegexp withSubstring: sourceArray])
    {
        NSString *url = [sourceArray objectAtIndex: 0];
        [sourceArray removeAllObjects];
        if([url matches: endRegexp withSubstring: sourceArray])
            url = [url substringToIndex: [url length] - 1];
        
        [sourceLinks addObject: url];
        NSRange r = [sourcetmp rangeOfString: url];
        sourcetmp = [sourcetmp substringFromIndex: r.location + r.length];
        [sourceArray removeAllObjects];
    }
    
    NSString *sourceTitle;
    if([sourceLinks count] > 0)
    {
        self.clientURL = [sourceLinks objectAtIndex: 0];
        
        sourceTitle = [[self.status objectForKey: @"source"] stringByReplacingOccurrencesOfString: @"</a>" withString: @""];
        sourceTitle = [sourceTitle stringByReplacingOccurrencesOfString: [NSString stringWithFormat: @"<a href=\"%@\">", self.clientURL] withString: @""];
        
        [clientButton setTitleColor: [UIColor blueColor] forState: UIControlStateNormal];
    }
    else
        sourceTitle = [self.status objectForKey: @"source"];

    [clientButton setTitle: sourceTitle forState: UIControlStateNormal];
    
    // Add the avatar
    self.avatarImageView.frame = CGRectMake(10, 10, 48, 48);
    
    // Grab the cached image
    NSString *profileImageURL = [[self.status objectForKey: @"user"] objectForKey: @"profile_image_url"];
    self.avatarImageView.image = [[Utilities alloc] getCachedImage: profileImageURL defaultToSmall: YES];

    // Do we need to show the reply to button?
    if( (NSInteger)[self.status objectForKey: @"in_reply_to_status_id"] > 0 )
    {
        self.inReplyToID = [self.status objectForKey: @"in_reply_to_status_id"];
        
        /*
        // Who's it to?
        int replyToUserID = [[self.status objectForKey: @"in_reply_to_user_id"] intValue];
        NSString *replyToName = [[IdenticaAPI alloc] GetUsernameFromUserID: replyToUserID];
        
        //NSString *buttonTitle = [NSString stringWithFormat: @"in reply to @%@", replyToName];
        //NSString *buttonTitle = @"in reply to";
        
        //[self.inReplyToButton setTitle: buttonTitle forState: UIControlStateNormal];
        //[self.inReplyToButton setTitle: buttonTitle forState: UIControlStateSelected];
         */
        
        self.inReplyToButton.hidden = NO;
    }
    
    // Is this a favorite?
    if([[self.status objectForKey: @"favorited"] isEqualToString: @"true"])
    {
        [self.favoriteButton setImage: [UIImage imageNamed: @"favorited.png"] forState: UIControlStateNormal];
        self.isFavorite = YES;
        self.favoriteButton.enabled = NO;
    }
    
    // If it's not my update, hide the trash button
    if(![theUsername isEqualToString: [[NSUserDefaults standardUserDefaults] objectForKey: @"username"]])
    {
        //deleteButton.hidden = YES;
        deleteButton.enabled = NO;
    }
}

- (void) setCellID: (NSString *) cellID
{
	self.statusID = cellID;
}

- (void) goToProfile: (id) sender
{
    // Push the User View Controller
    UserViewController *userViewController = [[UserViewController alloc] initWithNibName: @"UserView" bundle: nil showUser: self.username];
    [self.navigationController pushViewController: userViewController animated: YES];
    [userViewController release];

}

- (void) composeRetweet
{
    // Push the Compose View Controller
    ComposeViewController *composeViewController = [[ComposeViewController alloc] initWithNibName: @"ComposeView" bundle: nil];
    [composeViewController prefillText: [NSString stringWithFormat: @"RT @%@: %@", self.username, [self.status objectForKey: @"text"] ]];
	[self.navigationController pushViewController: composeViewController animated: YES];
	[composeViewController release];
}

- (void) composeReply
{
    // Push the Compose View Controller
    ComposeViewController *composeViewController = [[ComposeViewController alloc] initWithNibName: @"ComposeView" bundle: nil];
    [composeViewController prefillText: [NSString stringWithFormat: @"@%@ ", self.username]];
    [composeViewController setReplyToStatusID: self.statusID userName: self.username];
	[self.navigationController pushViewController: composeViewController animated: YES];
	[composeViewController release];
}

- (void) deleteStatusUpdate: (id) sender
{
    // Confirm the deletion
    UIActionSheet *actionSheet = [[UIActionSheet alloc]
                                  initWithTitle: @""
                                  delegate: self
                                  cancelButtonTitle: @"Cancel"
                                  destructiveButtonTitle: @"Delete", nil
                                  otherButtonTitles: nil];
    [actionSheet showInView: self.view];
    [actionSheet release];
}

- (void) parseTextForLinks: (NSString *) statusText
{
    // Parse out all the goodies
    //static NSString *urlRegexp  = @"(((http(s?))\\:\\/\\/)([-0-9a-zA-Z]+\\.)+[a-zA-Z]{2,6}(\\:[0-9]+)?(\\/[-0-9a-zA-Z_#!:.?+=&%@~*\\';,/$]*)?)";
    //static NSString *endRegexp  = @"[.,;:]$";
    static NSString *nameRegexp = @"(@[0-9a-zA-Z_]+)";
    static NSString *hashRegexp = @"(#[-a-zA-Z0-9_.+:=]+)";
    static NSString *groupRegexp = @"(![-a-zA-Z0-9_.+:=]+)";
    
    BOOL hasHash = false;
    
    self.links = [NSMutableArray array];
    NSMutableArray *array = [NSMutableArray array];
    
    NSString *tmp = statusText;
    
    // Find URLs
    while ([tmp matches: urlRegexp withSubstring: array])
    {
        NSString *url = [array objectAtIndex: 0];
        [array removeAllObjects];
        if([url matches: endRegexp withSubstring: array])
        {
            url = [url substringToIndex: [url length] - 1];
        }
        
        [self.links addObject: url];
        NSRange r = [tmp rangeOfString: url];
        tmp = [tmp substringFromIndex: r.location + r.length];
        [array removeAllObjects];
    }
    
    // Find screen names
    tmp = statusText;
    while ([tmp matches: nameRegexp withSubstring: array])
    {
        NSString *u = [array objectAtIndex: 0];
        [self.links addObject: u];
        NSRange r = [tmp rangeOfString: u];
        tmp = [tmp substringFromIndex: r.location + r.length];
        [array removeAllObjects];
    }
    
    // Find hashtags
    tmp = statusText;
    while ([tmp matches: hashRegexp withSubstring: array])
    {
        NSString *hash = [array objectAtIndex: 0];
        [self.links addObject: hash];
        NSRange r = [tmp rangeOfString: hash];
        tmp = [tmp substringFromIndex: r.location + r.length];
        [array removeAllObjects];
        hasHash = true;
    }
    
    // Find group tags
    tmp = statusText;
    while ([tmp matches: groupRegexp withSubstring: array])
    {
        NSString *group = [array objectAtIndex:0];
        [self.links addObject: group];
        NSRange r = [tmp rangeOfString: group];
        tmp = [tmp substringFromIndex: r.location + r.length];
        [array removeAllObjects];
    }
    
}

- (void) toggleFavoriteStatus: (id) sender
{
    IdenticaAPI *API = [IdenticaAPI alloc];
    
    if(self.isFavorite) // it's already a favorite, destroy it
    {
        NSLog(@"Destroying favorite");
        BOOL success = [API DestroyFavorite: self.statusID];
        if(success)
        {
            [self updateFavoriteStatus: NO];
        }
        else
        {
            NSString *msg = @"Unable to destroy favorite, please try again later.";
            UIAlertView *alert = [[UIAlertView alloc] initWithTitle: @"Error" message: msg  delegate: self cancelButtonTitle: nil otherButtonTitles: @"OK", nil];
            [alert show];	
            [alert release];
        }
    }
    else // it's not a favorite, add it
    {
        NSLog(@"Adding favorite");
        BOOL success = [API AddFavorite: self.statusID];
        if(success)
        {
            [self updateFavoriteStatus: YES];
        }
        else
        {
            NSString *msg = @"Unable to add as favorite, please try again later.";
            UIAlertView *alert = [[UIAlertView alloc] initWithTitle: @"Error" message: msg  delegate: self cancelButtonTitle: nil otherButtonTitles: @"OK", nil];
            [alert show];	
            [alert release];
        }
    }
}

- (void) updateFavoriteStatus: (BOOL) setAsFavorite
{
    if(setAsFavorite)
    {
        self.isFavorite = YES;
        [self.favoriteButton setBackgroundImage: [UIImage imageNamed: @"favorited.png"] forState: UIControlStateNormal];
    }
    else
    {
        self.isFavorite = NO;
        [self.favoriteButton setBackgroundImage: [UIImage imageNamed: @"favorite.png"] forState: UIControlStateNormal];
    }
}

- (void) viewReply: (id) sender
{
    StatusViewController *statusViewController = [[StatusViewController alloc] initWithNibName: @"StatusView" bundle: nil showStatus: self.inReplyToID];
    [self.navigationController pushViewController: statusViewController animated: YES];
    [statusViewController release];
}

- (void) loadWebPage: (id) sender
{
    if([self.clientURL length] > 0)
    {
        [self openWebView: self.clientURL];
    }
}

- (void) openWebView: (NSString *) href
{
    NSString *opensWith = [[NSUserDefaults standardUserDefaults] objectForKey: @"openLinksIn"];
    if([opensWith isEqualToString: @"Built-In Viewer"])
    {
        WebViewController *webViewController = [[WebViewController alloc] initWithNibName: @"WebView" bundle: nil href: href];
        [self.navigationController pushViewController: webViewController animated: YES];
        [webViewController release];
    }
    else if([opensWith isEqualToString: @"Safari"])
    {
        [[UIApplication sharedApplication] openURL: [NSURL URLWithString: href]];
    }
}

/* BEGIN Action Sheet Delegate */
- (void) actionSheet: (UIActionSheet *) actionSheet
clickedButtonAtIndex: (NSInteger) buttonIndex
{
    if(buttonIndex == 0)
    {
        BOOL success = [[IdenticaAPI alloc] DestroyStatus: self.statusID];
        if(success)
        {
            // Delete it from the parent
            [[NSNotificationCenter defaultCenter] postNotificationName: @"deleteRow" object: self.statusID];
            
            // Go back
            [self.navigationController popViewControllerAnimated: YES];
        }
        else
        {
            // Oops
            NSString *msg = @"Unable to destroy status, please try again later.";
            UIAlertView *alert = [[UIAlertView alloc] initWithTitle: @"Error" message: msg  delegate: self cancelButtonTitle: nil otherButtonTitles: @"OK", nil];
            [alert show];	
            [alert release];
        }
    }
}
/* END Action Sheet Delegate */

/* BEGIN Web View Delegate Methods */

-           (BOOL) webView: (UIWebView *) webView
shouldStartLoadWithRequest: (NSURLRequest *) request
            navigationType: (UIWebViewNavigationType) navigationType
{
    NSString *link = [NSString stringWithFormat: @"%@", request.URL];
    
    if([link isEqualTo: @"about:blank"]) // blank requests
    {
        return YES;
    }
    
    // Real requests
    if([[link substringToIndex: 6] isEqualToString: @"mod://"])
    {
        NSLog(@"caught custom URL");
        NSString *linkWithoutProtocol = [link stringByReplacingOccurrencesOfString: @"mod://" withString: @""];
        
        
        if([[linkWithoutProtocol substringToIndex: 4] isEqualToString: @"user"]) // username
        {
            NSString *user = [linkWithoutProtocol stringByReplacingOccurrencesOfString: @"user/@" withString: @""];
            NSLog(@"loading user %@", user);
            
            UserViewController *uvc = [[UserViewController alloc] initWithNibName: @"UserView" bundle: nil showUser: user];
            [self.navigationController pushViewController: uvc animated: YES];
            [uvc release];
        }
        else if([[linkWithoutProtocol substringToIndex: 3] isEqualToString: @"tag"]) // hashtag
        {
            NSString *tag = [linkWithoutProtocol stringByReplacingOccurrencesOfString: @"tag/" withString: @""];
            NSLog(@"loading hashtag %@", tag);
            
            SearchViewController *svc = [[SearchViewController alloc] initWithNibName: @"SearchView" bundle: nil searchText: tag];
            [self.navigationController pushViewController: svc animated: YES];
            [svc release];
        }
        else if([[linkWithoutProtocol substringToIndex: 5] isEqualToString: @"group"]) // group name
        {
            NSString *group = [linkWithoutProtocol stringByReplacingOccurrencesOfString: @"group/" withString: @""];
            NSLog(@"loading group %@", group);
            
            SearchViewController *svc = [[SearchViewController alloc] initWithNibName: @"SearchView" bundle: nil searchText: group];
            [self.navigationController pushViewController: svc animated: YES];
            [svc release];
        }
    }
    else // URL
    {
        NSLog(@"Pushing web view with URL %@", link);
        
        [self openWebView: link];
    }
    
    return NO;
}

/* END Web View Delegate */

- (void) didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning]; // Releases the view if it doesn't have a superview
    // Release anything that's not essential, such as cached data
}


- (void) dealloc
{
    [statusID dealloc];
    [super dealloc];
}


@end
