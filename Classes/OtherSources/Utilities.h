//
//  utils.h
//  modentica2
//
//  Created by Mark Bockenstedt on 2/23/09.
//  Copyright 2009 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>


@interface Utilities : NSObject {

}

// Methods
- (NSString *) formatDate: (NSString *) date;
- (NSString *) formatTimestamp: (NSString *) timestamp;
- (NSString *) formatTimestamp: (NSString *) timestamp forStatusView: (BOOL) forStatusView;

- (UIImage *) getCachedImage: (NSString *) profileImageURLString defaultToSmall: (BOOL) defaultToSmall;
- (void) cacheImage: (NSString *) profileImageURLString;
- (void) downloadProfileImages: (NSArray *) statuses;
- (void) downloadProfileImages: (NSArray *) statuses forDirectMessages: (BOOL) forDirectMessages;
- (void) downloadProfileImages: (NSArray *) statuses forSearch: (BOOL) forSearch;
- (void) downloadProfileImages: (NSArray *) users forUserList: (BOOL) forUserList;
- (UIImage *) roundCorners: (UIImage*) img;
- (void) purgeCache;


@end
