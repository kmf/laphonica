//
//  PikchurAPI.h
//  modentica2
//
//  Created by Mark Bockenstedt on 2/28/09.
//  Copyright 2009 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>


@interface PikchurAPI : NSObject {

}

- (NSString *) auth: (NSString *) username password: (NSString *) password service: (NSString *) service;
- (NSDictionary *) post: (UIImage *) image;
- (NSDictionary *) postURL: (NSString *) URLString;
- (UIImage *) getImage: (NSString *) URL;

@end
