//
//  AppDelegate.m
//  UberGenPass
//
//  Copyright (c) 2012 Camazotz Limited. All rights reserved.
//

#import "AppDelegate.h"
#import "Keychain.h"
#import "MainViewController.h"

@implementation AppDelegate

#pragma mark UIApplicationDelegate

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
  NSString *currentVersion = [NSBundle.mainBundle objectForInfoDictionaryKey:@"CFBundleShortVersionString"];
  NSString *defaultsVersion = [NSUserDefaults.standardUserDefaults stringForKey:AppVersionKey];
  
  // Is this the same version as the last session?
  
  if (![currentVersion isEqualToString:defaultsVersion]) {
    [self versionUpdatedFrom:defaultsVersion to:currentVersion];
  }
  
  return YES;
}

- (BOOL)application:(UIApplication *)application openURL:(NSURL *)url sourceApplication:(NSString *)sourceApplication annotation:(id)annotation {
  // Strip off our scheme prefix to get the real URL.
  
  NSString *scheme = NSBundle.mainBundle.infoDictionary[@"CFBundleURLTypes"][0][@"CFBundleURLSchemes"][0];
  NSString *urlStr = [url.absoluteString substringFromIndex:(scheme.length+1)];
  
  // Ignore about: URLs.
  
  if (![urlStr hasPrefix:@"about:"]) {
    ((MainViewController *)self.window.rootViewController).site = urlStr;
  }
  
  return YES;
}

- (NSUInteger)application:(UIApplication *)application supportedInterfaceOrientationsForWindow:(UIWindow *)window {
  return UIInterfaceOrientationMaskAllButUpsideDown;
}

#pragma mark Private

- (void)versionUpdatedFrom:(NSString *)oldVersion to:(NSString *)newVersion {
  if (oldVersion == nil) {
    [Keychain removeStringForKey:PasswordHashKey];
    [Keychain removeStringForKey:RecentSitesKey];
  }
  else {
    if ([newVersion isEqualToString:@"2.0.0"]) {
    }
  }
  
  [NSUserDefaults.standardUserDefaults setObject:newVersion forKey:AppVersionKey];
}

@end
