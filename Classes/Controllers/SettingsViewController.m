//
//  SettingsViewController.m
//  modentica2
//
//  Created by Mark Bockenstedt on 3/5/09.
//  Copyright 2009 __MyCompanyName__. All rights reserved.
//

#import "SettingsViewController.h"

#import "AccountViewController.h"
#import "ComposeViewController.h"
#import "InitialLoadViewController.h"
#import "OpenLinkViewController.h"
#import "PikchurAccountViewController.h"

#import "IdenticaAPI.h"


@implementation SettingsViewController

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

    self.navigationItem.title = @"Settings";
    
    [self.tableView reloadData];
}

- (void) showUpdateBox: (id) sender
{
    ComposeViewController *composeViewController = [[ComposeViewController alloc] initWithNibName: @"ComposeView" bundle: nil];
	[self.navigationController pushViewController: composeViewController animated: YES];
	[composeViewController release];
}

- (void) switchAction: (id) sender
{
    BOOL doAutoRefresh;
    
    if([sender isOn])
        doAutoRefresh = true;
    else
        doAutoRefresh = false;

    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    [defaults setBool: doAutoRefresh forKey: @"autoRefresh"];
    [defaults synchronize];

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
    return 5;
}


// Customize the number of rows in the table view.
- (NSInteger) tableView: (UITableView *) tableView
  numberOfRowsInSection: (NSInteger) section
{
    return 1;
}


- (UITableViewCell *) tableView: (UITableView *) tableView
          cellForRowAtIndexPath: (NSIndexPath *) indexPath
{
    static NSString *CellIdentifier = @"Cell";
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
        cell = [[[UITableViewCell alloc] initWithFrame: CGRectZero reuseIdentifier: CellIdentifier] autorelease];
        cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
    }
    
    // Set up the cell...
    switch (indexPath.section)
    {
        case 0:
            cell.text = @"Account Settings";
            break;
        
        case 1:
            cell.text = @"Pikchur";
            break;
            
        case 2:
            cell.text = @"Initial Load";
            
            // Add current count to cell
            UILabel *initialLoadCountLabel = [[UILabel alloc] initWithFrame: CGRectMake(250.0f, 12.0f, 20.0f, 20.0f)];
            initialLoadCountLabel.text = [[NSUserDefaults standardUserDefaults] objectForKey: @"initialLoad"];
            initialLoadCountLabel.font = [UIFont systemFontOfSize: 16];
            initialLoadCountLabel.textColor = [UIColor blueColor];
            
            [cell.contentView addSubview: initialLoadCountLabel];
            break;
            
        case 3:
            cell.text = @"Open Links With";
            
            // Add current count to cell
            UILabel *openLabel = [[UILabel alloc] initWithFrame: CGRectMake(125.0f, 12.0f, 145.0f, 20.0f)];
            openLabel.text = [[NSUserDefaults standardUserDefaults] objectForKey: @"openLinksIn"];
            openLabel.font = [UIFont systemFontOfSize: 16];
            openLabel.textColor = [UIColor blueColor];
            openLabel.textAlignment = UITextAlignmentRight;
            openLabel.backgroundColor = [UIColor clearColor];
            
            [cell.contentView addSubview: openLabel];
            break;
        
        case 4:
            cell.text = @"Auto Refresh";
            cell.accessoryType = UITableViewCellAccessoryNone;
            
            // Add the UISwitch
            UISwitch *refreshSwitch = [[UISwitch alloc] initWithFrame: CGRectMake(180.0f, 9.0f, 50.0f, 20.0f)];
            [refreshSwitch addTarget: self action: @selector(switchAction:) forControlEvents: UIControlEventValueChanged];
            
            if([[NSUserDefaults standardUserDefaults] boolForKey: @"autoRefresh"])
                refreshSwitch.on = YES;
            else
                refreshSwitch.on = NO;
            
            [cell.contentView addSubview: refreshSwitch];
            break;
    }

    return cell;
}


-      (void) tableView: (UITableView *) tableView
didSelectRowAtIndexPath: (NSIndexPath *) indexPath
{
    UITableViewCell *cell = [tableView cellForRowAtIndexPath: indexPath];
    NSString *buttonText = cell.text;
    
    if([buttonText isEqualToString: @"Account Settings"])
    {
        AccountViewController *accountViewController = [[AccountViewController alloc] initWithNibName: @"AccountView" bundle: nil];
        [self.navigationController pushViewController: accountViewController animated: YES];
        [accountViewController release];
    }
    else if([buttonText isEqualToString: @"Pikchur"])
    {
        PikchurAccountViewController *pavc = [[PikchurAccountViewController alloc] initWithNibName: @"PikchurAccountView" bundle: nil];
        [self.navigationController pushViewController: pavc animated: YES];
        [pavc release];
    }
    else if([buttonText isEqualToString: @"Initial Load"])
    {
        InitialLoadViewController *initialLoadViewController = [[InitialLoadViewController alloc] initWithNibName: @"InitialLoadView" bundle: nil];
        [self.navigationController pushViewController: initialLoadViewController animated: YES];
        [initialLoadViewController release];
    }
    else if([buttonText isEqualToString: @"Open Links With"])
    {
        OpenLinkViewController *openLinkviewController = [[OpenLinkViewController alloc] initWithNibName: @"OpenLinkView" bundle: nil];
        [self.navigationController pushViewController: openLinkviewController animated: YES];
        [openLinkviewController release];
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

