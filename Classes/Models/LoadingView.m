//
//  LoadingView.m
//  modentica2
//
//  Created by Mark Bockenstedt on 3/3/09.
//  Copyright 2009 __MyCompanyName__. All rights reserved.
//

#import "LoadingView.h"


@implementation LoadingView

@synthesize activityIndicatorView, progressView;

- (id) initWithTitle: (NSString *) title
             message: (NSString *) message
          asProgress: (BOOL) asProgress
{
    if (self = [super initWithTitle: title message: message delegate: self cancelButtonTitle: nil otherButtonTitles: nil])
    {
        progressView = [[UIProgressView alloc] initWithProgressViewStyle: UIProgressViewStyleDefault];
        progressView.frame = CGRectMake(70.0f, 80.0f, 150.0f, 9.0f);
        [self addSubview: progressView];
        
        [super show];
    }
    
    return self;
}

- (id) initWithTitle: (NSString *) title
             message: (NSString *) message
{
    if (self = [super initWithTitle: title message: message delegate: self cancelButtonTitle: nil otherButtonTitles: nil])
    {
        activityIndicatorView = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle: UIActivityIndicatorViewStyleWhite];
        activityIndicatorView.frame = CGRectMake(121.0f, 80.0f, 37.0f, 37.0f);
        [self addSubview: activityIndicatorView];
    }
    
    return self;
}

- (void) startAnimating
{
    [activityIndicatorView startAnimating];
    [super show];
}

- (void) kill
{
    [self dismissWithClickedButtonIndex: 0 animated: YES];
    [self release];
}

- (void) addValue: (float) value
{
    NSLog(@"adding %f", value);
    progressView.progress = progressView.progress + value;
    NSLog(@"total progress: %f", progressView.progress);
}


- (void) dealloc
{
    [activityIndicatorView release];
    [progressView release];
    [super dealloc];
}


@end
