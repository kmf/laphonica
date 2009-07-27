//
//  FriendViewController.m
//  modentica2
//
//  Created by Mark Bockenstedt on 2/6/09.
//  Copyright 2009 __MyCompanyName__. All rights reserved.
//

#import "FriendViewController.h"
#import "StatusViewController.h"
#import "ComposeViewController.h"

#import "LoadingView.h"

#import "IdenticaAPI.h"
#import "StatusCell.h"
#import "Utilities.h"

#define REFRESH_INTERVAL 120
#define TAB_ID 0


@implementation FriendViewController

@synthesize timeline, loadingView;

- (void) viewDidLoad
{
    [super viewDidLoad];
    
    page = 1;
    
    // Add event listeners
    [[NSNotificationCenter defaultCenter] addObserver: self selector: @selector(deleteStatusWithID:) name: @"deleteRow" object: nil];
    [[NSNotificationCenter defaultCenter] addObserver: self selector: @selector(addStatusSilently:) name: @"messageComposed" object: nil];
}


- (void) showUpdateBox: (id) sender
{
    ComposeViewController *composeViewController = [[ComposeViewController alloc] initWithNibName: @"ComposeView" bundle: nil];
	[self.navigationController pushViewController: composeViewController animated: YES];
	[composeViewController release];
}

- (void) refreshTimeline: (id) sender
{
    // Show alert box
    self.loadingView = [[LoadingView alloc] initWithTitle: @"Refreshing Timeline" message: @"Please wait..."];
    [self.loadingView startAnimating];
    
    // Get the ID of the latest status update in the timeline
    NSDictionary *latestStatus = [self.timeline objectAtIndex: 0];
    NSInteger latestStatusID = [[latestStatus objectForKey: @"id"] intValue];
    
    // Get New Data
    NSMutableArray *updates = [[IdenticaAPI alloc] GetFriendsTimeline: 1 since_id: latestStatusID];
    [[Utilities alloc] downloadProfileImages: updates];
    
    // Merge into the timeline, putting newest at the top
    self.timeline = [updates arrayByAddingObjectsFromArray: self.timeline];
    
    [self.tableView reloadData];
    
    // Scroll to the top if new updates were found
    if([updates count] > 0)
    {
        NSIndexPath *topRow = [NSIndexPath indexPathForRow: 0 inSection: 0];
        [self.tableView scrollToRowAtIndexPath: topRow atScrollPosition: UITableViewScrollPositionTop animated: YES];
    }
    
    // Kill alert
    [self.loadingView dismissWithClickedButtonIndex: 0 animated: YES];
    self.loadingView = nil;
}

-(void) viewWillAppear: (BOOL) animated
{
    [super viewWillAppear: animated];
    
    if([self.timeline count] == 0)
        self.loadingView = [[LoadingView alloc] initWithTitle: @"Loading Timeline" message: @"Please wait..."];
}

/* Threading */
- (void) beginLoadingThreadData
{
    [self.loadingView startAnimating];
    
    [NSThread detachNewThreadSelector: @selector(loadThreadData) toTarget: self withObject: nil];
}

- (void) loadThreadData
{
    NSAutoreleasePool *pool = [[NSAutoreleasePool alloc] init];
    [self performSelectorOnMainThread: @selector(finishedLoadingThreadData) withObject: nil waitUntilDone: YES];
    
    [pool release];
}

- (void) finishedLoadingThreadData
{
    // Get Data
    self.timeline = [[IdenticaAPI alloc] GetFriendsTimeline: 1 since_id: 0];
    
    // Download profile images
    [[Utilities alloc] downloadProfileImages: self.timeline];
    
    // Dump the loading view
    [self.loadingView dismissWithClickedButtonIndex: 0 animated: YES];
    self.loadingView = nil;
    
    // reload the data
    [self.tableView reloadData];
}
/* End Threading */

- (void) viewDidAppear: (BOOL) animated
{
    [super viewDidAppear: animated];
    
    // if there's no data, load some
    if([self.timeline count] == 0)
        [self beginLoadingThreadData];
    
    // Set timers for auto refresh
    if([[NSUserDefaults standardUserDefaults] boolForKey: @"autoRefresh"])
    {
        if(autoRefreshTimer == nil)
            [self setNextTimer];
    }
    else
    {
        if(autoRefreshTimer != nil)
            autoRefreshTimer = nil;
    }
    
    // Reset badge value
    self.tabBarController.selectedIndex = TAB_ID;
    self.tabBarController.selectedViewController.tabBarItem.badgeValue = 0;
}

/*
- (void) viewDidDisappear: (BOOL) animated
{
    [super viewDidDisappear: animated];
    
    // squash the timer
    //autoRefreshTimer = nil;
}
 */

- (void) setNextTimer
{
    autoRefreshTimer = [NSTimer scheduledTimerWithTimeInterval: REFRESH_INTERVAL target: self selector: @selector(autoRefresh:) userInfo: nil repeats: NO];    
}

- (void) autoRefresh: (NSTimer*) timer
{
    NSLog(@"autorefreshing friends timeline");
    // Get the ID of the latest status update in the timeline
    NSDictionary *latestStatus = [self.timeline objectAtIndex: 0];
    NSInteger latestStatusID = [[latestStatus objectForKey: @"id"] intValue];
    
    // Get New Data
    NSMutableArray *updates = [[IdenticaAPI alloc] GetFriendsTimeline: 1 since_id: latestStatusID];
    [[Utilities alloc] downloadProfileImages: updates];
    
    // Merge into the timeline, putting newest at the top
    self.timeline = [updates arrayByAddingObjectsFromArray: self.timeline];
    // reload table
    [self.tableView reloadData];
    
    
    // set badge only if there's updates and we're not on the page
    NSInteger currentTab = self.tabBarController.selectedIndex;
    if([updates count] > 0 && currentTab > 0)
    {
        NSInteger previousUnread = [self.tabBarController.selectedViewController.tabBarItem.badgeValue intValue];
        NSInteger newUnread = previousUnread + [updates count];
        
        self.tabBarController.selectedIndex = TAB_ID;
        self.tabBarController.selectedViewController.tabBarItem.badgeValue = [NSString stringWithFormat: @"%i", newUnread];
        
        self.tabBarController.selectedIndex = currentTab;
    }
    
    // Make sure auto refresh is on
    if([[NSUserDefaults standardUserDefaults] boolForKey: @"autoRefresh"])
        [self setNextTimer];
}

- (void) deleteStatusWithID: (id) sender
{
    NSInteger statusIDToDelete = (NSInteger)[sender object];
    
    // Find it
    for(int row = 0; row < [self.timeline count]; ++row)
    {
        NSDictionary *status = [self.timeline objectAtIndex: row];
        if( (NSInteger)[status objectForKey: @"id"] == statusIDToDelete )
        {
            NSLog(@"deleting row %i", row);
            
            // delete it from the table
            [self.timeline removeObjectAtIndex: row];
            
            // reload the table
            [self.tableView reloadData];
            break;
        }
    }
}

- (void) addStatusSilently: (id) sender
{
    // i'd like to just add the status by itself, but if i put it in there it'll mess with any messages being sent between the last update
    // and when i send my message - so i'll just force a refresh
    
    // A simple refresh should do the trick
    // Get the ID of the latest status update in the timeline
    NSDictionary *latestStatus = [self.timeline objectAtIndex: 0];
    NSInteger latestStatusID = [[latestStatus objectForKey: @"id"] intValue];
    
    // Get New Data
    NSMutableArray *updates = [[IdenticaAPI alloc] GetFriendsTimeline: 1 since_id: latestStatusID];
    [[Utilities alloc] downloadProfileImages: updates];
    
    // Merge into the timeline, putting newest at the top
    self.timeline = [updates arrayByAddingObjectsFromArray: self.timeline];
    
    [self.tableView reloadData];
    
    /*
    NSInteger statusIDToAdd = (NSInteger)[sender object];
    
    // Find it
    for(int row = 0; row < [self.timeline count]; ++row)
    {
        NSDictionary *status = [self.timeline objectAtIndex: row];
        if( (NSInteger)[status objectForKey: @"id"] == statusIDToDelete )
        {
            NSLog(@"deleting row %i", row);
            
            // delete it from the table
            [self.timeline removeObjectAtIndex: row];
            
            // reload the table
            [self.tableView reloadData];
            break;
        }
    }
     */
}

/*
- (void)viewWillDisappear:(BOOL)animated {
	[super viewWillDisappear:animated];
}
*/

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
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
    // + 1 is for the "load more" button
    return [self.timeline count] + 1;
    //return [self.timeline count];
}


// Customize the appearance of table view cells.
- (UITableViewCell *) tableView: (UITableView *) tableView 
          cellForRowAtIndexPath: (NSIndexPath *) indexPath
{
    NSInteger row = [indexPath row];
    
    // Load More button
    if(row == [self.timeline count])
    {
        static NSString *CellIdentifier = @"LoadMoreCell";
        UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier: CellIdentifier];
        if(cell == nil)
        {
            cell = [[[UITableViewCell alloc] initWithFrame: CGRectZero reuseIdentifier: CellIdentifier] autorelease];
        }
        
        cell.textAlignment = UITextAlignmentCenter;
        cell.text = @"Load More";
        cell.textColor = [[UIColor alloc] initWithRed: 0.4f green: 0.4f blue: 0.4f alpha: 1];
        
        return cell;
    }
    else
    {
        static NSString *CellIdentifier = @"FriendsStatusCell";
        
        StatusCell *cell = (StatusCell *)[tableView dequeueReusableCellWithIdentifier: CellIdentifier];
        if(cell == nil)
        {
            NSArray *topLevelObjects = [[NSBundle mainBundle] loadNibNamed: @"StatusCell" owner: self options: nil];
            
            for (id currentObject in topLevelObjects)
            {
                if([currentObject isKindOfClass: [UITableViewCell class]])
                {
                    cell = (StatusCell *) currentObject;
                    break;
                }
            }
        }
        
        // Set cell data
        NSDictionary *status = [self.timeline objectAtIndex: row];
        
        [cell setData: status forRow: row];
        [cell setProfileImage: [[status objectForKey: @"user"] objectForKey: @"profile_image_url"]];
        
        return cell;
    }
}

-   (CGFloat) tableView: (UITableView *) tableView 
heightForRowAtIndexPath: (NSIndexPath *) indexPath
{
    NSInteger row = [indexPath row];
    
    // If it's the "load more" cell, make it smaller
    if(row == [self.timeline count])
        return 50;
    
    NSDictionary *status = [self.timeline objectAtIndex: row];
    
    NSString *text = [status objectForKey: @"text"];
    
    CGFloat result = 75.0f; // the minimum height you want it to be
    CGFloat width = 0;
    CGRect bounds = [UIScreen mainScreen].bounds;
    CGFloat tableViewWidth = bounds.size.width;
    width = tableViewWidth - 50;
    
    
    CGSize textSize = {width, 20000.0f};
    CGSize size = [text sizeWithFont: [UIFont systemFontOfSize: 12] constrainedToSize: textSize lineBreakMode: UILineBreakModeWordWrap];
    size.height += 20.0f;
    result = MAX(size.height, 75.0f);
    
    return result;
}


-      (void) tableView: (UITableView *) tableView
didSelectRowAtIndexPath: (NSIndexPath *) indexPath
{
    NSInteger row = [indexPath row];
    if(row == [self.timeline count])
    {
        ++page;
        NSLog(@"Loading page %i", page);
        
        // Get New Data
        NSMutableArray *updates = [[IdenticaAPI alloc] GetFriendsTimeline: page since_id: 0];
        
        // Were there updates?
        if([updates count] > 0)
        {
            // download their avatars
            [[Utilities alloc] downloadProfileImages: updates];
            
            // Merge into the timeline
            self.timeline = (NSMutableArray *)[self.timeline arrayByAddingObjectsFromArray: updates];
            
            // reload the table
            [self.tableView reloadData];
            
            // deselect the cell
            [tableView deselectRowAtIndexPath: indexPath animated: YES];
            
            // Scroll it to the top
            [tableView scrollToRowAtIndexPath: indexPath atScrollPosition: UITableViewScrollPositionMiddle animated: YES];
        }
        
        return;
    }
    
    StatusCell *cell = (StatusCell *)[tableView cellForRowAtIndexPath: indexPath];
    
    StatusViewController *statusViewController = [[StatusViewController alloc] initWithNibName: @"StatusView" bundle: nil showStatus: [cell getCellID]];
    statusViewController.hidesBottomBarWhenPushed = YES;
    [self.navigationController pushViewController: statusViewController animated: YES];
}

/* Methods To Enable Swiping */
/*
-   (BOOL) tableView: (UITableView *) tableView
canEditRowAtIndexPath: (NSIndexPath *) indexPath
{
    // Return NO if you do not want the specified item to be editable.
    return YES;
}

// the critical one
- (void) tableView: (UITableView *) tableView 
commitEditingStyle: (UITableViewCellEditingStyle) editingStyle
 forRowAtIndexPath: (NSIndexPath *) indexPath
{
    if (editingStyle == UITableViewCellEditingStyleDelete)
    {
        // Delete the row from the data source
        [tableView deleteRowsAtIndexPaths:[NSArray arrayWithObject: indexPath] withRowAnimation:YES];
    }   
    else if (editingStyle == UITableViewCellEditingStyleInsert)
    {
        // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
    }   
}

-            (void) tableView: (UITableView *) tableView
editingStyleForRowAtIndexPath: (NSIndexPath *) indexPath
{
    
}
*/

/* End Swipe Methods */


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


- (void) dealloc
{
    [timeline dealloc];
    [loadingView dealloc];
    [super dealloc];
}


@end

