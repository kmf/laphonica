//
//  PikchurAPI.m
//  modentica2
//
//  Created by Mark Bockenstedt on 2/28/09.
//  Copyright 2009 __MyCompanyName__. All rights reserved.
//

#import "PikchurAPI.h"
#import "JSON/JSON.h"
#import "StringUtil.h"

#define TMP [NSHomeDirectory() stringByAppendingPathComponent: @"tmp"]
#define DEV_KEY @"ghdekZQKplOHGUyRZvPaNg"
#define APP_ORIGIN_ID @"MjI5"

@implementation PikchurAPI

- (NSString *) auth: (NSString *) username
           password: (NSString *) password
            service: (NSString *) service
{
    // Set up the request object
	NSMutableURLRequest *request = [[[NSMutableURLRequest alloc] init] autorelease];
	[request setURL: [NSURL URLWithString: @"https://api.pikchur.com/auth/json"]];
	[request setHTTPMethod: @"POST"];
	NSString *boundary =    [NSString stringWithString: @"---------------------------14737809831466499882746641449"];
	NSString *contentType = [NSString stringWithFormat: @"multipart/form-data; boundary=%@", boundary];
	[request addValue: contentType forHTTPHeaderField: @"Content-Type"];
    
    //NSString *args = [NSString stringWithFormat: @"data[api][username]=%@&data[api][password]=%@&data[api][service]=%@&data[api][key]=%@", username, password, service, DEV_KEY];
    //NSData *body = [NSData dataWithBytes: [args UTF8String] length: [args length]];
	NSMutableData *body = [NSMutableData data];
	
    //data[api][username]
    [body appendData: [[NSString stringWithFormat: @"\r\n--%@\r\n", boundary] dataUsingEncoding: NSUTF8StringEncoding]];	
	[body appendData: [[NSString stringWithString: @"Content-Disposition: form-data; name=\"data[api][username]\"; \r\n"] dataUsingEncoding: NSUTF8StringEncoding]];
	[body appendData: [[NSString stringWithString: @"Content-Type: application/octet-stream\r\n\r\n"] dataUsingEncoding: NSUTF8StringEncoding]];
	[body appendData: [[NSString stringWithFormat: @"%@", username] dataUsingEncoding: NSUTF8StringEncoding]];
	[body appendData: [[NSString stringWithFormat: @"\r\n--%@--\r\n", boundary] dataUsingEncoding: NSUTF8StringEncoding]];
	
	//data[api][password]
	[body appendData: [[NSString stringWithFormat: @"\r\n--%@\r\n", boundary] dataUsingEncoding: NSUTF8StringEncoding]];	
	[body appendData: [[NSString stringWithString: @"Content-Disposition: form-data; name=\"data[api][password]\"; \r\n"] dataUsingEncoding: NSUTF8StringEncoding]];
	[body appendData: [[NSString stringWithString: @"Content-Type: application/octet-stream\r\n\r\n"] dataUsingEncoding: NSUTF8StringEncoding]];
	[body appendData: [[NSString stringWithFormat: @"%@", password] dataUsingEncoding: NSUTF8StringEncoding]];
	[body appendData: [[NSString stringWithFormat: @"\r\n--%@--\r\n", boundary] dataUsingEncoding: NSUTF8StringEncoding]];
    
    //data[api][service]
	[body appendData: [[NSString stringWithFormat: @"\r\n--%@\r\n", boundary] dataUsingEncoding: NSUTF8StringEncoding]];	
	[body appendData: [[NSString stringWithString: @"Content-Disposition: form-data; name=\"data[api][service]\"; \r\n"] dataUsingEncoding: NSUTF8StringEncoding]];
	[body appendData: [[NSString stringWithString: @"Content-Type: application/octet-stream\r\n\r\n"] dataUsingEncoding: NSUTF8StringEncoding]];
	[body appendData: [[NSString stringWithFormat: @"%@", [service lowercaseString]] dataUsingEncoding: NSUTF8StringEncoding]];
	[body appendData: [[NSString stringWithFormat: @"\r\n--%@--\r\n", boundary] dataUsingEncoding: NSUTF8StringEncoding]];
    
    //data[api][key]
    [body appendData: [[NSString stringWithFormat: @"\r\n--%@\r\n", boundary] dataUsingEncoding: NSUTF8StringEncoding]];	
    [body appendData: [[NSString stringWithString: @"Content-Disposition: form-data; name=\"data[api][key]\"; \r\n"] dataUsingEncoding: NSUTF8StringEncoding]];
    [body appendData: [[NSString stringWithString: @"Content-Type: application/octet-stream\r\n\r\n"] dataUsingEncoding: NSUTF8StringEncoding]];
    [body appendData: [[NSString stringWithString: DEV_KEY] dataUsingEncoding: NSUTF8StringEncoding]];
    [body appendData: [[NSString stringWithFormat: @"\r\n--%@--\r\n", boundary] dataUsingEncoding: NSUTF8StringEncoding]];
	
	// setting the body of the post to the reqeust
	[request setHTTPBody: body];
	
	// now lets make the connection to the web
	NSData *returnData = [NSURLConnection sendSynchronousRequest: request returningResponse: nil error: nil];
	NSString *JSONString = [[NSString alloc] initWithData: returnData encoding: NSUTF8StringEncoding];
    
    NSDictionary *retval = [[SBJSON alloc] objectWithString: JSONString error: nil];
    
    if([retval objectForKey: @"auth_key"])
        return [retval objectForKey: @"auth_key"];
    else
        return nil;
}

- (NSDictionary *) post: (UIImage *) image
{
    NSString *authKey = [self auth: [[NSUserDefaults standardUserDefaults] objectForKey: @"pikchur_username"]
                          password: [[NSUserDefaults standardUserDefaults] objectForKey: @"pikchur_password"]
                           service: [[NSUserDefaults standardUserDefaults] objectForKey: @"pikchur_service"]];
    if(!authKey)
        return [NSDictionary dictionaryWithObjectsAndKeys: @"Could not obtain auth key", @"error", nil];

    //turning the image into a NSData object, getting the image back out of the UIImageView, setting the quality to 100
	NSData *imageData = UIImageJPEGRepresentation(image, 100);
	
    // Set up the request object
	NSMutableURLRequest *request = [[[NSMutableURLRequest alloc] init] autorelease];
	[request setURL: [NSURL URLWithString: @"http://api.pikchur.com/post/json"]];
	[request setHTTPMethod: @"POST"];
	
	NSString *boundary =    [NSString stringWithString: @"---------------------------14737809831466499882746641449"];
	NSString *contentType = [NSString stringWithFormat: @"multipart/form-data; boundary=%@", boundary];
	[request addValue: contentType forHTTPHeaderField: @"Content-Type"];
    
    UIDevice *device = [UIDevice alloc];
    NSString *statusMessage;
    if([device.model rangeOfString: @"iPhone"].location != NSNotFound)
        statusMessage = [NSString stringWithFormat: @"sent from my iPhone"];
    else
        statusMessage = [NSString stringWithFormat: @"sent from my iPod"];
	
	NSMutableData *body = [NSMutableData data];
    
    //data[api][auth_key]
	[body appendData: [[NSString stringWithFormat: @"\r\n--%@\r\n", boundary] dataUsingEncoding: NSUTF8StringEncoding]];	
	[body appendData: [[NSString stringWithString: @"Content-Disposition: form-data; name=\"data[api][auth_key]\"; \r\n"] dataUsingEncoding: NSUTF8StringEncoding]];
	[body appendData: [[NSString stringWithString: @"Content-Type: application/octet-stream\r\n\r\n"] dataUsingEncoding: NSUTF8StringEncoding]];
	[body appendData: [[NSString stringWithFormat: @"%@", authKey] dataUsingEncoding: NSUTF8StringEncoding]];
	[body appendData: [[NSString stringWithFormat: @"\r\n--%@--\r\n", boundary] dataUsingEncoding: NSUTF8StringEncoding]];
	
    //dataAPIimage 
	[body appendData: [[NSString stringWithFormat: @"\r\n--%@\r\n", boundary] dataUsingEncoding: NSUTF8StringEncoding]];
	[body appendData: [[NSString stringWithString: @"Content-Disposition: form-data; name=\"dataAPIimage\"; filename=\"image.jpg\"\r\n"] dataUsingEncoding: NSUTF8StringEncoding]];
	[body appendData: [[NSString stringWithString: @"Content-Type: image/jpeg\r\n\r\n"] dataUsingEncoding: NSUTF8StringEncoding]];
	[body appendData: [NSData dataWithData: imageData]];
	[body appendData: [[NSString stringWithFormat: @"\r\n--%@--\r\n", boundary] dataUsingEncoding: NSUTF8StringEncoding]];
    
    //data[api][status]
    [body appendData: [[NSString stringWithFormat: @"\r\n--%@\r\n", boundary] dataUsingEncoding: NSUTF8StringEncoding]];	
    [body appendData: [[NSString stringWithString: @"Content-Disposition: form-data; name=\"data[api][status]\"; \r\n"] dataUsingEncoding: NSUTF8StringEncoding]];
    [body appendData: [[NSString stringWithString: @"Content-Type: application/octet-stream\r\n\r\n"] dataUsingEncoding: NSUTF8StringEncoding]];
    [body appendData: [[NSString stringWithString: statusMessage] dataUsingEncoding: NSUTF8StringEncoding]];
    [body appendData: [[NSString stringWithFormat: @"\r\n--%@--\r\n", boundary] dataUsingEncoding: NSUTF8StringEncoding]];
    
    //data[api][key]
    [body appendData: [[NSString stringWithFormat: @"\r\n--%@\r\n", boundary] dataUsingEncoding: NSUTF8StringEncoding]];	
    [body appendData: [[NSString stringWithString: @"Content-Disposition: form-data; name=\"data[api][key]\"; \r\n"] dataUsingEncoding: NSUTF8StringEncoding]];
    [body appendData: [[NSString stringWithString: @"Content-Type: application/octet-stream\r\n\r\n"] dataUsingEncoding: NSUTF8StringEncoding]];
    [body appendData: [[NSString stringWithString: DEV_KEY] dataUsingEncoding: NSUTF8StringEncoding]];
    [body appendData: [[NSString stringWithFormat: @"\r\n--%@--\r\n", boundary] dataUsingEncoding: NSUTF8StringEncoding]];
    
    // TESTING, REMOVE
    /*
    [body appendData: [[NSString stringWithFormat: @"\r\n--%@\r\n", boundary] dataUsingEncoding: NSUTF8StringEncoding]];	
    [body appendData: [[NSString stringWithString: @"Content-Disposition: form-data; name=\"data[api][update][twitter]\"; \r\n"] dataUsingEncoding: NSUTF8StringEncoding]];
    [body appendData: [[NSString stringWithString: @"Content-Type: application/octet-stream\r\n\r\n"] dataUsingEncoding: NSUTF8StringEncoding]];
    [body appendData: [[NSString stringWithString: @"OFF"] dataUsingEncoding: NSUTF8StringEncoding]];
    [body appendData: [[NSString stringWithFormat: @"\r\n--%@--\r\n", boundary] dataUsingEncoding: NSUTF8StringEncoding]];
    
    [body appendData: [[NSString stringWithFormat: @"\r\n--%@\r\n", boundary] dataUsingEncoding: NSUTF8StringEncoding]];	
    [body appendData: [[NSString stringWithString: @"Content-Disposition: form-data; name=\"data[api][update][facebook]\"; \r\n"] dataUsingEncoding: NSUTF8StringEncoding]];
    [body appendData: [[NSString stringWithString: @"Content-Type: application/octet-stream\r\n\r\n"] dataUsingEncoding: NSUTF8StringEncoding]];
    [body appendData: [[NSString stringWithString: @"OFF"] dataUsingEncoding: NSUTF8StringEncoding]];
    [body appendData: [[NSString stringWithFormat: @"\r\n--%@--\r\n", boundary] dataUsingEncoding: NSUTF8StringEncoding]];
    
    [body appendData: [[NSString stringWithFormat: @"\r\n--%@\r\n", boundary] dataUsingEncoding: NSUTF8StringEncoding]];	
    [body appendData: [[NSString stringWithString: @"Content-Disposition: form-data; name=\"data[api][update][identica]\"; \r\n"] dataUsingEncoding: NSUTF8StringEncoding]];
    [body appendData: [[NSString stringWithString: @"Content-Type: application/octet-stream\r\n\r\n"] dataUsingEncoding: NSUTF8StringEncoding]];
    [body appendData: [[NSString stringWithString: @"OFF"] dataUsingEncoding: NSUTF8StringEncoding]];
    [body appendData: [[NSString stringWithFormat: @"\r\n--%@--\r\n", boundary] dataUsingEncoding: NSUTF8StringEncoding]];
     */
    // END TESTING
    
    //data[api][upload_only]
    [body appendData: [[NSString stringWithFormat: @"\r\n--%@\r\n", boundary] dataUsingEncoding: NSUTF8StringEncoding]];	
    [body appendData: [[NSString stringWithString: @"Content-Disposition: form-data; name=\"data[api][upload_only]\"; \r\n"] dataUsingEncoding: NSUTF8StringEncoding]];
    [body appendData: [[NSString stringWithString: @"Content-Type: application/octet-stream\r\n\r\n"] dataUsingEncoding: NSUTF8StringEncoding]];
    [body appendData: [[NSString stringWithString: @"TRUE"] dataUsingEncoding: NSUTF8StringEncoding]];
    [body appendData: [[NSString stringWithFormat: @"\r\n--%@--\r\n", boundary] dataUsingEncoding: NSUTF8StringEncoding]];
    
    //data[api][origin]
    [body appendData: [[NSString stringWithFormat: @"\r\n--%@\r\n", boundary] dataUsingEncoding: NSUTF8StringEncoding]];	
    [body appendData: [[NSString stringWithString: @"Content-Disposition: form-data; name=\"data[api][upload_only]\"; \r\n"] dataUsingEncoding: NSUTF8StringEncoding]];
    [body appendData: [[NSString stringWithString: @"Content-Type: application/octet-stream\r\n\r\n"] dataUsingEncoding: NSUTF8StringEncoding]];
    [body appendData: [[NSString stringWithString: APP_ORIGIN_ID] dataUsingEncoding: NSUTF8StringEncoding]];
    [body appendData: [[NSString stringWithFormat: @"\r\n--%@--\r\n", boundary] dataUsingEncoding: NSUTF8StringEncoding]];
	
	// setting the body of the post to the reqeust
	[request setHTTPBody: body];
	
	NSData *returnData = [NSURLConnection sendSynchronousRequest: request returningResponse: nil error: nil];
	NSString *JSONString = [[NSString alloc] initWithData: returnData encoding: NSUTF8StringEncoding];
    
    NSDictionary *retval = [[SBJSON alloc] objectWithString: JSONString error: nil];
    
    return retval;
}

- (NSDictionary *) postURL: (NSString *) URLString
{
    NSString *authKey = [self auth: [[NSUserDefaults standardUserDefaults] objectForKey: @"pikchur_username"]
                          password: [[NSUserDefaults standardUserDefaults] objectForKey: @"pikchur_password"]
                           service: [[NSUserDefaults standardUserDefaults] objectForKey: @"pikchur_service"]];
    if(!authKey)
        return [NSDictionary dictionaryWithObjectsAndKeys: @"Could not obtain auth key", @"error", nil];
    
    // Set up the request object
	NSMutableURLRequest *request = [[[NSMutableURLRequest alloc] init] autorelease];
	[request setURL: [NSURL URLWithString: @"http://api.pikchur.com/post/json"]];
	[request setHTTPMethod: @"POST"];
	
	NSString *boundary =    [NSString stringWithString: @"---------------------------14737809831466499882746641449"];
	NSString *contentType = [NSString stringWithFormat: @"multipart/form-data; boundary=%@", boundary];
	[request addValue: contentType forHTTPHeaderField: @"Content-Type"];
	
	NSMutableData *body = [NSMutableData data];
	
	//data[api][auth_key]
	[body appendData: [[NSString stringWithFormat: @"\r\n--%@\r\n", boundary] dataUsingEncoding: NSUTF8StringEncoding]];	
	[body appendData: [[NSString stringWithString: @"Content-Disposition: form-data; name=\"data[api][auth_key]\"; \r\n"] dataUsingEncoding: NSUTF8StringEncoding]];
	[body appendData: [[NSString stringWithString: @"Content-Type: application/octet-stream\r\n\r\n"] dataUsingEncoding: NSUTF8StringEncoding]];
	[body appendData: [[NSString stringWithString: authKey] dataUsingEncoding: NSUTF8StringEncoding]];
	[body appendData: [[NSString stringWithFormat: @"\r\n--%@--\r\n", boundary] dataUsingEncoding: NSUTF8StringEncoding]];
    
    // data[api][file_url]
    [body appendData: [[NSString stringWithFormat: @"\r\n--%@\r\n", boundary] dataUsingEncoding: NSUTF8StringEncoding]];
    [body appendData: [[NSString stringWithString: @"Content-Disposition: form-data; name=\"data[api][file_url]\"; \r\n"] dataUsingEncoding: NSUTF8StringEncoding]];
	[body appendData: [[NSString stringWithString: @"Content-Type: application/octet-stream\r\n\r\n"] dataUsingEncoding: NSUTF8StringEncoding]];
	[body appendData: [[NSString stringWithString: URLString] dataUsingEncoding: NSUTF8StringEncoding]];
	[body appendData: [[NSString stringWithFormat: @"\r\n--%@--\r\n", boundary] dataUsingEncoding: NSUTF8StringEncoding]];
    
    //data[api][status]
    [body appendData: [[NSString stringWithFormat: @"\r\n--%@\r\n", boundary] dataUsingEncoding: NSUTF8StringEncoding]];	
    [body appendData: [[NSString stringWithString: @"Content-Disposition: form-data; name=\"data[api][status]\"; \r\n"] dataUsingEncoding: NSUTF8StringEncoding]];
    [body appendData: [[NSString stringWithString: @"Content-Type: application/octet-stream\r\n\r\n"] dataUsingEncoding: NSUTF8StringEncoding]];
    [body appendData: [[NSString stringWithString: @""] dataUsingEncoding: NSUTF8StringEncoding]];
    [body appendData: [[NSString stringWithFormat: @"\r\n--%@--\r\n", boundary] dataUsingEncoding: NSUTF8StringEncoding]];
    
    //data[api][key]
    [body appendData: [[NSString stringWithFormat: @"\r\n--%@\r\n", boundary] dataUsingEncoding: NSUTF8StringEncoding]];	
    [body appendData: [[NSString stringWithString: @"Content-Disposition: form-data; name=\"data[api][key]\"; \r\n"] dataUsingEncoding: NSUTF8StringEncoding]];
    [body appendData: [[NSString stringWithString: @"Content-Type: application/octet-stream\r\n\r\n"] dataUsingEncoding: NSUTF8StringEncoding]];
    [body appendData: [[NSString stringWithString: DEV_KEY] dataUsingEncoding: NSUTF8StringEncoding]];
    [body appendData: [[NSString stringWithFormat: @"\r\n--%@--\r\n", boundary] dataUsingEncoding: NSUTF8StringEncoding]];
    
    //data[api][upload_only]
    [body appendData: [[NSString stringWithFormat: @"\r\n--%@\r\n", boundary] dataUsingEncoding: NSUTF8StringEncoding]];	
    [body appendData: [[NSString stringWithString: @"Content-Disposition: form-data; name=\"data[api][upload_only]\"; \r\n"] dataUsingEncoding: NSUTF8StringEncoding]];
    [body appendData: [[NSString stringWithString: @"Content-Type: application/octet-stream\r\n\r\n"] dataUsingEncoding: NSUTF8StringEncoding]];
    [body appendData: [[NSString stringWithString: @"TRUE"] dataUsingEncoding: NSUTF8StringEncoding]];
    [body appendData: [[NSString stringWithFormat: @"\r\n--%@--\r\n", boundary] dataUsingEncoding: NSUTF8StringEncoding]];
    
    //data[api][origin]
    [body appendData: [[NSString stringWithFormat: @"\r\n--%@\r\n", boundary] dataUsingEncoding: NSUTF8StringEncoding]];	
    [body appendData: [[NSString stringWithString: @"Content-Disposition: form-data; name=\"data[api][upload_only]\"; \r\n"] dataUsingEncoding: NSUTF8StringEncoding]];
    [body appendData: [[NSString stringWithString: @"Content-Type: application/octet-stream\r\n\r\n"] dataUsingEncoding: NSUTF8StringEncoding]];
    [body appendData: [[NSString stringWithString: APP_ORIGIN_ID] dataUsingEncoding: NSUTF8StringEncoding]];
    [body appendData: [[NSString stringWithFormat: @"\r\n--%@--\r\n", boundary] dataUsingEncoding: NSUTF8StringEncoding]];
	
	// setting the body of the post to the reqeust
	[request setHTTPBody: body];
	
	NSData *returnData = [NSURLConnection sendSynchronousRequest: request returningResponse: nil error: nil];
	NSString *JSONString = [[NSString alloc] initWithData: returnData encoding: NSUTF8StringEncoding];
    
    NSDictionary *retval = [[SBJSON alloc] objectWithString: JSONString error: nil];
    NSLog(@"%@", retval);
    
    return retval;
}

- (UIImage *) getImage: (NSString *) URL
{
    // Figure out the URL to the image
    NSString *tail = [URL stringByReplacingOccurrencesOfString: @"https://s3.amazonaws.com/pikchurimages/" withString: @""];
    NSString *URLString = [NSString stringWithFormat: @"https://s3.amazonaws.com/pikchurimages/pic_%@_m.jpg", tail];
    NSURL *pictureURL = [NSURL URLWithString: URLString];
    
    // grab the image
    NSData *data = [[NSData alloc] initWithContentsOfURL: pictureURL];
    UIImage *image = [[UIImage alloc] initWithData: data];
    
    return image;
    
    /*
    NSURL *pictureURL = [NSURL URLWithString: URL];
    
    // Write to tmp if it's not already there
    NSString *filename = [URL stringByReplacingOccurrencesOfString: @"https://s3.amazonaws.com/pikchurimages/" withString: @""];
    NSString *uniquePath = [TMP stringByAppendingPathComponent: filename];
    UIImage *image;
    if(![[NSFileManager defaultManager] fileExistsAtPath: uniquePath])
    {
        // Fetch image
        NSData *data = [[NSData alloc] initWithContentsOfURL: pictureURL];
        image = [[UIImage alloc] initWithData: data];
        
        // Is it JPEG or PNG?
        if([URL rangeOfString: @".png" options: NSCaseInsensitiveSearch].location != NSNotFound)
        {
            [UIImagePNGRepresentation(image) writeToFile: uniquePath atomically: YES];
        }
        else if(
                [URL rangeOfString: @".jpg" options: NSCaseInsensitiveSearch].location != NSNotFound || 
                [URL rangeOfString: @".jpeg" options: NSCaseInsensitiveSearch].location != NSNotFound
                )
        {
            [UIImageJPEGRepresentation(image, 100) writeToFile: uniquePath atomically: YES];
        }
    }
    else
    {
        image = [UIImage imageWithContentsOfFile: uniquePath];
    }
    
    return image;
     */
}

@end
