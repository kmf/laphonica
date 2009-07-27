//
//  SearchViewController.m
//  modentica2
//
//  Created by Mark Bockenstedt on 3/27/09.
//  Copyright 2009 __MyCompanyName__. All rights reserved.
//

#import "SearchViewController.h"

#import "StatusViewController.h"

#import "IdenticaAPI.h"
#import "LoadingView.h"
#import "StatusCell.h"
#import "Utilities.h"


@implementation SearchViewController

@synthesize searchBar, searchResultsTable, searchResults, loadingView, searchText;

- (id) initWithNibName: (NSString *) nibNameOrNil
                bundle: (NSBundle *) nibBundleOrNil
            searchText: (NSString *) text
{
    if(self = [super initWithNibName: nibNameOrNil bundle: nibBundleOrNil])
    {
        self.searchText = text;
        
        UIBarButtonItem *favoriteButton = [[[UIBarButtonItem alloc] 
                                        initWithTitle: @"Save" 
                                        style: UIBarButtonItemStyleBordered
                                        target: self
                                        action: @selector(saveSearch:)] autorelease]; 
        self.navigationItem.rightBarButtonItem = favoriteButton;
        self.navigationItem.title = @"Search";
        
        [searchBar setAutocapitalizationType: UITextAutocapitalizationTypeNone];
        [searchBar setAutocorrectionType: UITextAutocorrectionTypeNo];
        
        self.loadingView = [[LoadingView alloc] initWithTitle: @"Searching" message: @"Please wait..."];
        
        page = 1;
    }
    
    return self;
}

- (void) searchBarSearchButtonClicked: (UISearchBar *) bar
{
    [searchBar resignFirstResponder];
    
    [self beginLoadingThreadData];
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
    self.searchResults = [[IdenticaAPI alloc] Search: searchBar.text page: 1];
    
    // Download profile images
    [[Utilities alloc] downloadProfileImages: self.searchResults forSearch: YES];
    
    // Dump the loading view
    [self.loadingView dismissWithClickedButtonIndex: 0 animated: YES];
    self.loadingView = nil;
    
    // reload the data
    [self.searchResultsTable reloadData];
}
/* End Threading */


- (void) viewDidLoad
{
    [super viewDidLoad];
    
    if([self.searchText length] > 0)
    {
        searchBar.text = searchText;
        [self beginLoadingThreadData];
    }
    else
        [searchBar becomeFirstResponder];
}

- (void) saveSearch: (id) sender
{
    NSString *query = searchBar.text;
    if([query length] > 0)
    {
        NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
        
        NSMutableArray *savedSearches = (NSMutableArray *)[defaults arrayForKey: @"savedSearches"];
        NSLog(@"saved Searches: %@", savedSearches);
        
        [savedSearches addObject: query];
            
        [defaults setObject: savedSearches forKey: @"savedSearches"];
        [defaults synchronize];
    }
}

- (void) removeSavedSearch: (id) sender
{
    NSString *query = searchBar.text;
    if([query length] > 0)
    {
        NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
        
        NSMutableArray *savedSearches = (NSMutableArray *)[defaults arrayForKey: @"savedSearches"];
        NSLog(@"saved Searches: %@", savedSearches);
        
        [savedSearches removeObject: query];
        
        [defaults setObject: savedSearches forKey: @"savedSearches"];
        [defaults synchronize];
    }
}

/*
- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
}
*/

/*
- (void) viewDidAppear: (BOOL) animated
{
    [super viewDidAppear: animated];
}
*/

- (void) didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
}

#pragma mark Table view methods

- (NSInteger) numberOfSectionsInTableView: (UITableView *) tableView
{
    return 1;
}

- (NSInteger) tableView: (UITableView *) tableView
  numberOfRowsInSection: (NSInteger) section
{
    return [self.searchResults count] + 1;
}


- (UITableViewCell *) tableView: (UITableView *) tableView 
          cellForRowAtIndexPath: (NSIndexPath *) indexPath
{
    NSInteger row = [indexPath row];
    
    // Load More button
    if(row == [self.searchResults count])
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
        static NSString *CellIdentifier = @"SearchStatusCell";
        
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
        NSDictionary *status = [self.searchResults objectAtIndex: row];
        
        [cell setData: status forRow: row forSearch: YES];
        [cell setProfileImage: [status objectForKey: @"profile_image_url"]];
        
        return cell;
    }
}

-   (CGFloat) tableView: (UITableView *) tableView 
heightForRowAtIndexPath: (NSIndexPath *) indexPath
{
    NSInteger row = [indexPath row];
    
    // If it's the "load more" cell, make it smaller
    if(row == [self.searchResults count])
        return 50;
    
    NSDictionary *status = [self.searchResults objectAtIndex: row];
    
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
    if(row == [self.searchResults count])
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
            self.searchResults = (NSMutableArray *)[self.searchResults arrayByAddingObjectsFromArray: updates];
            
            // reload the table
            [self.searchResultsTable reloadData];
            
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

#pragma mark UITextFieldDelegate methods

- (BOOL) textFieldShouldReturn: (UITextField *) textField
{
    [textField resignFirstResponder];
    return YES;
}


- (void) dealloc
{
    [searchResults dealloc];
    [super dealloc];
}


@end

