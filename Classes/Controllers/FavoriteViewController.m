//
//  FriendViewController.m
//  modentica2
//
//  Created by Mark Bockenstedt on 2/6/09.
//  Copyright 2009 __MyCompanyName__. All rights reserved.
//

#import "FavoriteViewController.h"
#import "StatusViewController.h"
#import "ComposeViewController.h"

#import "IdenticaAPI.h"
#import "StatusCell.h"
#import "Utilities.h"


@implementation FavoriteViewController

@synthesize favorites, statusID, loadingView;

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
    self.loadingView = [[LoadingView alloc] initWithTitle: @"Refreshing Timeline" message: @"Please wait..."];
    [self.loadingView startAnimating];
    
    // Get Data
    NSString *loggedInUser = [[NSUserDefaults standardUserDefaults] objectForKey: @"username"];
    self.favorites = [[IdenticaAPI alloc] GetFavorites: loggedInUser page: 1];
    [[Utilities alloc] downloadProfileImages: self.favorites];
    [self.tableView reloadData];
    
    // Kill alert
    [self.loadingView dismissWithClickedButtonIndex: 0 animated: YES];
    self.loadingView = nil;
}

-(void) viewWillAppear: (BOOL) animated
{
    [super viewWillAppear: animated];
    
    if([self.favorites count] == 0)
        self.loadingView = [[LoadingView alloc] initWithTitle: @"Loading Favorites" message: @"Please wait..."];
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
    NSString *loggedInUser = [[NSUserDefaults standardUserDefaults] objectForKey: @"username"];
    
    self.favorites = [[IdenticaAPI alloc] GetFavorites: loggedInUser page: 1];
    [[Utilities alloc] downloadProfileImages: self.favorites];
    
    [self.loadingView dismissWithClickedButtonIndex: 0 animated: YES];
    self.loadingView = nil;
    
    [self.tableView reloadData];
}

- (void) viewDidAppear: (BOOL) animated
{
    [super viewDidAppear: animated];
    
    if([self.favorites count] == 0)
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

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}


// Customize the number of rows in the table view.
- (NSInteger) tableView: (UITableView *) tableView 
  numberOfRowsInSection: (NSInteger) section
{
    return [self.favorites count];
}


// Customize the appearance of table view cells.
- (UITableViewCell *) tableView: (UITableView *) tableView 
          cellForRowAtIndexPath: (NSIndexPath *) indexPath
{
    static NSString *cellID = @"FavoriteStatusCell";
    
    StatusCell *cell = (StatusCell *) [tableView dequeueReusableCellWithIdentifier: cellID];
    if(cell == nil)
    {
        //cell = [[[StatusCell alloc] initWithFrame: CGRectZero reuseIdentifier: cellID] autorelease];
        
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
    NSDictionary *status = [self.favorites objectAtIndex:indexPath.row];
    
    [cell setData: status forRow: indexPath.row];
    [cell setProfileImage: [[status objectForKey: @"user"] objectForKey: @"profile_image_url"]];
    
    return cell;
}

-   (CGFloat) tableView: (UITableView *) tableView 
heightForRowAtIndexPath: (NSIndexPath *) indexPath
{
    NSDictionary *status = [self.favorites objectAtIndex: indexPath.row];
    
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
    StatusCell *cell = (StatusCell *)[tableView cellForRowAtIndexPath: indexPath];
    
    StatusViewController *statusViewController = [[StatusViewController alloc] initWithNibName: @"StatusView" bundle: nil showStatus: [cell getCellID]];
    statusViewController.hidesBottomBarWhenPushed = YES;
    [self.navigationController pushViewController: statusViewController animated: YES];
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
    [favorites dealloc];
    [super dealloc];
}


@end

