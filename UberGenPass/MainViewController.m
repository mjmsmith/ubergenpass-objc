//
//  MainViewController.m
//  UberGenPass
//
//  Copyright (c) 2012 Camazotz Limited. All rights reserved.
//

#import <QuartzCore/QuartzCore.h>

#import "GradientButton.h"
#import "HelpViewController.h"
#import "Keychain.h"
#import "MainViewController.h"
#import "NSData+Base64.h"
#import "PasswordGenerator.h"
#import "SettingsViewController.h"

#define MaxRecentSites 50

@interface MainViewController () <UITableViewDataSource, UITableViewDelegate, HelpViewControllerDelegate, SettingsViewControllerDelegate>
@property (strong, readwrite, nonatomic) IBOutlet UITextField *urlTextField;
@property (strong, readwrite, nonatomic) IBOutlet UIStepper *passwordLengthStepper;
@property (strong, readwrite, nonatomic) IBOutlet UITextField *passwordLengthTextField;
@property (strong, readwrite, nonatomic) IBOutlet UILabel *passwordHostLabel;
@property (strong, readwrite, nonatomic) IBOutlet UITextField *passwordTextField;
@property (strong, readwrite, nonatomic) IBOutlet UIView *passwordTapView;
@property (strong, readwrite, nonatomic) IBOutlet GradientButton *clipboardButton;
@property (strong, readwrite, nonatomic) IBOutlet GradientButton *safariButton;
@property (strong, readwrite, nonatomic) IBOutlet UIImageView *checkmarkImageView;
@property (strong, readwrite, nonatomic) IBOutlet UITableView *matchingSitesTableView;
@property (strong, readwrite, nonatomic) IBOutlet UILabel *versionLabel;
@property (strong, readwrite, nonatomic) NSDate *inactiveDate;
@property (strong, readwrite, nonatomic) NSMutableOrderedSet *recentSites;
@property (strong, readwrite, nonatomic) NSArray *matchingSites;
@end

@implementation MainViewController

#pragma mark Lifecycle

- (void)dealloc {
  [NSNotificationCenter.defaultCenter removeObserver:self name:UIApplicationWillResignActiveNotification object:nil];
  [NSNotificationCenter.defaultCenter removeObserver:self name:UIApplicationDidBecomeActiveNotification object:nil];
  [NSNotificationCenter.defaultCenter removeObserver:self name:UIPasteboardChangedNotification object:UIPasteboard.generalPasteboard];
}

#pragma mark Public

- (void)setUrl:(NSString *)url {
  if (self.urlTextField == nil) {
    self->_url = url;
  }
  else {
    self.urlTextField.text = url;

    [self editingChanged];
    
    if (!self.passwordTextField.hidden) {
      [self.urlTextField resignFirstResponder];
    }
  }
}

#pragma mark UIViewController

- (void)viewDidLoad {
  [super viewDidLoad];

  NSArray *recentSites = [NSUserDefaults.standardUserDefaults arrayForKey:@"RecentSites"];
  
  if (recentSites != nil) {
    self.recentSites = [NSMutableOrderedSet orderedSetWithArray:recentSites];
    self.matchingSites = [NSMutableArray array];
  }
  
  // Notifications.
  
  [NSNotificationCenter.defaultCenter addObserver:self
                                         selector:@selector(applicationWillResignActive:)
                                             name:UIApplicationWillResignActiveNotification object:nil];
  [NSNotificationCenter.defaultCenter addObserver:self
                                         selector:@selector(applicationDidBecomeActive:)
                                             name:UIApplicationDidBecomeActiveNotification object:nil];
  [NSNotificationCenter.defaultCenter addObserver:self
                                         selector:@selector(pasteboardChanged:)
                                             name:UIPasteboardChangedNotification object:UIPasteboard.generalPasteboard];
  // URL text field.
  
  self.urlTextField.text = self.url;

  // Password length stepper and text field.
  
  int passwordLength = [NSUserDefaults.standardUserDefaults integerForKey:@"PasswordLength"];
  
  self.passwordLengthStepper.minimumValue = 4;
  self.passwordLengthStepper.maximumValue = 24;
  self.passwordLengthStepper.value = (passwordLength == 0) ? 10 : passwordLength;

  self.passwordLengthTextField.text = [NSString stringWithFormat:@"%d", (int)self.passwordLengthStepper.value];

  // Password text field.  We can't set the height in IB if the style is a rounded rect.
  
  self.passwordTextField.borderStyle = UITextBorderStyleRoundedRect;
  
  // Password buttons.
  
  [self.clipboardButton useAlertStyle];
  [self.safariButton useAlertStyle];

  // Controls hidden until we have a site.
  
  self.passwordHostLabel.hidden = YES;
  self.passwordTextField.hidden = YES;
  self.clipboardButton.hidden = YES;
  self.safariButton.hidden = YES;
  self.checkmarkImageView.hidden = YES;
  
  // Matching sites popup.
  
  self.matchingSitesTableView.hidden = YES;

  self.matchingSitesTableView.layer.masksToBounds = NO;
  self.matchingSitesTableView.layer.shadowOpacity = 0.5;
  
  // Version label.
  
  self.versionLabel.text = [NSBundle.mainBundle objectForInfoDictionaryKey:@"CFBundleShortVersionString"];

  // If we're ready to generate passwords, update the UI as usual.
  
  if (PasswordGenerator.sharedGenerator.hasMasterPassword) {
    [self editingChanged];

    if (!self.passwordTextField.hidden) {
      [self.urlTextField resignFirstResponder];
    }
  }
}

- (void)viewDidAppear:(BOOL)animated {
  [super viewDidAppear:animated];
  
  // If we have no master password, force a segue to Settings (only happens on startup).
  // Otherwise, set focus if we have no site text.
  
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
    controller.savesPasswordHash = PasswordGenerator.sharedGenerator.savesHash;
    controller.remembersRecentSites = (self.recentSites != nil);
    controller.backgroundTimeout = [NSUserDefaults.standardUserDefaults integerForKey:@"BackgroundTimeout"];
    controller.delegate = self;
  }
}

#pragma mark Actions

- (IBAction)editingChanged {
  NSString *domain = [PasswordGenerator.sharedGenerator domainFromURL:self.urlTextField.text];
  BOOL hidden = (domain == nil);

  if (!hidden) {
    self.passwordHostLabel.text = domain;
    self.passwordTextField.text = [PasswordGenerator.sharedGenerator passwordForURL:self.urlTextField.text
                                                                             length:self.passwordLengthStepper.value];
  }
  
  self.passwordHostLabel.hidden = hidden;
  self.passwordTextField.hidden = hidden;
  self.clipboardButton.hidden = hidden;
  self.safariButton.hidden = hidden;

  [self updateClipboardCheckmark];
  
  if (self.recentSites != nil) {
    self.matchingSites = [self recentSitesWithPrefix:[self.urlTextField.text lowercaseString]];
    
    if (self.matchingSites.count == 0) {
      self.matchingSitesTableView.hidden = YES;
    }
    else {
      [self.matchingSitesTableView reloadData];
      self.matchingSitesTableView.hidden = NO;
    }
  }
  
  self->_url = self.urlTextField.text;
}

- (IBAction)lengthChanged {
  [NSUserDefaults.standardUserDefaults setInteger:self.passwordLengthStepper.value forKey:@"PasswordLength"];
  self.passwordLengthTextField.text =  [NSNumber numberWithInt:self.passwordLengthStepper.value].stringValue;
  [self editingChanged];
}

- (IBAction)tapGestureRecognized:(UITapGestureRecognizer *)recognizer {
  self.passwordTextField.secureTextEntry = !self.passwordTextField.secureTextEntry;
  [self.urlTextField resignFirstResponder];
}

- (IBAction)copyToClipboard {
  UIPasteboard.generalPasteboard.string = self.passwordTextField.text;
  [self updateClipboardCheckmark];
  
  if (self.recentSites != nil ) {
    [self addRecentSite:[PasswordGenerator.sharedGenerator domainFromURL:self.url]];
  }
}

- (IBAction)launchSafari {
  NSString *url = self.url;
  
  if ([url rangeOfString:@":"].location == NSNotFound) {
    url = [@"http://" stringByAppendingString:url];
  }
  
  if (self.recentSites != nil ) {
    [self addRecentSite:[PasswordGenerator.sharedGenerator domainFromURL:url]];
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
  else {
    [self updateClipboardCheckmark];
  }
  
  self.inactiveDate = nil;
}

- (void)pasteboardChanged:(NSNotification *)notification {
  [self updateClipboardCheckmark];
}

#pragma mark UITableViewDataSource

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
  return self.matchingSites.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
  UITableViewCell *cell = [self.matchingSitesTableView dequeueReusableCellWithIdentifier:@"MatchingSitesTableViewCell"];
  
  cell.textLabel.text = self.matchingSites[indexPath.row];
  
  return cell;
}

#pragma mark UITableViewDelegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
  [self.matchingSitesTableView deselectRowAtIndexPath:indexPath animated:YES];

  self.urlTextField.text = self.matchingSites[indexPath.row];
  [self editingChanged];
}

#pragma mark UITextFieldDelegate

- (void)textFieldDidBeginEditing:(UITextField *)textField {
  if (self.recentSites != nil) {
    self.matchingSitesTableView.hidden = (self.matchingSites.count == 0);
  }
}

- (void)textFieldDidEndEditing:(UITextField *)textField {
  if (self.recentSites != nil) {
    self.matchingSitesTableView.hidden = YES;
  }
}

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

  if (controller.savesPasswordHash) {
    [Keychain setString:[PasswordGenerator.sharedGenerator.hash base64EncodedString] forKey:@"Hash"];
  }
  else {
    [Keychain removeStringForKey:@"Hash"];
  }

  if (controller.remembersRecentSites) {
    if (self.recentSites == nil) {
      self.recentSites = [NSMutableOrderedSet orderedSet];
      self.matchingSites = [NSMutableArray array];

      [NSUserDefaults.standardUserDefaults setObject:[self.recentSites array] forKey:@"RecentSites"];
    }
  }
  else {
    if (self.recentSites != nil) {
      self.recentSites = nil;
      self.matchingSites = nil;

      [NSUserDefaults.standardUserDefaults removeObjectForKey:@"RecentSites"];
      self.matchingSitesTableView.hidden = YES;
    }
  }

  [NSUserDefaults.standardUserDefaults setInteger:controller.backgroundTimeout forKey:@"BackgroundTimeout"];
  
  [self editingChanged];
  [self dismissViewControllerAnimated:YES completion:nil];
}

- (void)settingsViewControllerDidCancel:(SettingsViewController *)controller {
  [self dismissViewControllerAnimated:YES completion:nil];
}

#pragma mark Private

- (void)addRecentSite:(NSString *)site {
  if ([self.recentSites containsObject:site]) {
    return;
  }

  if (self.recentSites.count >= MaxRecentSites) {
    [self.recentSites removeObjectAtIndex:0];
  }
  [self.recentSites addObject:site];

  [NSUserDefaults.standardUserDefaults setObject:[self.recentSites array] forKey:@"RecentSites"];
}

- (NSArray *)recentSitesWithPrefix:(NSString *)prefix {
  NSMutableArray *sites = [NSMutableArray array];
  
  if (prefix.length == 0) {
    return sites;
  }

  for (NSString *site in self.recentSites) {
    if (site.length > prefix.length && [site hasPrefix:prefix]) {
      [sites addObject:site];
    }
  }

  return [sites sortedArrayUsingComparator:^(NSString *left, NSString *right) {
    return [left compare:right];
  }];
}

- (void)updateClipboardCheckmark {
  self.checkmarkImageView.hidden = self.clipboardButton.hidden ||
                                   ![self.passwordTextField.text isEqualToString:UIPasteboard.generalPasteboard.string];
}

@end
