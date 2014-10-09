//
//  SettingsViewController.m
//  UberGenPass
//
//  Copyright (c) 2012 Camazotz Limited. All rights reserved.
//

#import "HelpViewController.h"
#import "PasswordGenerator.h"
#import "PasswordsViewController.h"
#import "SettingsViewController.h"
#import "StatusImageView.h"

@interface SettingsViewController () <HelpViewControllerDelegate, PasswordsViewControllerDelegate>
@property (strong, readwrite, nonatomic) IBOutlet UIBarButtonItem *cancelButtonItem;
@property (strong, readwrite, nonatomic) IBOutlet UIBarButtonItem *doneButtonItem;
@property (strong, readwrite, nonatomic) IBOutlet UITextField *passwordTextField;
@property (strong, readwrite, nonatomic) IBOutlet StatusImageView *statusImageView;
@property (strong, readwrite, nonatomic) IBOutlet UIButton *changePasswordButton;
@property (strong, readwrite, nonatomic) IBOutlet UISwitch *recentSitesSwitch;
@property (strong, readwrite, nonatomic) IBOutlet UISegmentedControl *timeoutSegment;

@property (strong, readwrite, nonatomic) UIImage *greyImage;
@property (strong, readwrite, nonatomic) UIImage *greenImage;
@end

@implementation SettingsViewController

#pragma mark Public

- (void)resetForActivate {
  if (self.canCancel) {
    self.canCancel = NO;
    self.cancelButtonItem.enabled = NO;
  }
  
  self.passwordTextField.text = nil;

  [self.passwordTextField becomeFirstResponder];
  [self editingChanged:nil];
}

#pragma mark UIViewController

- (void)viewDidLoad {
  [super viewDidLoad];
  
  self.greyImage = [UIImage imageNamed:@"GreyStatus"];
  self.greenImage = [UIImage imageNamed:@"GreenStatus"];

  if (!self.canCancel) {
    self.cancelButtonItem.enabled = NO;
  }
  
  self.recentSitesSwitch.on = self.remembersRecentSites;
  
  if (self.backgroundTimeout == 300) {
    self.timeoutSegment.selectedSegmentIndex = 2;
  }
  else if (self.backgroundTimeout == 60) {
    self.timeoutSegment.selectedSegmentIndex = 1;
  }
  
  [self editingChanged:nil];
}

- (void)viewDidAppear:(BOOL)animated {
  [super viewDidAppear:animated];
  
  // If we have no master password hash, force a segue to Passwords (only happens on startup).
  // Otherwise, set focus if the Done button isn't enabled.
  
  if (PasswordGenerator.sharedGenerator.passwordHash == nil) {
    [self performSegueWithIdentifier:ShowPasswordsRequiredSegue sender:self];
  }
  else {
    if (self.doneButtonItem.enabled) {
      [self.view endEditing:NO];
    }
    else {
      [self.passwordTextField becomeFirstResponder];
    }
  }
}

- (NSUInteger)supportedInterfaceOrientations {
  return UIInterfaceOrientationMaskPortrait;
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
  if ([segue.identifier isEqualToString:ShowHelpSegue]) {
    HelpViewController *controller = segue.destinationViewController;
    
    controller.documentName = @"SettingsHelp";
    controller.delegate = self;
  }
  else if ([segue.identifier isEqualToString:ShowPasswordsOptionalSegue] ||
           [segue.identifier isEqualToString:ShowPasswordsRequiredSegue]) {
    PasswordsViewController *controller = segue.destinationViewController;
    
    controller.canCancel = [segue.identifier isEqualToString:ShowPasswordsOptionalSegue];
    controller.delegate = self;
  }
}

#pragma mark Actions

- (IBAction)editingChanged:(id)sender {
  if ([PasswordGenerator.sharedGenerator textMatchesHash:self.passwordTextField.text]) {
    self.statusImageView.image = self.greenImage;
    self.doneButtonItem.enabled = YES;
    
    [self.passwordTextField resignFirstResponder];
    
    if (sender == self.passwordTextField) {
      [self.statusImageView animate];
    }
  }
  else {
    self.statusImageView.image = self.greyImage;
    self.doneButtonItem.enabled = NO;
  }
}

- (IBAction)tapGestureRecognized:(UITapGestureRecognizer *)recognizer {
  [self.view endEditing:YES];
}

- (IBAction)addSafariBookmarklet {
  [UIPasteboard.generalPasteboard setString:@"javascript:location.href='ubergenpass:'+location.href"];
  [UIApplication.sharedApplication openURL:[NSURL URLWithString:@"http://camazotz.com/ubergenpass/bookmarklet"]];
}

- (IBAction)done {
  NSInteger timeouts[] = {0, 60, 300};

  self.masterPassword = self.passwordTextField.text;
  self.remembersRecentSites = self.recentSitesSwitch.on;
  self.backgroundTimeout = timeouts[self.timeoutSegment.selectedSegmentIndex];
  
  [self.delegate settingsViewControllerDidFinish:self];
}

- (IBAction)cancel {
  [self.delegate settingsViewControllerDidCancel:self];
}

#pragma mark UITextFieldDelegate

- (BOOL)textFieldShouldReturn:(UITextField *)textField {
  return NO;
}

#pragma mark HelpViewControllerDelegate

- (void)helpViewControllerDidFinish:(HelpViewController *)controller {
  [self dismissViewControllerAnimated:YES completion:nil];
}

#pragma mark PasswordsViewControllerDelegate

- (void)passwordsViewControllerDidFinish:(PasswordsViewController *)controller {
  [PasswordGenerator.sharedGenerator updateMasterPassword:controller.masterPassword
                                           secretPassword:controller.secretPassword];

  self.passwordTextField.text = controller.masterPassword;
  [self editingChanged:nil];
  
  [self dismissViewControllerAnimated:YES completion:nil];
}

- (void)passwordsViewControllerDidCancel:(PasswordsViewController *)controller {
  [self dismissViewControllerAnimated:YES completion:nil];
}

@end
