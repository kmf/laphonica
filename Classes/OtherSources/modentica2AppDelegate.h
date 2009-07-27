//
//  modentica2AppDelegate.h
//  modentica2
//
//  Created by Mark Bockenstedt on 2/6/09.
//  Copyright __MyCompanyName__ 2009. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "LoadingView.h"

@interface modentica2AppDelegate : NSObject <UIApplicationDelegate, UITabBarControllerDelegate>
{
    UIWindow *window;
    UITabBarController *tabBarController;
    
    LoadingView *loadingView;
}

// Properties
@property (nonatomic, retain) IBOutlet UIWindow *window;
@property (nonatomic, retain) IBOutlet UITabBarController *tabBarController;
@property (nonatomic, retain) LoadingView *loadingView;

// Methods
- (void) loadSettingsView;
- (void) applicationWillTerminate: (NSNotification *) notification;

@end
