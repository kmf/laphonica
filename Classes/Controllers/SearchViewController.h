//
//  SearchViewController.h
//  modentica2
//
//  Created by Mark Bockenstedt on 3/27/09.
//  Copyright 2009 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "LoadingView.h"


@interface SearchViewController : UIViewController <UITableViewDelegate, UISearchBarDelegate, UITextFieldDelegate>
{
    IBOutlet UISearchBar *searchBar;
    IBOutlet UITableView *searchResultsTable;
    
    NSMutableArray *searchResults;
    LoadingView *loadingView;
    NSString *searchText;
    NSInteger page;
}

@property (nonatomic, retain) UISearchBar *searchBar;
@property (nonatomic, retain) UITableView *searchResultsTable;

@property (nonatomic, retain) NSMutableArray *searchResults;
@property (nonatomic, retain) LoadingView *loadingView;
@property (nonatomic, retain) NSString *searchText;

// Methods
- (id) initWithNibName: (NSString *) nibNameOrNil bundle: (NSBundle *) nibBundleOrNil searchText: (NSString *) searchText;
- (void) beginLoadingThreadData;
- (void) loadThreadData;
- (void) finishedLoadingThreadData;

- (void) saveSearch: (id) sender;

@end
