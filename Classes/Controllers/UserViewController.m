//
//  UserViewController.m
//  modentica2
//
//  Created by Mark Bockenstedt on 2/6/09.
//  Copyright 2009 __MyCompanyName__. All rights reserved.
//

#import "UserViewController.h"
#import "FollowerViewController.h"
#import "SearchViewController.h"
#import "TimelineViewController.h"
#import "WebViewController.h"

#import "IdenticaAPI.h"
#import "Utilities.h"

@implementation UserViewController

@synthesize userProfile, screenName;
@synthesize profileImageView, usernameLabel, locationLabel, descriptionLabel, websiteButton, followersLabel, memberSinceLabel;
@synthesize userActions, subscribeButton, unsubscribeButton, titleBar;


// The designated initializer. Override to perform setup that is required before the view is loaded.
- (id) initWithNibName: (NSString *) nibNameOrNil
                bundle: (NSBundle *) nibBundleOrNil
              showUser: (NSString *) username
{
    if(self = [super initWithNibName: nibNameOrNil bundle: nibBundleOrNil])
    {
        self.userProfile = [[IdenticaAPI alloc] GetUser: username];
        
        self.navigationItem.title = [self.userProfile objectForKey: @"name"];
        self.screenName = username;
        
        // Cache the profile image
        [[Utilities alloc] cacheImage: [self.userProfile objectForKey: @"large_profile_image_url"]];
    }
    
    return self;
}

- (id) initWithNibName: (NSString *) nibNameOrNil
                bundle: (NSBundle *) nibBundleOrNil
              withUser: (NSDictionary *) userInfo
{
    if(self = [super initWithNibName: nibNameOrNil bundle: nibBundleOrNil])
    {
        self.userProfile = userInfo;
        
        self.navigationItem.title = [self.userProfile objectForKey: @"name"];
        self.screenName = [self.userProfile objectForKey: @"screen_name"];
        
        // Cache the profile image
        [[Utilities alloc] cacheImage: [self.userProfile objectForKey: @"large_profile_image_url"]];
    }
    
    return self;
}


/*
// Implement loadView to create a view hierarchy programmatically, without using a nib.
- (void)loadView {
}
*/

// Implement viewDidLoad to do additional setup after loading the view, typically from a nib.
- (void) viewDidLoad
{
    [super viewDidLoad];
    
    // Set Fonts
    usernameLabel.font = [UIFont boldSystemFontOfSize: 16];
    locationLabel.font = [UIFont systemFontOfSize: 14];
    memberSinceLabel.font = [UIFont systemFontOfSize: 14];
    followersLabel.font = [UIFont systemFontOfSize: 14];
    
    
    // Fill in the blanks
    usernameLabel.text = [NSString stringWithFormat:@"@%@", self.screenName];
    
    memberSinceLabel.text = [NSString stringWithFormat: @"Joined %@", [[Utilities alloc] formatDate: [self.userProfile objectForKey: @"created_at"]]];
    
    if(![ [NSString stringWithFormat: @"%@", [self.userProfile objectForKey: @"location"]] isEqualToString: @"<null>"])
        locationLabel.text = [self.userProfile objectForKey: @"location"];
    
    if(![ [NSString stringWithFormat: @"%@", [self.userProfile objectForKey: @"description"]] isEqualToString: @"<null>"])
    {
        descriptionLabel.text = [self.userProfile objectForKey: @"description"];
        descriptionLabel.font = [UIFont systemFontOfSize: 12];
    }
    
    if(![ [NSString stringWithFormat: @"%@", [self.userProfile objectForKey: @"url"]] isEqualToString: @"<null>"])
    {
        [websiteButton setTitle: [self.userProfile objectForKey: @"url"] forState: UIControlStateNormal];
        [websiteButton setTitle: [self.userProfile objectForKey: @"url"] forState: UIControlStateSelected];
    }
    
    followersLabel.text = [NSString stringWithFormat: @"%@ followers", [self.userProfile objectForKey: @"followers_count"]];
    
    // Load Profile Image
    NSString *profileImageURL = [self.userProfile objectForKey: @"large_profile_image_url"];
    profileImageView.frame = CGRectMake(15, 20, 73, 73);
    profileImageView.image = [[Utilities alloc] getCachedImage: profileImageURL defaultToSmall: NO];
    
    // Get Credentials
    NSString *loggedInUsername = [[NSUserDefaults standardUserDefaults] objectForKey: @"username"];
    
    // Update Subscription button if it's not my profile
    if(![self.screenName isEqualToString: loggedInUsername])
    {
        // determine if I'm already subscribing to the person I'm viewing
        IdenticaAPI *API = [IdenticaAPI alloc];
        if([API FriendshipExists: self.screenName])
        {
            unsubscribeButton.enabled = YES;
            unsubscribeButton.hidden = NO;
        }
        else
        {
            subscribeButton.enabled = YES;
            subscribeButton.hidden = NO;
        }
    }
    
    UIColor *backgroundColor = [[UIColor alloc] initWithRed: 0.87 green: 0.87 blue: 0.87 alpha: 1.0];
    
    [self.view setBackgroundColor: backgroundColor];
    [self.userActions setBackgroundColor: backgroundColor];
}

- (void) setupImage: (UIImage*) img
{
    profileImageView.image = img;
}

- (void) subscribe: (id) sender
{
    BOOL success = [[IdenticaAPI alloc] SubscribeUser: self.screenName];
    if(success)
    {
        subscribeButton.enabled = NO;
        subscribeButton.hidden = YES;
        
        unsubscribeButton.enabled = YES;
        unsubscribeButton.hidden = NO;
    }
    else
    {
        NSString *msg = @"Unable to subscribe to user, please try again later.";
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle: @"Error" message: msg  delegate: self cancelButtonTitle: nil otherButtonTitles: @"OK", nil];
        [alert show];	
        [alert release];
    }
}

- (void) unsubscribe: (id) sender
{
    BOOL success = [[IdenticaAPI alloc] UnsubscribeUser: self.screenName];
    if(success)
    {
        subscribeButton.enabled = YES;
        subscribeButton.hidden = NO;
        
        unsubscribeButton.enabled = NO;
        unsubscribeButton.hidden = YES;
    }
    else
    {
        NSString *msg = @"Unable to send unsubscribe from user, please try again later.";
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle: @"Error" message: msg  delegate: self cancelButtonTitle: nil otherButtonTitles: @"OK", nil];
        [alert show];	
        [alert release];
    }
}

- (void) loadWebPage: (id) sender
{
    NSString *website = websiteButton.currentTitle;
    
    NSString *opensWith = [[NSUserDefaults standardUserDefaults] objectForKey: @"openLinksIn"];
    if([opensWith isEqualToString: @"Built-In Viewer"])
    {
        WebViewController *webViewController = [[WebViewController alloc] initWithNibName: @"WebView" bundle: nil href: website];
        [self.navigationController pushViewController: webViewController animated: YES];
        [webViewController release];
    }
    else if([opensWith isEqualToString: @"Safari"])
    {
        [[UIApplication sharedApplication] openURL: [NSURL URLWithString: website]];
    }
}

/*
// Override to allow orientations other than the default portrait orientation.
- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
    // Return YES for supported orientations
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}
*/

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning]; // Releases the view if it doesn't have a superview
    // Release anything that's not essential, such as cached data
}

- (NSInteger) numberOfSectionsInTableView: (UITableView *) tableView
{
    return 1;
}


// Customize the number of rows in the table view.
- (NSInteger) tableView: (UITableView *) tableView 
  numberOfRowsInSection: (NSInteger) section
{
    return 5;
}


// Customize the appearance of table view cells.
- (UITableViewCell *) tableView: (UITableView *) tableView 
          cellForRowAtIndexPath: (NSIndexPath *) indexPath
{
    static NSString *CellIdentifier = @"ActionCell";
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if(cell == nil)
    {
        cell = [[[UITableViewCell alloc] initWithFrame:CGRectZero reuseIdentifier:CellIdentifier] autorelease];
    }
    
    UILabel *countLabel;
    
    switch(indexPath.row)
    {
        case 0:
            cell.text = @"Recent Updates";
            
            // Add count label
            countLabel = [[UILabel alloc] initWithFrame: CGRectMake(145.0f, 12.0f, 50.0f, 20.0f)];
            countLabel.text = [NSString stringWithFormat: @"(%@)", [self.userProfile objectForKey: @"statuses_count"]];
            countLabel.font = [UIFont boldSystemFontOfSize: 16];
            
            [cell.contentView addSubview: countLabel];
            [countLabel release];
            break;
            
        case 1:
            cell.text = @"Favorites";
            
            // Add count label
            countLabel = [[UILabel alloc] initWithFrame: CGRectMake(90.0f, 12.0f, 50.0f, 20.0f)];
            countLabel.text = [NSString stringWithFormat: @"(%@)", [self.userProfile objectForKey: @"favourites_count"]];
            countLabel.font = [UIFont boldSystemFontOfSize: 16];
            
            [cell.contentView addSubview: countLabel];
            [countLabel release];
            break;
        
        case 2:
            cell.text = @"Friends";
            
            // Add count label
            countLabel = [[UILabel alloc] initWithFrame: CGRectMake(80.0f, 12.0f, 50.0f, 20.0f)];
            countLabel.text = [NSString stringWithFormat: @"(%@)", [self.userProfile objectForKey: @"friends_count"]];
            countLabel.font = [UIFont boldSystemFontOfSize: 16];
            
            [cell.contentView addSubview: countLabel];
            [countLabel release];
            break;
        
        case 3:
            cell.text = @"Followers";
            
            // Add count label
            countLabel = [[UILabel alloc] initWithFrame: CGRectMake(100.0f, 12.0f, 50.0f, 20.0f)];
            countLabel.text = [NSString stringWithFormat: @"(%@)", [self.userProfile objectForKey: @"followers_count"]];
            countLabel.font = [UIFont boldSystemFontOfSize: 16];
            
            [cell.contentView addSubview: countLabel];
            [countLabel release];
            break;
            
        case 4:
            cell.text = [NSString stringWithFormat: @"Search @%@", self.screenName];
            break;
    }
    
    cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
    
    return cell;
}


-      (void) tableView: (UITableView *) tableView
didSelectRowAtIndexPath: (NSIndexPath *) indexPath
{
    UITableViewCell *cell = (UITableViewCell *)[tableView cellForRowAtIndexPath: indexPath];
    NSString *buttonText = cell.text;
    
    [cell setSelected: NO animated: YES];
    
    if([buttonText isEqualToString: @"Recent Updates"])
    {
        TimelineViewController *timelineViewController = [[TimelineViewController alloc] initWithNibName: @"TimelineView" bundle: nil showUser: self.screenName];
        [self.navigationController pushViewController: timelineViewController animated: YES];
        [timelineViewController release];
    }
    else if([buttonText isEqualToString: @"Friends"])
    {
        FollowerViewController *fvController = [[FollowerViewController alloc] initWithNibName: @"FollowerView" bundle: nil parentUser: self.screenName view: @"friends"];
        [self.navigationController pushViewController: fvController animated: YES];
        [fvController release];
    }
    else if([buttonText isEqualToString: @"Followers"])
    {
        FollowerViewController *fvController = [[FollowerViewController alloc] initWithNibName: @"FollowerView" bundle: nil parentUser: self.screenName view: @"followers"];
        [self.navigationController pushViewController: fvController animated: YES];
        [fvController release];
    }
    else if([buttonText isEqualToString: [NSString stringWithFormat: @"Search @%@", self.screenName]])
    {
        SearchViewController *svc = [[SearchViewController alloc] initWithNibName: @"SearchView" bundle: nil searchText: self.screenName];
        [self.navigationController pushViewController: svc animated: YES];
        [svc release];
    }
}



- (void) dealloc
{
    [super dealloc];
}


@end
