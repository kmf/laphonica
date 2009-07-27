//
//  ImageViewController.m
//  modentica2
//
//  Created by Mark Bockenstedt on 3/13/09.
//  Copyright 2009 __MyCompanyName__. All rights reserved.
//

#import "ImageViewController.h"

#import "REString.h"


@implementation ImageViewController

@synthesize imageView;

- (id) initWithNibName: (NSString *) nibNameOrNil
                bundle: (NSBundle *) nibBundleOrNil
                  href: (NSString *) href
{
    if (self = [super initWithNibName: nibNameOrNil bundle: nibBundleOrNil])
    {
        imageURL = href;
    }
    return self;
}

- (void) viewDidLoad
{
    [super viewDidLoad];
    
    NSArray *parts = [imageURL componentsSeparatedByString: @"/"];
    NSString *tail = [parts objectAtIndex: [parts count] - 1];
    
    UIImage *image;
    
    float totalWidth = 320.0;
    float totalHeight = 394.0;
    
    // TwitPic
    if([imageURL rangeOfString: @"twitpic" options: NSCaseInsensitiveSearch].location != NSNotFound)
    {
        // Get HTML
        /*
        NSString *html = [NSString stringWithContentsOfURL: [NSURL URLWithString: imageURL]];
        
        static NSString *picRegex = @"<div id=\"pic\" style=\"border:2px solid white;\" src=\"(.*)\" alt=\"\">";
        
        NSMutableArray *links = [NSMutableArray array];
        NSMutableArray *array = [NSMutableArray array];
        
        // Find URLs
        while ([html matches: picRegex withSubstring: array])
        {
            NSString *u = [array objectAtIndex: 0];
            [links addObject: u];
            NSRange r = [html rangeOfString: u];
            html = [html substringFromIndex: r.location + r.length];
            [array removeAllObjects];
        }
        
        NSLog(@"links %@", links);
         */
        
        NSString *imageURLString = [NSString stringWithFormat: @"http://twitpic.com/show/thumb/%@.jpg", tail];
        image = [self downloadImage: imageURLString];
    }
    
    // Pikchur
    if([imageURL rangeOfString: @"pikchur" options: NSCaseInsensitiveSearch].location != NSNotFound)
    {
        NSString *imageURLString = [NSString stringWithFormat: @"https://s3.amazonaws.com/pikchurimages/pic_%@_m.jpg", tail];
        [self downloadImage: imageURLString];
    }
    
    imageView.image = image;
}

- (UIImage *) downloadImage: (NSString *) url
{
    NSURL *picURL = [NSURL URLWithString: url];
    NSData *data = [[NSData alloc] initWithContentsOfURL: picURL];
    UIImage *image = [[UIImage alloc] initWithData: data];
    
    return image;
}

/*
// Override to allow orientations other than the default portrait orientation.
- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
    // Return YES for supported orientations
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}
*/

- (void) didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning]; // Releases the view if it doesn't have a superview
    // Release anything that's not essential, such as cached data
}


- (void) dealloc
{
    [super dealloc];
}


@end
