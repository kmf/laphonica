//
//  TimelineViewController.m
//  modentica2
//
//  Created by Mark Bockenstedt on 3/2/09.
//  Copyright 2009 __MyCompanyName__. All rights reserved.
//

#import "TimelineViewController.h"
#import "StatusViewController.h"
#import "ComposeViewController.h"

#import "IdenticaAPI.h"
#import "StatusCell.h"

#define TMP [NSHomeDirectory() stringByAppendingPathComponent: @"tmp"]

@implementation TimelineViewController

@synthesize timeline, statusID, progressAlert, activityView, username;

/*
- (void) viewDidLoad
{
    [super viewDidLoad];
}
*/

- (id) initWithNibName: (NSString *) nibNameOrNil
                bundle: (NSBundle *) nibBundleOrNil
              showUser: (NSString *) usernameToShow
{
    if (self = [super initWithNibName: nibNameOrNil bundle: nibBundleOrNil])
    {
        UIBarButtonItem *composeButton = [[[UIBarButtonItem alloc] 
                                          initWithBarButtonSystemItem: UIBarButtonSystemItemCompose 
                                          target: self 
                                          action: @selector(showUpdateBox:)] autorelease];
        
        self.navigationItem.rightBarButtonItem = composeButton;
        
        self.navigationItem.title = @"Recent Updates";
        
        UIBarButtonItem *backButton = [[[UIBarButtonItem alloc] 
                                           initWithTitle: @"Back" 
                                           style: UIBarButtonItemStyleBordered
                                           target: self
                                           action: @selector(goBack:)] autorelease]; 
        
        self.navigationItem.leftBarButtonItem = backButton;
        
        self.username = usernameToShow;
    }
    
    return self;
}

- (void) showUpdateBox: (id) sender
{
    NSLog(@"Showing update box");
    
    ComposeViewController *composeViewController = [[ComposeViewController alloc] initWithNibName: @"ComposeView" bundle: nil];
	[self.navigationController pushViewController: composeViewController animated: YES];
	[composeViewController release];
}

- (void) refreshTimeline: (id) sender
{
    NSLog(@"Refreshing timeline");
    [self beginLoadingThreadData];
    [self.tableView reloadData];
}

- (void) goBack: (id) sender
{
    [self.navigationController popViewControllerAnimated: YES];
}

-(void) viewWillAppear: (BOOL) animated
{
    [super viewWillAppear: animated];
    
    if([self.timeline count] == 0)
    {
        self.progressAlert = [[UIAlertView alloc] initWithTitle: @"Loading Data"
                                                        message: @"Please wait..."
                                                       delegate: self
                                              cancelButtonTitle: nil
                                              otherButtonTitles: nil];
        self.activityView = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle: UIActivityIndicatorViewStyleWhite];
        self.activityView.frame = CGRectMake(121.0f, 80.0f, 37.0f, 37.0f);
        [self.progressAlert addSubview: self.activityView];
        [self.activityView startAnimating];
        [self.progressAlert show];
        [self.progressAlert release];
    }
}

- (void) beginLoadingThreadData
{
    [self.activityView startAnimating];
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
    // Call the time consuming method here.
    IdenticaAPI *API = [IdenticaAPI alloc];
    self.timeline = [API GetUserTimeline: self.username page: 1 since_id: 0];
    
    // Go thru and cache images
    for(NSDictionary *status in self.timeline)
    {
        NSString *profileImageURLString = [[status objectForKey: @"user"] objectForKey: @"profile_image_url"];
        NSURL *profileImageURL = [NSURL URLWithString: profileImageURLString];
        
        // Write to tmp if it's not already there
        NSString *filename = [profileImageURLString stringByReplacingOccurrencesOfString: @"http://avatar.identi.ca/" withString: @""];
        NSString *uniquePath = [TMP stringByAppendingPathComponent: filename];
        if(![[NSFileManager defaultManager] fileExistsAtPath: uniquePath])
        {
            // Fetch image
            NSData *data = [[NSData alloc] initWithContentsOfURL: profileImageURL];
            UIImage *image = [[UIImage alloc] initWithData: data];
            
            // Is it JPEG or PNG?
            if([profileImageURLString rangeOfString: @".png" options: NSCaseInsensitiveSearch].location != NSNotFound)
            {
                [UIImagePNGRepresentation(image) writeToFile: uniquePath atomically: YES];
            }
            else if(
                    [profileImageURLString rangeOfString: @".jpg" options: NSCaseInsensitiveSearch].location != NSNotFound || 
                    [profileImageURLString rangeOfString: @".jpeg" options: NSCaseInsensitiveSearch].location != NSNotFound
                    )
            {
                [UIImageJPEGRepresentation(image, 100) writeToFile: uniquePath atomically: YES];
            }
        }
    }
    
    
    [progressAlert dismissWithClickedButtonIndex: 0 animated: YES];
    progressAlert = nil;
    
    [self.tableView reloadData];
}

- (void) viewDidAppear: (BOOL) animated
{
    [super viewDidAppear: animated];
    
    if([self.timeline count] == 0)
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

#pragma mark Table view methods

- (NSInteger) numberOfSectionsInTableView: (UITableView *) tableView
{
    return 1;
}


// Customize the number of rows in the table view.
- (NSInteger) tableView: (UITableView *) tableView 
  numberOfRowsInSection: (NSInteger) section
{
    return [self.timeline count];
}


// Customize the appearance of table view cells.
- (UITableViewCell *) tableView: (UITableView *) tableView 
          cellForRowAtIndexPath: (NSIndexPath *) indexPath
{
    static NSString *cellID = @"FriendsStatusCell";
    
    StatusCell *cell = (StatusCell *)[tableView dequeueReusableCellWithIdentifier: cellID];
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
    NSDictionary *status = [self.timeline objectAtIndex:indexPath.row];
    
    [cell setData: status forRow: indexPath.row];
    [cell setProfileImage: [[status objectForKey: @"user"] objectForKey: @"profile_image_url"]];
    
    return cell;
}

-   (CGFloat) tableView: (UITableView *) tableView 
heightForRowAtIndexPath: (NSIndexPath *) indexPath
{
    NSDictionary *status = [self.timeline objectAtIndex: indexPath.row];
    
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
- (id)initWithStyle:(UITableViewStyle)style {
    // Override initWithStyle: if you create the controller programmatically and want to perform customization that is not appropriate for viewDidLoad.
    if (self = [super initWithStyle:style]) {
    }
    return self;
}
*/

/*
- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
}
*/
/*
- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
}
*/
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
    [timeline dealloc];
    [super dealloc];
}


@end

