//
//  PasswordsViewController.h
//  UberGenPass
//
//  Created by Mark Smith on 6/6/14.
//  Copyright (c) 2014 Camazotz Limited. All rights reserved.
//

@class PasswordsViewController;

@protocol PasswordsViewControllerDelegate
- (void)passwordsViewControllerDidFinish:(PasswordsViewController *)controller;
- (void)passwordsViewControllerDidCancel:(PasswordsViewController *)controller;
@end

@interface PasswordsViewController : UIViewController
@property (weak, readwrite, nonatomic) id <PasswordsViewControllerDelegate> delegate;
@property (assign, readwrite, nonatomic) BOOL canCancel;
@property (strong, readwrite, nonatomic) NSString *masterPassword;
@property (strong, readwrite, nonatomic) NSString *secretPassword;
@end
