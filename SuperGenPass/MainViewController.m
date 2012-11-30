//
//  MainViewController.m
//  SuperGenPass
//
//  Created by Mark Smith on 11/27/12.
//  Copyright (c) 2012 Camazotz Limited. All rights reserved.
//

#import "MainViewController.h"
#import "PasswordGenerator.h"

@interface MainViewController ()
@property (strong, readwrite, nonatomic) IBOutlet UITextField *urlTextField;
@property (strong, readwrite, nonatomic) IBOutlet UIStepper *passwordLengthStepper;
@property (strong, readwrite, nonatomic) IBOutlet UILabel *passwordLengthLabel;
@property (strong, readwrite, nonatomic) IBOutlet UITextField *passwordTextField;
@property (strong, readwrite, nonatomic) IBOutlet UIButton *showHideButton;
@property (strong, readwrite, nonatomic) IBOutlet UIButton *clipboardButton;
@property (strong, readwrite, nonatomic) IBOutlet UIButton *safariButton;
@end

@implementation MainViewController

@synthesize url = _url;

#pragma mark UIViewController

- (void)viewDidLoad {
  [super viewDidLoad];
  
  self.urlTextField.text = self.url;

  int passwordLength = [NSUserDefaults.standardUserDefaults integerForKey:@"PasswordLength"];
  
  self.passwordLengthStepper.minimumValue = 8;
  self.passwordLengthStepper.maximumValue = 20;
  self.passwordLengthStepper.value = (passwordLength == 0) ? 10 : passwordLength;
  if (self.passwordLengthStepper.value == 0) {
    self.passwordLengthStepper.value = 10;
  }

  self.passwordLengthLabel.text = [NSString stringWithFormat:@"Password Length: %d", (int)self.passwordLengthStepper.value];

  if (PasswordGenerator.sharedGenerator.hasPassword) {
    [self editingChanged];
  }
}

- (void)viewDidAppear:(BOOL)animated {
  [super viewDidAppear:animated];
  
  if (!PasswordGenerator.sharedGenerator.hasPassword) {
    [self performSegueWithIdentifier:@"showAlternate" sender:self];
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

- (IBAction)toggleShow {
  self.passwordTextField.secureTextEntry = !self.passwordTextField.secureTextEntry;
  [self.showHideButton setTitle:(self.passwordTextField.secureTextEntry ? @"Show" : @"Hide") forState:UIControlStateNormal];
}

- (IBAction)copyToClipboard {
  UIPasteboard.generalPasteboard.string = self.passwordTextField.text;
}

- (IBAction)lengthChanged {
  [NSUserDefaults.standardUserDefaults setInteger:self.passwordLengthStepper.value forKey:@"PasswordLength"];
  self.passwordLengthLabel.text = [NSString stringWithFormat:@"Password Length: %d", (int)self.passwordLengthStepper.value];
  [self editingChanged];
}

- (IBAction)editingChanged {
  self.passwordTextField.text = [PasswordGenerator.sharedGenerator passwordForURL:self.urlTextField.text
                                                                            length:self.passwordLengthStepper.value];
  BOOL hasText = (self.passwordTextField.text.length > 0);

  self.passwordTextField.hidden = !hasText;
  self.showHideButton.hidden = !hasText;
  self.clipboardButton.hidden = !hasText;
  self.safariButton.hidden = !hasText;

  self->_url = self.urlTextField.text;
}

- (IBAction)launchSafari {
  NSString *url = self.url;
  
  if ([url rangeOfString:@":"].location == NSNotFound) {
    url = [@"http://" stringByAppendingString:url];
  }
  
  [UIApplication.sharedApplication openURL:[NSURL URLWithString:url]];
}

#pragma mark UITextFieldDelegate

- (BOOL)textFieldShouldBeginEditing:(UITextField *)textField {
  return textField != self.passwordTextField;
}

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
