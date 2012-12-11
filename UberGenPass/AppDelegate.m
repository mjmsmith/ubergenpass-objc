//
//  AppDelegate.m
//  UberGenPass
//
//  Created by Mark Smith on 11/27/12.
//  Copyright (c) 2012 Camazotz Limited. All rights reserved.
//

#import "AppDelegate.h"
#import "MainViewController.h"

@implementation AppDelegate

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
  return YES;
}

- (BOOL)application:(UIApplication *)application openURL:(NSURL *)url sourceApplication:(NSString *)sourceApplication annotation:(id)annotation {
  NSString* scheme = NSBundle.mainBundle.infoDictionary[@"CFBundleURLTypes"][0][@"CFBundleURLSchemes"][0];
  
  ((MainViewController *)self.window.rootViewController).url = [url.absoluteString substringFromIndex:(scheme.length+1)];

  return YES;
}

- (NSUInteger)application:(UIApplication *)application supportedInterfaceOrientationsForWindow:(UIWindow *)window {
  return UIInterfaceOrientationMaskAllButUpsideDown;
}

@end
