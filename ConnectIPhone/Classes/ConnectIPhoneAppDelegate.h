//
//  ConnectIPhoneAppDelegate.h
//  ConnectIPhone
//
//  Created by CONNECT on 5/24/11.
//  Copyright 2011 Team MACK. All rights reserved.
//

#import <UIKit/UIKit.h>


@class UITabBarController;
@interface ConnectIPhoneAppDelegate : NSObject <UIApplicationDelegate, UITabBarDelegate> {
    UIWindow *window;
	IBOutlet UITabBarController *tabBarController;	
}

@property (nonatomic, retain) IBOutlet UIWindow *window;
@property (nonatomic, retain) IBOutlet UITabBarController *tabBarController;

@end

