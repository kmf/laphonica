//
//  LoadingView.h
//  modentica2
//
//  Created by Mark Bockenstedt on 3/3/09.
//  Copyright 2009 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <Foundation/Foundation.h>

@interface LoadingView : UIAlertView
{
    UIActivityIndicatorView *activityIndicatorView;
    UIProgressView *progressView;
}

@property (nonatomic, retain) UIActivityIndicatorView *activityIndicatorView;
@property (nonatomic, retain) UIProgressView *progressView;

- (id) initWithTitle: (NSString *) title message: (NSString *) message asProgress: (BOOL) asProgress;
- (id) initWithTitle: (NSString *) title message: (NSString *) message;
- (void) startAnimating;
- (void) kill;

- (void) addValue: (float) value;

@end
