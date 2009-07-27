//
//  UploadActivityView.h
//  modentica2
//
//  Created by Mark Bockenstedt on 3/5/09.
//  Copyright 2009 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>


@interface UploadActivityView : UIAlertView
{
    UIImageView *imageView;
    UIActivityIndicatorView *activityIndicatorView;
}

@property (nonatomic, retain) UIImageView *imageView;
@property (nonatomic, retain) UIActivityIndicatorView *activityIndicatorView;

- (id) initWithTitle: (NSString *) title message: (NSString *) message delegate: (id) delegate cancelButtonTitle: (NSString *) cancelButtonTitle otherButtonTitles: (NSString *) otherButtonTitles;
- (void) startAnimating;
- (void) kill;

@end
