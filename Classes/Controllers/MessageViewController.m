//
//  MessageViewController.m
//  modentica2
//
//  Created by Mark Bockenstedt on 2/6/09.
//  Copyright 2009 __MyCompanyName__. All rights reserved.
//

#import "MessageViewController.h"
#import "StatusViewController.h"
#import "ComposeViewController.h"
#import "LoadingView.h"

#import "IdenticaAPI.h"
#import "StatusCell.h"
#import "Utilities.h"


@implementation MessageViewController

@synthesize inbox, outbox, statusID, messageTableView, viewSegmentController, loadingView, visibleView;

/*
- (void) viewDidLoad
{
    [super viewDidLoad];
}
 */

- (void) showUpdateBox: (id) sender
{
    ComposeViewController *composeViewController = [[ComposeViewController alloc] initWithNibName: @"ComposeView" bundle: nil];
	[self.navigationController pushViewController: composeViewController animated: YES];
	[composeViewController release];
}

- (void) refreshTimeline: (id) sender
{
    // Show alert box
    self.loadingView = [[LoadingView alloc] initWithTitle: @"Refreshing Messages" message: @"Please wait..."];
    [self.loadingView startAnimating];
    
    // Get data
    if([self inboxIsVisible])
    {
        self.inbox = [[IdenticaAPI alloc] GetInbox: 1 since_id: 0];
        [[Utilities alloc] downloadProfileImages: self.inbox forDirectMessages: YES];
    }
    else if([self outboxIsVisible])
    {
        self.outbox = [[IdenticaAPI alloc] GetOutbox: 1 since_id: 0];
        [[Utilities alloc] downloadProfileImages: self.outbox forDirectMessages: YES];
    }
    
    [self.messageTableView reloadData];
    
    // Kill alert
    [self.loadingView dismissWithClickedButtonIndex: 0 animated: YES];
    self.loadingView = nil;
}
        
- (BOOL) inboxIsVisible
{
    if([self.visibleView isEqualToString: @"inbox"])
        return YES;
    else
        return NO;
}

- (BOOL) outboxIsVisible
{
    if([self.visibleView isEqualToString: @"outbox"])
        return YES;
    else
        return NO;
}

- (void) switchView: (id) sender
{
    if([self inboxIsVisible])
    {
        self.visibleView = @"outbox";
        
        if([self.outbox count] == 0)
        {
            self.outbox = [[IdenticaAPI alloc] GetOutbox: 1 since_id: 0];
            [[Utilities alloc] downloadProfileImages: self.outbox forDirectMessages: YES];
        }
        
        [self.messageTableView reloadData];
    }
    else if([self outboxIsVisible])
    {
        self.visibleView = @"inbox";
        
        if([self.inbox count] == 0)
        {
            self.inbox = [[IdenticaAPI alloc] GetInbox: 1 since_id: 0];
            [[Utilities alloc] downloadProfileImages: self.inbox forDirectMessages: YES];
        }
        
        [self.messageTableView reloadData];
    }
}

-(void) viewWillAppear: (BOOL) animated
{
    [super viewWillAppear: animated];
    
    self.loadingView = [[LoadingView alloc] initWithTitle: @"Loading Messages" message: @"Please wait..."];
    self.visibleView = @"inbox";
    
    [viewSegmentController addTarget: self action: @selector(switchView:) forControlEvents: UIControlEventValueChanged];
}

- (void) beginLoadingThreadData
{
    [self.loadingView startAnimating];
    [NSThread detachNewThreadSelector: @selector(loadThreadData) toTarget: self withObject: nil];
}

- (void) loadThreadData
{
    NSAutoreleasePool *pool = [[NSAutoreleasePool alloc] init];
    [self performSelectorOnMainThread: @selector(finishedLoadingThreadData) withObject: nil waitUntilDone: NO];
    [pool release];
}

- (void) finishedLoadingThreadData
{
    if([self inboxIsVisible])
    {
        self.inbox = [[IdenticaAPI alloc] GetInbox: 1 since_id: 0];
        [[Utilities alloc] downloadProfileImages: self.inbox forDirectMessages: YES];
    }
    else if([self outboxIsVisible])
    {
        self.outbox = [[IdenticaAPI alloc] GetInbox: 1 since_id: 0];
        [[Utilities alloc] downloadProfileImages: self.outbox forDirectMessages: YES];
    }    
    
    [self.loadingView dismissWithClickedButtonIndex: 0 animated: YES];
    self.loadingView = nil;
    
    [self.messageTableView reloadData];
}

- (void) viewDidAppear: (BOOL) animated
{
    [super viewDidAppear: animated];
    
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
    int count;
    if([self inboxIsVisible])
        count = [self.inbox count];
    else if([self outboxIsVisible])
        count = [self.outbox count];
    
    return count;
}


// Customize the appearance of table view cells.
- (UITableViewCell *) tableView: (UITableView *) tableView 
          cellForRowAtIndexPath: (NSIndexPath *) indexPath
{
    static NSString *cellID = @"MessageStatusCell";
    
    StatusCell *cell = (StatusCell *) [tableView dequeueReusableCellWithIdentifier: cellID];
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
    NSDictionary *status;
    if([self inboxIsVisible])
        status = [self.inbox objectAtIndex: indexPath.row];
    else if([self outboxIsVisible])
        status = [self.outbox objectAtIndex: indexPath.row];
    
    [cell setData: status forRow: indexPath.row forDirectMessage: YES];
    [cell setProfileImage: [[status objectForKey: @"sender"] objectForKey: @"profile_image_url"]];
    
    return cell;
    
    /*
    static NSString *CellIdentifier = @"Cell";
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
        cell = [[[UITableViewCell alloc] initWithFrame:CGRectZero reuseIdentifier:CellIdentifier] autorelease];
    }
    
    // Set up the cell...
    
    return cell;
     */
}

-   (CGFloat) tableView: (UITableView *) tableView 
heightForRowAtIndexPath: (NSIndexPath *) indexPath
{
    return 60.0f;
    
    NSDictionary *status;
    if([self inboxIsVisible])
        status = [self.inbox objectAtIndex: indexPath.row];
    else if([self outboxIsVisible])
        status = [self.outbox objectAtIndex: indexPath.row];
    
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
    /*
    StatusCell *cell = (StatusCell *)[tableView cellForRowAtIndexPath: indexPath];
    
    StatusViewController *statusViewController = [[StatusViewController alloc] initWithNibName: @"StatusView" bundle: nil];
    [statusViewController setCellID: [cell getCellID]];
    statusViewController.hidesBottomBarWhenPushed = YES;
    [self.navigationController pushViewController: statusViewController animated: YES];
     */
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


- (void) dealloc
{
    [inbox dealloc];
    [outbox dealloc];
    [super dealloc];
}


@end