//
//  FriendViewController.h
//  modentica2
//
//  Created by Mark Bockenstedt on 2/6/09.
//  Copyright 2009 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "LoadingView.h"


@interface FriendViewController : UITableViewController
{
    NSMutableArray *timeline;
    LoadingView *loadingView;
    NSInteger page;
    
    NSTimeInterval *autoRefreshInterval;
    NSTimer *autoRefreshTimer;
}

// Properties
@property (nonatomic, retain) NSMutableArray *timeline;
@property (nonatomic, retain) LoadingView *loadingView;


// Methods
- (IBAction) showUpdateBox: (id) sender;
- (IBAction) refreshTimeline: (id) sender;

- (void) viewWillAppear: (BOOL) animated;
- (void) beginLoadingThreadData;
- (void) loadThreadData;
- (void) finishedLoadingThreadData;
- (void) viewDidAppear: (BOOL) animated;

// Notification methods
- (void) deleteStatusWithID: (id) sender;
- (void) addStatusSilently: (id) sender;

// timer-based methods
- (void) setNextTimer: (NSTimeInterval) interval;
- (void) setNextTimer;
- (void) autoRefresh: (NSTimer *) timer;

@end
