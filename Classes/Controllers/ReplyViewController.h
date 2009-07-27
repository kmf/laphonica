//
//  ReplyViewController.h
//  modentica2
//
//  Created by Mark Bockenstedt on 2/21/09.
//  Copyright 2009 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "LoadingView.h"


@interface ReplyViewController : UITableViewController
{
    NSMutableArray *timeline;
    LoadingView *loadingView;
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

@end
