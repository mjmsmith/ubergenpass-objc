//
//  SettingsViewController.h
//  UberGenPass
//
//  Copyright (c) 2012 Camazotz Limited. All rights reserved.
//

@class SettingsViewController;

@protocol SettingsViewControllerDelegate
- (void)settingsViewControllerDidFinish:(SettingsViewController *)controller;
- (void)settingsViewControllerDidCancel:(SettingsViewController *)controller;
@end

@interface SettingsViewController : UIViewController
@property (weak, readwrite, nonatomic) id <SettingsViewControllerDelegate> delegate;
@property (assign, readwrite, nonatomic) BOOL savesPasswordHash;
@property (assign, readwrite, nonatomic) BOOL remembersRecentSites;
@property (assign, readwrite, nonatomic) BOOL canCancel;
@property (assign, readwrite, nonatomic) int backgroundTimeout;
@property (copy, readonly, nonatomic) NSString *password;

- (void)resetForActivate;
@end
