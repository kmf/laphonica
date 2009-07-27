//
//  FollowerViewController.h
//  modentica2
//
//  Created by Mark Bockenstedt on 3/2/09.
//  Copyright 2009 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "LoadingView.h"


@interface FollowerViewController : UITableViewController
{
    NSString *parentUser;
    NSString *viewType;
    NSArray *userList;
    
    LoadingView *loadingView;
}

@property (nonatomic, retain) NSString *parentUser;
@property (nonatomic, retain) NSString *viewType;
@property (nonatomic, retain) NSArray *userList;

@property (nonatomic, retain) LoadingView *loadingView;

// Methods
- (id) initWithNibName: (NSString *) nibNameOrNil bundle: (NSBundle *) nibBundleOrNil parentUser: (NSString *) userParent view: (NSString *) view;
- (IBAction) showUpdateBox: (id) sender;

- (void) viewWillAppear: (BOOL) animated;
- (void) beginLoadingThreadData;
- (void) loadThreadData;
- (void) finishedLoadingThreadData;
- (void) downloadProfileImages;
- (void) viewDidAppear: (BOOL) animated;

@end
