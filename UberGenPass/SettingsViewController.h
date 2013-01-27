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
@property (assign, readwrite, nonatomic) BOOL storesHash;
@property (assign, readwrite, nonatomic) BOOL canCancel;
@property (copy, readwrite, nonatomic) NSData *hash;
@property (assign, readwrite, nonatomic) int backgroundTimeout;
@property (copy, readonly, nonatomic) NSString *password;

- (void)resetForActivate;
@end
