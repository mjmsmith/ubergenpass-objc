//
//  SettingsViewController.h
//  SuperGenPass
//
//  Created by Mark Smith on 11/27/12.
//  Copyright (c) 2012 Camazotz Limited. All rights reserved.
//

#import <UIKit/UIKit.h>

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
@property (copy, readonly, nonatomic) NSString *password;
@end
