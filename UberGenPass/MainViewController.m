//
//  MainViewController.m
//  UberGenPass
//
//  Copyright (c) 2012 Camazotz Limited. All rights reserved.
//

#import <QuartzCore/QuartzCore.h>

#import "AboutViewController.h"
#import "GradientButton.h"
#import "HelpViewController.h"
#import "Keychain.h"
#import "MainViewController.h"
#import "NSData+Base64.h"
#import "PasswordGenerator.h"
#import "SettingsViewController.h"

#define MaxRecentSites 50
#define MaxMatchingSiteListItems 5

@interface MainViewController () <UITableViewDataSource, UITableViewDelegate,
                                  AboutViewControllerDelegate, HelpViewControllerDelegate, SettingsViewControllerDelegate>
@property (strong, readwrite, nonatomic) IBOutlet UITextField *siteTextField;
@property (strong, readwrite, nonatomic) IBOutlet UIStepper *passwordLengthStepper;
@property (strong, readwrite, nonatomic) IBOutlet UITextField *passwordLengthTextField;
@property (strong, readwrite, nonatomic) IBOutlet UILabel *domainLabel;
@property (strong, readwrite, nonatomic) IBOutlet UITextField *passwordTextField;
@property (strong, readwrite, nonatomic) IBOutlet UIView *passwordTapView;
@property (strong, readwrite, nonatomic) IBOutlet GradientButton *clipboardButton;
@property (strong, readwrite, nonatomic) IBOutlet GradientButton *safariButton;
@property (strong, readwrite, nonatomic) IBOutlet UIImageView *checkmarkImageView;
@property (strong, readwrite, nonatomic) IBOutlet UIView *matchingSitesView;
@property (strong, readwrite, nonatomic) IBOutlet UITableView *matchingSitesTableView;
@property (strong, readwrite, nonatomic) IBOutlet NSLayoutConstraint *matchingSitesViewHeightConstraint;
@property (strong, readwrite, nonatomic) UIView *coveringView;
@property (strong, readwrite, nonatomic) NSDate *inactiveDate;
@property (strong, readwrite, nonatomic) NSMutableOrderedSet *recentSites;
@property (strong, readwrite, nonatomic) NSArray *matchingSites;
- (IBAction)editingChanged;
- (IBAction)lengthChanged;
- (IBAction)tapGestureRecognized:(UITapGestureRecognizer *)recognizer;
- (IBAction)copyToClipboard;
- (IBAction)launchSafari;
@end

@implementation MainViewController

#pragma mark Lifecycle

- (void)dealloc {
  [NSNotificationCenter.defaultCenter removeObserver:self name:UIApplicationDidEnterBackgroundNotification object:nil];
  [NSNotificationCenter.defaultCenter removeObserver:self name:UIApplicationWillEnterForegroundNotification object:nil];
  [NSNotificationCenter.defaultCenter removeObserver:self name:UIPasteboardChangedNotification object:UIPasteboard.generalPasteboard];
}

#pragma mark Public

- (void)setSite:(NSString *)site {
  if (self.siteTextField == nil) {
    self->_site = site;
  }
  else {
    self.siteTextField.text = site;
    [self editingChanged];
  }
}

#pragma mark UIViewController

- (void)viewDidLoad {
  [super viewDidLoad];

  // Recent sites.
  
  NSError *error = nil;
  NSString *str = [Keychain stringForKey:RecentSitesKey];
  NSData *data = [str dataUsingEncoding:NSUTF8StringEncoding];
  NSArray *recentSites = (data == nil) ? nil : [NSJSONSerialization JSONObjectWithData:data options:0 error:&error];
  
  if (recentSites != nil) {
    self.recentSites = [NSMutableOrderedSet orderedSetWithArray:recentSites];
    self.matchingSites = [NSMutableArray array];
  }
  
  // Notifications.
  
  [NSNotificationCenter.defaultCenter addObserver:self
                                         selector:@selector(applicationDidEnterBackground:)
                                             name:UIApplicationDidEnterBackgroundNotification object:nil];
  [NSNotificationCenter.defaultCenter addObserver:self
                                         selector:@selector(applicationWillEnterForeground:)
                                             name:UIApplicationWillEnterForegroundNotification object:nil];
  [NSNotificationCenter.defaultCenter addObserver:self
                                         selector:@selector(pasteboardChanged:)
                                             name:UIPasteboardChangedNotification object:UIPasteboard.generalPasteboard];
  // Site text field.
  
  self.siteTextField.text = self.site;

  // Password length stepper and text field.
  
  int passwordLength = [NSUserDefaults.standardUserDefaults integerForKey:PasswordLengthKey];
  
  self.passwordLengthStepper.minimumValue = 4;
  self.passwordLengthStepper.maximumValue = 24;
  self.passwordLengthStepper.value = (passwordLength == 0) ? 10 : passwordLength;

  self.passwordLengthTextField.text = [NSString stringWithFormat:@"%d", (int)self.passwordLengthStepper.value];

  // Password text field.  We can't set the height in IB if the style is a rounded rect.
  
  self.passwordTextField.borderStyle = UITextBorderStyleRoundedRect;
  
  // Password buttons.
  
  [self.clipboardButton useAlertStyle];
  [self.safariButton useAlertStyle];
  
  // Matching sites popup.
  
  self.matchingSitesView.layer.shadowColor = UIColor.blackColor.CGColor;
  self.matchingSitesView.layer.shadowOpacity = 0.75;
  self.matchingSitesView.layer.shadowOffset = CGSizeMake(4, 2);
  self.matchingSitesView.layer.shadowRadius = 10;
  
  // Controls hidden until we have a site.
  
  self.domainLabel.hidden = YES;
  self.passwordTextField.hidden = YES;
  self.passwordTapView.hidden = YES;
  self.clipboardButton.hidden = YES;
  self.safariButton.hidden = YES;
  self.checkmarkImageView.hidden = YES;
  self.matchingSitesView.hidden = YES;

  // If we're ready to generate passwords, update the UI as usual.
  
  if (PasswordGenerator.sharedGenerator.hasMasterPassword) {
    [self editingChanged];
  }
}

- (void)viewWillAppear:(BOOL)animated {
  [super viewWillAppear:animated];

  if (!PasswordGenerator.sharedGenerator.hasMasterPassword) {
    [self addCoveringView];
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
    if (self.siteTextField.text.length == 0) {
      [self.siteTextField becomeFirstResponder];
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
  if ([segue.identifier isEqualToString:@"ShowAbout"]) {
    AboutViewController *controller = segue.destinationViewController;
    
    controller.delegate = self;
  }
  else if ([segue.identifier isEqualToString:@"ShowHelp"]) {
    HelpViewController *controller = segue.destinationViewController;
    
    controller.documentName = @"MainHelp";
    controller.delegate = self;
  }
  else if ([segue.identifier isEqualToString:@"ShowSettingsOptional"] ||
           [segue.identifier isEqualToString:@"ShowSettingsRequired"]) {
    SettingsViewController *controller = segue.destinationViewController;
    
    controller.canCancel = [segue.identifier isEqualToString:@"ShowSettingsOptional"];
    controller.savesPasswordHash = PasswordGenerator.sharedGenerator.savesHash;
    controller.remembersRecentSites = (self.recentSites != nil);
    controller.backgroundTimeout = [NSUserDefaults.standardUserDefaults integerForKey:BackgroundTimeoutKey];
    controller.delegate = self;
  }
}

#pragma mark Actions

- (IBAction)editingChanged {
  NSString *domain = [PasswordGenerator.sharedGenerator domainFromSite:self.siteTextField.text];

  if (domain != nil) {
    self.domainLabel.text = domain;
    [self updatePasswordTextField];
  }
  
  BOOL hidden = (domain == nil);

  self.domainLabel.hidden = hidden;
  self.passwordTextField.hidden = hidden;
  self.passwordTapView.hidden = hidden;
  self.clipboardButton.hidden = hidden;
  self.safariButton.hidden = hidden;

  [self updateClipboardCheckmark];
  
  if (self.recentSites != nil) {
    self.matchingSites = [self recentSitesMatchingText:[self.siteTextField.text lowercaseString]];
    
    if (self.matchingSites.count == 0) {
      self.matchingSitesView.hidden = YES;
    }
    else {
      [self.matchingSitesTableView reloadData];
      [self sizeAndShowMatchingSitesView];
    }
  }

  self->_site = self.siteTextField.text;
}

- (IBAction)lengthChanged {
  [NSUserDefaults.standardUserDefaults setInteger:self.passwordLengthStepper.value forKey:PasswordLengthKey];
  self.passwordLengthTextField.text = [NSNumber numberWithInt:self.passwordLengthStepper.value].stringValue;
  
  if (!self.passwordTextField.hidden) {
    [self updatePasswordTextField];
    [self updateClipboardCheckmark];
  }
}

- (IBAction)tapGestureRecognized:(UITapGestureRecognizer *)recognizer {
  self.passwordTextField.secureTextEntry = !self.passwordTextField.secureTextEntry;
  [self.siteTextField resignFirstResponder];

  if (self.recentSites != nil) {
    [self addToRecentSites];
  }
}

- (IBAction)copyToClipboard {
  UIPasteboard.generalPasteboard.string = self.passwordTextField.text;
  [self updateClipboardCheckmark];
  
  if (self.recentSites != nil) {
    [self addToRecentSites];
  }
}

- (IBAction)launchSafari {
  NSString *site = self.siteTextField.text;
  
  if ([site rangeOfString:@":"].location == NSNotFound) {
    site = [@"http://" stringByAppendingString:site];
  }
  
  if (self.recentSites != nil) {
    [self addToRecentSites];
  }
  
  [UIApplication.sharedApplication openURL:[NSURL URLWithString:site]];
}

#pragma mark Notifications

- (void)applicationWillEnterForeground:(NSNotification *)notification {
  if (self.inactiveDate == nil) {
    return;
  }
  
  // Has the background timeout elapsed?
  
  NSTimeInterval elapsed = fabs([NSDate.date timeIntervalSinceDate:self.inactiveDate]);
  
  if (elapsed > [NSUserDefaults.standardUserDefaults integerForKey:BackgroundTimeoutKey]) {
    // Yes, show Settings again to force master password (re-)entry.
    
    if (self.presentedViewController.class == SettingsViewController.class) {
      [((SettingsViewController *)self.presentedViewController) resetForActivate];
    }
    else {
      if (self.presentedViewController != nil) {
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

- (void)applicationDidEnterBackground:(NSNotification *)notification {
  self.inactiveDate = NSDate.date;
  [self addCoveringView];
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

  self.siteTextField.text = self.matchingSites[indexPath.row];
  [self editingChanged];
  self.matchingSitesView.hidden = YES;
}

#pragma mark UITextFieldDelegate

- (void)textFieldDidBeginEditing:(UITextField *)textField {
  if (self.recentSites != nil) {
    if (self.matchingSites.count != 0) {
      [self sizeAndShowMatchingSitesView];
    }
  }
}

- (void)textFieldDidEndEditing:(UITextField *)textField {
  if (self.recentSites != nil) {
    self.matchingSitesView.hidden = YES;
  }
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField {
  [textField resignFirstResponder];
  return YES;
}

#pragma mark AboutViewControllerDelegate

- (void)aboutViewControllerDidFinish:(AboutViewController *)controller {
  [self dismissViewControllerAnimated:YES completion:nil];
}

#pragma mark HelpViewControllerDelegate

- (void)helpViewControllerDidFinish:(HelpViewController *)controller {
  [self dismissViewControllerAnimated:YES completion:nil];
}

#pragma mark SettingsViewControllerDelegate

- (void)settingsViewControllerDidFinish:(SettingsViewController *)controller {
  [PasswordGenerator.sharedGenerator updateMasterPassword:controller.password];
  PasswordGenerator.sharedGenerator.savesHash = controller.savesPasswordHash;

  if (controller.remembersRecentSites) {
    if (self.recentSites == nil) {
      self.recentSites = [NSMutableOrderedSet orderedSet];
      self.matchingSites = [NSMutableArray array];

      [self saveRecentSites];
    }
  }
  else {
    if (self.recentSites != nil) {
      self.recentSites = nil;
      self.matchingSites = nil;

      [NSUserDefaults.standardUserDefaults removeObjectForKey:RecentSitesKey];
      self.matchingSitesView.hidden = YES;
    }
  }

  [NSUserDefaults.standardUserDefaults setInteger:controller.backgroundTimeout forKey:BackgroundTimeoutKey];
  
  if (!self.passwordTextField.hidden) {
    [self updatePasswordTextField];
    [self updateClipboardCheckmark];
  }

  if (self.coveringView != nil) {
    [self.coveringView removeFromSuperview];
    self.coveringView = nil;
  }

  [self dismissViewControllerAnimated:YES completion:nil];
}

- (void)settingsViewControllerDidCancel:(SettingsViewController *)controller {
  [self dismissViewControllerAnimated:YES completion:nil];
}

#pragma mark Private

- (void)addCoveringView {
  if (self.coveringView != nil) {
    return;
  }
  
  self.coveringView = [[UIView alloc] initWithFrame:self.view.bounds];
  self.coveringView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
  self.coveringView.backgroundColor = self.view.backgroundColor;
  
  [self.view addSubview:self.coveringView];
}

- (void)addToRecentSites {
  NSString *site = [PasswordGenerator.sharedGenerator domainFromSite:self.siteTextField.text];

  // Ignore this site if it's already the most recent one.
  
  if ([site isEqualToString:self.recentSites.lastObject]) {
    return;
  }
  
  // Append the site to the end of the ordered set.
  
  [self.recentSites removeObject:site];

  if (self.recentSites.count >= MaxRecentSites) {
    [self.recentSites removeObjectAtIndex:0];
  }

  [self.recentSites addObject:site];
  [self saveRecentSites];
}

- (NSArray *)recentSitesMatchingText:(NSString *)text {
  NSMutableArray *prefixSites = [NSMutableArray array];
  NSMutableArray *insideSites = [NSMutableArray array];
  
  if (text.length == 0) {
    return prefixSites;
  }

  for (NSString *site in self.recentSites) {
    NSRange range = [site rangeOfString:text];
    
    if (range.location == 0) {
      [prefixSites addObject:site];
    }
    else if (range.location != NSNotFound) {
      [insideSites addObject:site];
    }
  }

  NSArray *firstSites = [prefixSites sortedArrayUsingComparator:^(NSString *left, NSString *right) {
    return [left compare:right];
  }];
  NSArray *secondSites = [insideSites sortedArrayUsingComparator:^(NSString *left, NSString *right) {
    return [left compare:right];
  }];
  
  return [firstSites arrayByAddingObjectsFromArray:secondSites];
}

- (void)saveRecentSites {
  NSError *error = nil;
  NSData *data = [NSJSONSerialization dataWithJSONObject:[self.recentSites array] options:0 error:&error];
  NSString *str = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
  
  [Keychain setString:str forKey:RecentSitesKey];
}

- (void)sizeAndShowMatchingSitesView {
  self.matchingSitesViewHeightConstraint.constant = MIN(self.matchingSites.count, MaxMatchingSiteListItems) *
                                                    self.matchingSitesTableView.rowHeight;
  self.matchingSitesView.hidden = NO;
}

- (void)updatePasswordTextField {
  self.passwordTextField.secureTextEntry = YES;
  self.passwordTextField.text = [PasswordGenerator.sharedGenerator passwordForSite:self.siteTextField.text
                                                                            length:self.passwordLengthStepper.value];
}

- (void)updateClipboardCheckmark {
  self.checkmarkImageView.hidden = self.clipboardButton.hidden ||
                                   ![self.passwordTextField.text isEqualToString:UIPasteboard.generalPasteboard.string];
}

@end
