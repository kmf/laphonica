//
//  MessageViewController.h
//  modentica2
//
//  Created by Mark Bockenstedt on 2/21/09.
//  Copyright 2009 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "LoadingView.h"

@interface MessageViewController : UIViewController <UITableViewDelegate>
{
    NSArray *inbox;
    NSArray *outbox;
    NSString *statusID;
    NSString *visibleView;
    
    IBOutlet UITableView *messageTableView;
    IBOutlet UISegmentedControl *viewSegmentController;
    
    LoadingView *loadingView;
}

// Properties
@property (nonatomic, retain) NSArray *inbox;
@property (nonatomic, retain) NSArray *outbox;
@property (nonatomic, assign) NSString *statusID;
@property (nonatomic, retain) NSString *visibleView;

@property (nonatomic, retain) UITableView *messageTableView;
@property (nonatomic, retain) UISegmentedControl *viewSegmentController;
@property (nonatomic, retain) LoadingView *loadingView;

// Methods
- (IBAction) showUpdateBox: (id) sender;
- (IBAction) refreshTimeline: (id) sender;
- (BOOL) inboxIsVisible;
- (BOOL) outboxIsVisible;
- (IBAction) switchView: (id) sender;

- (void) viewWillAppear: (BOOL) animated;
- (void) beginLoadingThreadData;
- (void) loadThreadData;
- (void) finishedLoadingThreadData;
- (void) viewDidAppear: (BOOL) animated;

@end
