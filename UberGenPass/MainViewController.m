//
//  MainViewController.m
//  UberGenPass
//
//  Copyright (c) 2012 Camazotz Limited. All rights reserved.
//

#import "GradientButton.h"
#import "Keychain.h"
#import "MainViewController.h"
#import "NSData+Base64.h"
#import "PasswordGenerator.h"

@interface MainViewController ()
@property (strong, readwrite, nonatomic) IBOutlet UITextField *urlTextField;
@property (strong, readwrite, nonatomic) IBOutlet UIStepper *passwordLengthStepper;
@property (strong, readwrite, nonatomic) IBOutlet UITextField *passwordLengthTextField;
@property (strong, readwrite, nonatomic) IBOutlet UILabel *passwordHostLabel;
@property (strong, readwrite, nonatomic) IBOutlet UITextField *passwordTextField;
@property (strong, readwrite, nonatomic) IBOutlet GradientButton *showHideButton;
@property (strong, readwrite, nonatomic) IBOutlet GradientButton *clipboardButton;
@property (strong, readwrite, nonatomic) IBOutlet GradientButton *safariButton;
@property (strong, readwrite, nonatomic) IBOutlet UILabel *versionLabel;
@property (strong, readwrite, nonatomic) NSDate *inactiveDate;
@end

@implementation MainViewController

#pragma mark Lifecycle

- (void)dealloc {
  [NSNotificationCenter.defaultCenter removeObserver:self name:UIApplicationWillResignActiveNotification object:nil];
  [NSNotificationCenter.defaultCenter removeObserver:self name:UIApplicationDidBecomeActiveNotification object:nil];
}

#pragma mark Public

- (void)setUrl:(NSString *)url {
  if (self.urlTextField == nil) {
    self->_url = url;
  }
  else {
    self.urlTextField.text = url;
    self.urlTextField.selectedTextRange = [self.urlTextField textRangeFromPosition:self.urlTextField.beginningOfDocument
                                                                        toPosition:self.urlTextField.beginningOfDocument];
    [self editingChanged];
  }
}

#pragma mark UIViewController

- (void)viewDidLoad {
  [super viewDidLoad];

  // Observe active/inactive notifications.
  
  [NSNotificationCenter.defaultCenter addObserver:self
                                         selector:@selector(applicationWillResignActive:)
                                             name:UIApplicationWillResignActiveNotification object:nil];
  [NSNotificationCenter.defaultCenter addObserver:self
                                         selector:@selector(applicationDidBecomeActive:)
                                             name:UIApplicationDidBecomeActiveNotification object:nil];
  // URL text field.
  
  self.urlTextField.text = self.url;
  self.urlTextField.selectedTextRange = [self.urlTextField textRangeFromPosition:self.urlTextField.beginningOfDocument
                                                                      toPosition:self.urlTextField.beginningOfDocument];

  // Password length stepper and text field.
  
  int passwordLength = [NSUserDefaults.standardUserDefaults integerForKey:@"PasswordLength"];
  
  self.passwordLengthStepper.minimumValue = 4;
  self.passwordLengthStepper.maximumValue = 24;
  self.passwordLengthStepper.value = (passwordLength == 0) ? 10 : passwordLength;

  self.passwordLengthTextField.text = [NSString stringWithFormat:@"%d", (int)self.passwordLengthStepper.value];

  // Password buttons.
  
  [self.showHideButton useAlertStyle];
  [self.clipboardButton useAlertStyle];
  [self.safariButton useAlertStyle];

  // Controls hidden until we have a URL/domain.
  
  self.passwordHostLabel.hidden = YES;
  self.passwordTextField.hidden = YES;
  self.showHideButton.hidden = YES;
  self.clipboardButton.hidden = YES;
  self.safariButton.hidden = YES;

  // Version label.
  
  self.versionLabel.text = [NSBundle.mainBundle objectForInfoDictionaryKey:@"CFBundleShortVersionString"];

  // If we're ready to generate passwords, update the UI as usual.
  
  if (PasswordGenerator.sharedGenerator.hasMasterPassword) {
    [self editingChanged];
  }
}

- (void)viewDidAppear:(BOOL)animated {
  [super viewDidAppear:animated];
  
  // If we have no master password, force a segue to Settings (only happens on startup).
  // Otherwise, set focus if we have no URL/domain text.
  
  if (!PasswordGenerator.sharedGenerator.hasMasterPassword) {
    [self performSegueWithIdentifier:@"ShowSettingsRequired" sender:self];
  }
  else {
    if (self.urlTextField.text.length == 0) {
      [self.urlTextField becomeFirstResponder];
    }
  }
}

- (NSUInteger)supportedInterfaceOrientations {
  return UIInterfaceOrientationMaskPortrait;
}

- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event {
  // Handle background taps.
  
  UITouch *touch = [touches anyObject];
  
  if (touch.phase == UITouchPhaseBegan) {
    [self.view endEditing:YES];
  }
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
  if ([segue.identifier isEqualToString:@"ShowHelp"]) {
    HelpViewController *controller = segue.destinationViewController;
    
    controller.documentName = @"MainHelp";
    controller.delegate = self;
  }
  else if ([segue.identifier isEqualToString:@"ShowSettingsOptional"] || [segue.identifier isEqualToString:@"ShowSettingsRequired"]) {
    SettingsViewController *controller = segue.destinationViewController;
    
    controller.canCancel = [segue.identifier isEqualToString:@"ShowSettingsOptional"];
    controller.hash = PasswordGenerator.sharedGenerator.hash;
    controller.storesHash = ([Keychain stringForKey:@"Hash"] != nil);
    controller.backgroundTimeout = [NSUserDefaults.standardUserDefaults integerForKey:@"BackgroundTimeout"];
    controller.delegate = self;
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
  
  self.passwordHostLabel.hidden = hidden;
  self.passwordTextField.hidden = hidden;
  self.showHideButton.hidden = hidden;
  self.clipboardButton.hidden = hidden;
  self.safariButton.hidden = hidden;

  self->_url = self.urlTextField.text;
}

- (IBAction)lengthChanged {
  [NSUserDefaults.standardUserDefaults setInteger:self.passwordLengthStepper.value forKey:@"PasswordLength"];
  self.passwordLengthTextField.text =  [NSNumber numberWithInt:self.passwordLengthStepper.value].stringValue;
  [self editingChanged];
}

- (IBAction)toggleShow {
  self.passwordTextField.secureTextEntry = !self.passwordTextField.secureTextEntry;
  
  if (self.passwordTextField.secureTextEntry) {
    [self.showHideButton setTitle:NSLocalizedString(@"ShowPasswordButtonName", nil) forState:UIControlStateNormal];
  }
  else {
    [self.showHideButton setTitle:NSLocalizedString(@"HidePasswordButtonName", nil) forState:UIControlStateNormal];
  }
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

#pragma mark Notifications

- (void)applicationWillResignActive:(NSNotification *)notification {
  self.inactiveDate = NSDate.date;
}

- (void)applicationDidBecomeActive:(NSNotification *)notification {
  if (self.inactiveDate == nil) {
    return;
  }
  
  // Has the background timeout elapsed?
  
  NSTimeInterval elapsed = fabs([NSDate.date timeIntervalSinceDate:self.inactiveDate]);
  
  if (elapsed > [NSUserDefaults.standardUserDefaults integerForKey:@"BackgroundTimeout"]) {
    // Yes, show Settings again to force master password (re-)entry.
    
    if (self.presentedViewController.class == SettingsViewController.class) {
      [((SettingsViewController *)self.presentedViewController) resetForActivate];
    }
    else {
      if (self.presentedViewController.class == HelpViewController.class) {
        [self dismissViewControllerAnimated:NO completion:nil];
      }
      
      [self performSegueWithIdentifier:@"ShowSettingsRequired" sender:self];
    }
  }
  
  self.inactiveDate = nil;
}

#pragma mark UITextFieldDelegate

- (BOOL)textFieldShouldReturn:(UITextField *)textField {
  [textField resignFirstResponder];
  return YES;
}

#pragma mark HelpViewControllerDelegate

- (void)helpViewControllerDidFinish:(HelpViewController *)controller {
  [self dismissViewControllerAnimated:YES completion:nil];
}

#pragma mark SettingsViewControllerDelegate

- (void)settingsViewControllerDidFinish:(SettingsViewController *)controller {
  [PasswordGenerator.sharedGenerator updateMasterPassword:controller.password];

  if (controller.storesHash) {
    [Keychain setString:[PasswordGenerator.sharedGenerator.hash base64EncodedString] forKey:@"Hash"];
  }
  else {
    [Keychain removeStringForKey:@"Hash"];
  }

  [NSUserDefaults.standardUserDefaults setInteger:controller.backgroundTimeout forKey:@"BackgroundTimeout"];
  
  [self editingChanged];
  [self dismissViewControllerAnimated:YES completion:nil];
}

- (void)settingsViewControllerDidCancel:(SettingsViewController *)controller {
  [self dismissViewControllerAnimated:YES completion:nil];
}

@end
