//
//  ImageViewController.h
//  modentica2
//
//  Created by Mark Bockenstedt on 3/13/09.
//  Copyright 2009 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>


@interface ImageViewController : UIViewController
{
    IBOutlet UIImageView *imageView;
    NSString *imageURL;
}

@property (nonatomic, retain) UIImageView *imageView;

- (UIImage *) downloadImage: (NSString *) url;

@end
