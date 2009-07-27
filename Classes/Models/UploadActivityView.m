//
//  UploadActivityView.m
//  modentica2
//
//  Created by Mark Bockenstedt on 3/5/09.
//  Copyright 2009 __MyCompanyName__. All rights reserved.
//

#import "UploadActivityView.h"


@implementation UploadActivityView

@synthesize activityIndicatorView, imageView;

- (id) initWithTitle: (NSString *) title
             message: (NSString *) message
            delegate: (id) delegate
   cancelButtonTitle: (NSString *) cancelButtonTitle
   otherButtonTitles: (NSString *) otherButtonTitles
{
    if (self = [super initWithTitle: title message: message delegate: delegate cancelButtonTitle: cancelButtonTitle otherButtonTitles: otherButtonTitles])
    {
        imageView = [[UIImageView alloc] initWithFrame: CGRectMake(121.0f, 80.0f, 37.0f, 37.0f)];
        [self addSubview: imageView];
        
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

- (void) dealloc
{
    [activityIndicatorView dealloc];
    [imageView dealloc];
    [super dealloc];
}

@end
