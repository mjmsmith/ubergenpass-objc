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
  NSDictionary* urlDict = [[NSBundle.mainBundle.infoDictionary objectForKey:@"CFBundleURLTypes"] objectAtIndex:0];
  NSString *scheme = [[urlDict objectForKey:@"CFBundleURLSchemes"] objectAtIndex:0];
  
  ((MainViewController *)self.window.rootViewController).url = [url.absoluteString substringFromIndex:(scheme.length+1)];

  return YES;
}

- (void)applicationWillResignActive:(UIApplication *)application {
}

- (void)applicationDidEnterBackground:(UIApplication *)application {
}

- (void)applicationWillEnterForeground:(UIApplication *)application {
}

- (void)applicationDidBecomeActive:(UIApplication *)application {
}

- (void)applicationWillTerminate:(UIApplication *)application {
}

@end
