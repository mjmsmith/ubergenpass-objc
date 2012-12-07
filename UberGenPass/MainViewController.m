//
//  MainViewController.m
//  UberGenPass
//
//  Created by Mark Smith on 11/27/12.
//  Copyright (c) 2012 Camazotz Limited. All rights reserved.
//

#import "GradientButton.h"
#import "MainViewController.h"
#import "PasswordGenerator.h"

@interface MainViewController ()
@property (strong, readwrite, nonatomic) IBOutlet UITextField *urlTextField;
@property (strong, readwrite, nonatomic) IBOutlet UIStepper *passwordLengthStepper;
@property (strong, readwrite, nonatomic) IBOutlet UITextField *passwordLengthTextField;
@property (strong, readwrite, nonatomic) IBOutlet UILabel *passwordForLabel;
@property (strong, readwrite, nonatomic) IBOutlet UILabel *passwordHostLabel;
@property (strong, readwrite, nonatomic) IBOutlet UITextField *passwordTextField;
@property (strong, readwrite, nonatomic) IBOutlet GradientButton *showHideButton;
@property (strong, readwrite, nonatomic) IBOutlet GradientButton *clipboardButton;
@property (strong, readwrite, nonatomic) IBOutlet GradientButton *safariButton;
- (IBAction)editingChanged;
- (IBAction)lengthChanged;
- (IBAction)toggleShow;
- (IBAction)copyToClipboard;
- (IBAction)launchSafari;
@end

@implementation MainViewController

#pragma mark UIViewController

- (void)viewDidLoad {
  [super viewDidLoad];
  
  int passwordLength = [NSUserDefaults.standardUserDefaults integerForKey:@"PasswordLength"];
  
  self.urlTextField.text = self.url;
  
  self.passwordLengthStepper.minimumValue = 8;
  self.passwordLengthStepper.maximumValue = 20;
  self.passwordLengthStepper.value = (passwordLength == 0) ? 10 : passwordLength;

  self.passwordLengthTextField.text = [NSString stringWithFormat:@"%d", (int)self.passwordLengthStepper.value];

  [self.showHideButton useAlertStyle];
  [self.clipboardButton useAlertStyle];
  [self.safariButton useAlertStyle];

  self.passwordForLabel.hidden = YES;
  self.passwordHostLabel.hidden = YES;
  self.passwordTextField.hidden = YES;
  self.showHideButton.hidden = YES;
  self.clipboardButton.hidden = YES;
  self.safariButton.hidden = YES;
  
  if (PasswordGenerator.sharedGenerator.hasPassword) {
    [self editingChanged];
  }
}

- (void)viewDidAppear:(BOOL)animated {
  [super viewDidAppear:animated];
  
  if (!PasswordGenerator.sharedGenerator.hasPassword) {
    [self performSegueWithIdentifier:@"showAlternate" sender:self];
  }
  else {
    if (self.urlTextField.text.length == 0) {
      [self.urlTextField becomeFirstResponder];
    }
  }
}

- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event {
  UITouch *touch = [touches anyObject];
  
  if (touch.phase == UITouchPhaseBegan) {
    [self.view endEditing:YES];
  }
}

- (void)setUrl:(NSString *)url {
  if (self.urlTextField == nil) {
    self->_url = url;
  }
  else {
    self.urlTextField.text = url;
    [self editingChanged];
  }
}

#pragma mark Actions

- (IBAction)editingChanged {
  NSString *domain = [PasswordGenerator.sharedGenerator domainFromURL:self.urlTextField.text];
  NSString *password = [PasswordGenerator.sharedGenerator passwordForURL:self.urlTextField.text
                                                                  length:self.passwordLengthStepper.value];
  BOOL hidden = (domain == nil);

  if (!hidden) {
    self.passwordHostLabel.text = domain;
    self.passwordTextField.text = password;
  }
  
  self.passwordForLabel.hidden = hidden;
  self.passwordHostLabel.hidden = hidden;
  self.passwordTextField.hidden = hidden;
  self.showHideButton.hidden = hidden;
  self.clipboardButton.hidden = hidden;
  self.safariButton.hidden = hidden;

  self->_url = self.urlTextField.text;
}

- (IBAction)lengthChanged {
  [NSUserDefaults.standardUserDefaults setInteger:self.passwordLengthStepper.value forKey:@"PasswordLength"];
  self.passwordLengthTextField.text = [NSString stringWithFormat:@"%d", (int)self.passwordLengthStepper.value];
  [self editingChanged];
}

- (IBAction)toggleShow {
  self.passwordTextField.secureTextEntry = !self.passwordTextField.secureTextEntry;
  [self.showHideButton setTitle:(self.passwordTextField.secureTextEntry ? @"Show Password" : @"Hide Password") forState:UIControlStateNormal];
}

- (IBAction)copyToClipboard {
  UIPasteboard.generalPasteboard.string = self.passwordTextField.text;
}

- (IBAction)launchSafari {
  NSString *url = self.url;
  
  if ([url rangeOfString:@":"].location == NSNotFound) {
    url = [@"http://" stringByAppendingString:url];
  }
  
  [UIApplication.sharedApplication openURL:[NSURL URLWithString:url]];
}

#pragma mark UITextFieldDelegate

- (BOOL)textFieldShouldReturn:(UITextField *)textField {
  [textField resignFirstResponder];
  return YES;
}

#pragma mark SettingsViewControllerDelegate

- (void)settingsViewControllerDidFinish:(SettingsViewController *)controller {
  [PasswordGenerator.sharedGenerator updatePassword:controller.password storesHash:controller.storesHash];
  
  [self editingChanged];
  [self dismissViewControllerAnimated:YES completion:nil];
}

- (void)settingsViewControllerDidCancel:(SettingsViewController *)controller {
  [self dismissViewControllerAnimated:YES completion:nil];
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
  if ([segue.identifier isEqualToString:@"showAlternate"]) {
    SettingsViewController *controller = segue.destinationViewController;

    controller.canCancel = PasswordGenerator.sharedGenerator.hasPassword;
    controller.hash = PasswordGenerator.sharedGenerator.hash;
    controller.storesHash = PasswordGenerator.sharedGenerator.storesHash;
    controller.delegate = self;
  }
}

@end
