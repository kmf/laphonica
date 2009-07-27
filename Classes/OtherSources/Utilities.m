//
//  utils.m
//  modentica2
//
//  Created by Mark Bockenstedt on 2/23/09.
//  Copyright 2009 __MyCompanyName__. All rights reserved.
//

#import "Utilities.h"

#define TMP NSTemporaryDirectory()

@implementation Utilities

/* ======================================================================
 
 TIMESTAMP FUNCTIONS
 
 ======================================================================*/

- (NSString *) formatDate: (NSString *) date
{
    // Convert string to date
    NSDateFormatter *inputFormatter = [[NSDateFormatter alloc] init];
    [inputFormatter setDateFormat: @"EEE MMM dd HH:mm:ss '+0000' yyyy"];
    
    NSDate *formatterDate = [inputFormatter dateFromString: date];
    
    NSDateFormatter *outputFormatter = [[[NSDateFormatter alloc] init] autorelease];
    [outputFormatter setDateFormat: @"MMM d',' yyyy"];
    
    NSString *newDateString = [outputFormatter stringFromDate: formatterDate];
    
    return newDateString;
}

- (NSString *) formatTimestamp: (NSString *) timestamp
{
    // Load Offset
    int offset = [[[NSUserDefaults standardUserDefaults] objectForKey: @"utc_offset"] intValue];
    
    NSDateFormatter *f = [[NSDateFormatter alloc] init];
    [f setDateFormat: @"EEE MMM dd HH:mm:ss '+0000' yyyy"];
    NSDate *formattedDate = [[f dateFromString: timestamp] addTimeInterval: offset];
    
    NSDateFormatter *outputFormatter = [[[NSDateFormatter alloc] init] autorelease];
    [outputFormatter setDateFormat: @"EEE M/dd h:mm a"];
    
    // Figure out offset Date
    NSString *newDateString = [outputFormatter stringFromDate: formattedDate];
    return newDateString;
}

- (NSString *) formatTimestamp: (NSString *) timestamp
                 forStatusView: (BOOL) forStatusView
{
    // Load Offset
    int offset = [[[NSUserDefaults standardUserDefaults] objectForKey: @"utc_offset"] intValue];
    
    NSDateFormatter *f = [[NSDateFormatter alloc] init];
    [f setDateFormat: @"EEE MMM dd HH:mm:ss '+0000' yyyy"];
    NSDate *formattedDate = [[f dateFromString: timestamp] addTimeInterval: offset];
    
    NSDateFormatter *outputFormatter = [[[NSDateFormatter alloc] init] autorelease];
    [outputFormatter setDateFormat: @"EEE, MMM dd 'at' h:mm a"];
    
    // Figure out offset Date
    NSString *newDateString = [outputFormatter stringFromDate: formattedDate];
    return newDateString;
}

/* ======================================================================
 
 IMAGE CACHING FUNCTIONS
 
 ======================================================================*/

- (void) purgeCache
{
    
}

- (void) cacheImage: (NSString *) profileImageURLString
{
    NSURL *profileImageURL = [NSURL URLWithString: profileImageURLString];
    
    // Write to tmp if it's not already there
    NSString *filename = [profileImageURLString stringByReplacingOccurrencesOfString: @"http://avatar.identi.ca/" withString: @""];
    NSString *uniquePath = [TMP stringByAppendingPathComponent: filename];
    if(![[NSFileManager defaultManager] fileExistsAtPath: uniquePath])
    {
        // Fetch image
        NSData *data = [[NSData alloc] initWithContentsOfURL: profileImageURL];
        UIImage *image = [[UIImage alloc] initWithData: data];
        
        // Do we want to round the corners?
        image = [self roundCorners: image];
        
        // Is it JPEG or PNG?
        if([profileImageURLString rangeOfString: @".png" options: NSCaseInsensitiveSearch].location != NSNotFound)
        {
            [UIImagePNGRepresentation(image) writeToFile: uniquePath atomically: YES];
        }
        else if(
                [profileImageURLString rangeOfString: @".jpg" options: NSCaseInsensitiveSearch].location != NSNotFound || 
                [profileImageURLString rangeOfString: @".jpeg" options: NSCaseInsensitiveSearch].location != NSNotFound
                )
        {
            [UIImageJPEGRepresentation(image, 100) writeToFile: uniquePath atomically: YES];
        }
    }
}

- (UIImage *) getCachedImage: (NSString *) profileImageURLString
              defaultToSmall: (BOOL) defaultToSmall
{
    NSString *filename = [profileImageURLString stringByReplacingOccurrencesOfString: @"http://avatar.identi.ca/" withString: @""];
    NSString *uniquePath = [TMP stringByAppendingPathComponent: filename];
    
    UIImage *profileImage;
    
    // Set the default image
    if(defaultToSmall)
        profileImage = [UIImage imageWithContentsOfFile: @"profileImageSmall.png"];
    else
        profileImage = [UIImage imageWithContentsOfFile: @"profileImage.png"];
    
    // Check for a cached version
    if([[NSFileManager defaultManager] fileExistsAtPath: uniquePath])
    {
        profileImage = [UIImage imageWithContentsOfFile: uniquePath];
    }
    else
    {
        // get a new one
        [self cacheImage: profileImageURLString];
        profileImage = [UIImage imageWithContentsOfFile: uniquePath];
    }

    return profileImage;
}

- (void) downloadProfileImages: (NSArray *) statuses
{
    // Go thru and cache images
    for(NSDictionary *status in statuses)
    {
        [self cacheImage: [[status objectForKey: @"user"] objectForKey: @"profile_image_url"]];
    }
}

- (void) downloadProfileImages: (NSArray *) statuses
             forDirectMessages: (BOOL) forDirectMessages
{
    // Go thru and cache images
    for(NSDictionary *status in statuses)
    {
        NSString *profileImageURL = [[status objectForKey: @"sender"] objectForKey: @"profile_image_url"];
        [self cacheImage: profileImageURL];
    }
}

- (void) downloadProfileImages: (NSArray *) statuses
                     forSearch: (BOOL) forSearch
{
    // Go thru and cache images
    for(NSDictionary *status in statuses)
    {
        NSString *profileImageURL = [status objectForKey: @"profile_image_url"];
        [self cacheImage: profileImageURL];
    }
}

- (void) downloadProfileImages: (NSArray *) users
                   forUserList: (BOOL) forUserList
{
    // Go thru and cache images
    for(NSDictionary *user in users)
    {
        [self cacheImage: [user objectForKey: @"profile_image_url"]];
    }
}

static void addRoundedRectToPath(CGContextRef context, CGRect rect, float ovalWidth, float ovalHeight)
{
    float fw, fh;
    if (ovalWidth == 0 || ovalHeight == 0)
    {
        CGContextAddRect(context, rect);
        return;
    }
    CGContextSaveGState(context);
    CGContextTranslateCTM (context, CGRectGetMinX(rect), CGRectGetMinY(rect));
    CGContextScaleCTM (context, ovalWidth, ovalHeight);
    fw = CGRectGetWidth (rect) / ovalWidth;
    fh = CGRectGetHeight (rect) / ovalHeight;
    CGContextMoveToPoint(context, fw, fh/2);
    CGContextAddArcToPoint(context, fw, fh, fw/2, fh, 1);
    CGContextAddArcToPoint(context, 0, fh, 0, fh/2, 1);
    CGContextAddArcToPoint(context, 0, 0, fw/2, 0, 1);
    CGContextAddArcToPoint(context, fw, 0, fw, fh/2, 1);
    CGContextClosePath(context);
    CGContextRestoreGState(context);
}

- (UIImage *) roundCorners: (UIImage*) img
{
    int w = img.size.width;
    int h = img.size.height;
    
    CGColorSpaceRef colorSpace = CGColorSpaceCreateDeviceRGB();
    CGContextRef context = CGBitmapContextCreate(NULL, w, h, 8, 4 * w, colorSpace, kCGImageAlphaPremultipliedFirst);
    
    CGContextBeginPath(context);
    CGRect rect = CGRectMake(0, 0, img.size.width, img.size.height);
    addRoundedRectToPath(context, rect, 5, 5);
    CGContextClosePath(context);
    CGContextClip(context);
    
    CGContextDrawImage(context, CGRectMake(0, 0, w, h), img.CGImage);
    
    CGImageRef imageMasked = CGBitmapContextCreateImage(context);
    CGContextRelease(context);
    CGColorSpaceRelease(colorSpace);
    [img release];
    
    return [UIImage imageWithCGImage:imageMasked];
}

@end
