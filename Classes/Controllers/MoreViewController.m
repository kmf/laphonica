//
//  MoreViewController.m
//  modentica2
//
//  Created by Mark Bockenstedt on 2/6/09.
//  Copyright 2009 __MyCompanyName__. All rights reserved.
//

#import "MoreViewController.h"

#import "ComposeViewController.h"
#import "GoToUserViewController.h"
#import "SearchViewController.h"
#import "SettingsViewController.h"
#import "UserViewController.h"

@implementation MoreViewController

/*
- (id)initWithStyle:(UITableViewStyle)style {
    // Override initWithStyle: if you create the controller programmatically and want to perform customization that is not appropriate for viewDidLoad.
    if (self = [super initWithStyle:style]) {
    }
    return self;
}
*/

- (void) viewDidLoad
{
    [super viewDidLoad];

    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
    //self.navigationItem.rightBarButtonItem = self.editButtonItem;
}

- (void) showUpdateBox: (id) sender
{
    ComposeViewController *composeViewController = [[ComposeViewController alloc] initWithNibName: @"ComposeView" bundle: nil];
	[self.navigationController pushViewController: composeViewController animated: YES];
	[composeViewController release];
}

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

- (void) didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning]; // Releases the view if it doesn't have a superview
    // Release anything that's not essential, such as cached data
}

#pragma mark Table view methods

- (NSInteger) numberOfSectionsInTableView: (UITableView *) tableView
{
    return 4;
}


// Customize the number of rows in the table view.
- (NSInteger) tableView: (UITableView *) tableView
  numberOfRowsInSection: (NSInteger) section
{
    NSInteger rows;
    switch (section)
    {
        case 0: rows = 2; break;
        case 1: rows = 1; break;
        case 2: rows = 1; break;
        case 3: rows = 1; break;
    }
    
    return rows;
}

// Customize the appearance of table view cells.
- (UITableViewCell *) tableView: (UITableView *) tableView
          cellForRowAtIndexPath: (NSIndexPath *) indexPath
{
    static NSString *CellIdentifier = @"Cell";
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
        cell = [[[UITableViewCell alloc] initWithFrame:CGRectZero reuseIdentifier:CellIdentifier] autorelease];
        cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
    }
    
    // Set up the cell...
    switch (indexPath.section)
    {
        case 0:
            switch (indexPath.row)
            {
                case 0: cell.text = @"My Profile";  break;
                case 1: cell.text = @"Go to User";  break;
            }
            break;
        
        case 1:
            switch (indexPath.row)
            {
                case 0: cell.text = @"Search";      break;
            }
            break;
        
        case 2:
            switch (indexPath.row)
            {
                case 0: cell.text = @"Settings";    break;
            }
            break;
        
        case 3:
            switch (indexPath.row)
            {
                case 0: cell.text = @"Logout";      break;
            }
            break;
            
    }

    return cell;
}


-      (void) tableView: (UITableView *) tableView
didSelectRowAtIndexPath: (NSIndexPath *) indexPath
{
    UITableViewCell *cell = [tableView cellForRowAtIndexPath: indexPath];
    NSString *buttonText = cell.text;
    
    if([buttonText isEqualToString: @"My Profile"])
    {
        NSString *username = [[NSUserDefaults standardUserDefaults] objectForKey: @"username"];
        
        UserViewController *userViewController = [[UserViewController alloc] initWithNibName: @"UserView" bundle: nil showUser: username];
        userViewController.hidesBottomBarWhenPushed = YES;
        [self.navigationController pushViewController: userViewController animated: YES];
        [userViewController release];
    }
    else if([buttonText isEqualToString: @"Go to User"])
    {
        GoToUserViewController *goToUserViewController = [[GoToUserViewController alloc] initWithNibName: @"GoToUserView" bundle :nil];
        [self.navigationController pushViewController: goToUserViewController animated: YES];
        [goToUserViewController release];
    }
    else if([buttonText isEqualToString: @"Search"])
    {
        SearchViewController *svc = [[SearchViewController alloc] initWithNibName: @"SearchView" bundle: nil searchText: nil];
        [self.navigationController pushViewController: svc animated: YES];
        [svc release];
    }
    else if([buttonText isEqualToString: @"Settings"])
    {
        SettingsViewController *settingsViewController = [[SettingsViewController alloc] initWithNibName: @"SettingsView" bundle: nil];
        [self.navigationController pushViewController: settingsViewController animated: YES];
        [settingsViewController release];
    }
    else if([buttonText isEqualToString: @"Logout"])
    {
        NSLog(@"Clicked logout");
        /*
        NSUserDefaults *standardUserDefaults = [NSUserDefaults standardUserDefaults];
        
        [standardUserDefaults setObject: @"" forKey: @"username"];
        [standardUserDefaults setObject: @"" forKey: @"password"];
        [standardUserDefaults setObject: @"" forKey: @"domain"];
        [standardUserDefaults synchronize];
        
        // Load 'Settings View'
        SettingsViewController *settingsViewController = [[SettingsViewController alloc] initWithNibName: @"SettingsView" bundle: nil];
        [self.navigationController pushViewController: settingsViewController animated: YES];
        [settingsViewController release];
         */
    }
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

