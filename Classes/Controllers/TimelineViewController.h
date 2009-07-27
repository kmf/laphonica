//
//  TimelineViewController.h
//  modentica2
//
//  Created by Mark Bockenstedt on 3/2/09.
//  Copyright 2009 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>


@interface TimelineViewController : UITableViewController
{
    NSArray *timeline;
    NSString *statusID;
    NSString *username;
    
    UIAlertView *progressAlert;
    UIActivityIndicatorView *activityView;
}

// Properties
@property (nonatomic, retain) NSArray *timeline;
@property (nonatomic, assign) NSString *statusID;
@property (nonatomic, retain) NSString *username;

@property (nonatomic, retain) UIAlertView *progressAlert;
@property (nonatomic, retain) UIActivityIndicatorView *activityView;

// Methods
- (IBAction) showUpdateBox: (id) sender;
- (IBAction) refreshTimeline: (id) sender;

- (void) viewWillAppear: (BOOL) animated;
- (void) beginLoadingThreadData;
- (void) loadThreadData;
- (void) finishedLoadingThreadData;
- (void) viewDidAppear: (BOOL) animated;

@end
