//
//  FollowerViewController.m
//  modentica2
//
//  Created by Mark Bockenstedt on 3/2/09.
//  Copyright 2009 __MyCompanyName__. All rights reserved.
//

#import "FollowerViewController.h"
#import "ComposeViewController.h"
#import "UserViewController.h"

#import "IdenticaAPI.h"
#import "UserCell.h"
#import "LoadingView.h"
#import "Utilities.h"

#define TMP [NSHomeDirectory() stringByAppendingPathComponent: @"tmp"]


@implementation FollowerViewController

@synthesize parentUser, viewType, userList, loadingView;

- (id) initWithNibName: (NSString *) nibNameOrNil
                bundle: (NSBundle *) nibBundleOrNil
            parentUser: (NSString *) userParent
                  view: (NSString *) view
{
    if (self = [super initWithNibName: nibNameOrNil bundle: nibBundleOrNil])
    {
        self.parentUser = userParent;
        self.viewType = view;
        
        self.navigationItem.title = [self.viewType capitalizedString];
    }
    
    return self;
}

/*
- (id) initWithStyle: (UITableViewStyle) style
          parentUser: (NSString *) userParent
{
    if (self = [super initWithStyle: style])
    {
        self.parentUser = userParent;
    }
    
    return self;
}
 */

- (void) showUpdateBox: (id) sender
{
    ComposeViewController *composeViewController = [[ComposeViewController alloc] initWithNibName: @"ComposeView" bundle: nil];
	[self.navigationController pushViewController: composeViewController animated: YES];
	[composeViewController release];
}

-(void) viewWillAppear: (BOOL) animated
{
    [super viewWillAppear: animated];
    
    if([self.userList count] == 0)
    {
        self.loadingView = [[LoadingView alloc] initWithTitle: @"Loading List"
                                                      message: @"Please wait..."
                                                     delegate: self
                                            cancelButtonTitle: nil
                                            otherButtonTitles: nil];
    }
}

- (void) beginLoadingThreadData
{
    [self.loadingView startAnimating];
    [NSThread detachNewThreadSelector: @selector(loadThreadData) toTarget: self withObject: nil];
}

- (void) loadThreadData
{
    NSAutoreleasePool *pool = [[NSAutoreleasePool alloc] init];
    //[NSThread sleepForTimeInterval: 2];
    [self performSelectorOnMainThread: @selector(finishedLoadingThreadData) withObject: nil waitUntilDone: NO];
    [pool release];
}

- (void) finishedLoadingThreadData
{
    if([self.viewType isEqualToString: @"friends"])
        self.userList = [[IdenticaAPI alloc] GetFriends: self.parentUser page: 1];
    else if([self.viewType isEqualToString: @"followers"])
        self.userList = [[IdenticaAPI alloc] GetFollowers: self.parentUser page: 1];
    
    // Download profile images
    [[Utilities alloc] downloadProfileImages: self.userList forUserList: YES];
    
    [self.loadingView kill];
    
    [self.tableView reloadData];
}

- (void) viewDidAppear: (BOOL) animated
{
    [super viewDidAppear: animated];
    
    if([self.userList count] == 0)
        [self beginLoadingThreadData];
}

/*
- (void)viewWillDisappear:(BOOL)animated {
	[super viewWillDisappear:animated];
}
*/
/*
- (void)viewDidDisappear:(BOOL)animated {
	[super viewDidDisappear:animated];
}
*/

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

#pragma mark Table view methods

- (NSInteger) numberOfSectionsInTableView: (UITableView *) tableView
{
    return 1;
}


// Customize the number of rows in the table view.
- (NSInteger) tableView: (UITableView *) tableView
  numberOfRowsInSection: (NSInteger) section
{
    return [self.userList count];
}


// Customize the appearance of table view cells.
- (UITableViewCell *) tableView: (UITableView *) tableView
          cellForRowAtIndexPath: (NSIndexPath *) indexPath
{
    static NSString *cellID = @"UserCell";
    
    UserCell *cell = (UserCell *)[tableView dequeueReusableCellWithIdentifier: cellID];
    if(cell == nil)
    {
        NSArray *topLevelObjects = [[NSBundle mainBundle] loadNibNamed: @"UserCell" owner: self options: nil];
        
        for (id currentObject in topLevelObjects)
        {
            if([currentObject isKindOfClass: [UITableViewCell class]])
            {
                cell = (UserCell *) currentObject;
                break;
            }
        }
    }
    
    // Set cell data
    NSDictionary *user = [self.userList objectAtIndex: indexPath.row];
    [cell setData: user forRow: indexPath.row];
    [cell setProfileImage: [user objectForKey: @"profile_image_url"]];
    return cell;
}

-   (CGFloat) tableView: (UITableView *) tableView 
heightForRowAtIndexPath: (NSIndexPath *) indexPath
{
    return 60.0f;
}


-      (void) tableView: (UITableView *) tableView
didSelectRowAtIndexPath: (NSIndexPath *) indexPath
{
    NSDictionary *user = [self.userList objectAtIndex: indexPath.row];
    
    UserViewController *uvc = [[UserViewController alloc] initWithNibName: @"UserView" bundle: nil showUser: [user objectForKey: @"screen_name"]];
    [self.navigationController pushViewController: uvc animated: YES];
    [uvc release]; 
}


/*
// Override to support conditional editing of the table view.
- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath {
    // Return NO if you do not want the specified item to be editable.
    return YES;
}
*/


/*
// Override to support editing the table view.
- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath {
    
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        // Delete the row from the data source
        [tableView deleteRowsAtIndexPaths:[NSArray arrayWithObject:indexPath] withRowAnimation:YES];
    }   
    else if (editingStyle == UITableViewCellEditingStyleInsert) {
        // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
    }   
}
*/


/*
// Override to support rearranging the table view.
- (void)tableView:(UITableView *)tableView moveRowAtIndexPath:(NSIndexPath *)fromIndexPath toIndexPath:(NSIndexPath *)toIndexPath {
}
*/


/*
// Override to support conditional rearranging of the table view.
- (BOOL)tableView:(UITableView *)tableView canMoveRowAtIndexPath:(NSIndexPath *)indexPath {
    // Return NO if you do not want the item to be re-orderable.
    return YES;
}
*/


- (void)dealloc {
    [super dealloc];
}


@end

