//
//  SettingsViewController.m
//  UberGenPass
//
//  Copyright (c) 2012 Camazotz Limited. All rights reserved.
//

#import "HelpViewController.h"
#import "PasswordGenerator.h"
#import "SettingsViewController.h"

@interface SettingsViewController () <HelpViewControllerDelegate>
@property (strong, readwrite, nonatomic) UIImage *greyImage;
@property (strong, readwrite, nonatomic) UIImage *greenImage;
@property (strong, readwrite, nonatomic) UIImage *yellowImage;
@property (strong, readwrite, nonatomic) UIImage *redImage;
@property (strong, readwrite, nonatomic) IBOutlet UINavigationBar *navigationBar;
@property (strong, readwrite, nonatomic) IBOutlet UIBarButtonItem *doneButtonItem;
@property (strong, readwrite, nonatomic) IBOutlet UIBarButtonItem *cancelButtonItem;
@property (strong, readwrite, nonatomic) IBOutlet UITextField *upperPasswordTextField;
@property (strong, readwrite, nonatomic) IBOutlet UITextField *lowerPasswordTextField;
@property (strong, readwrite, nonatomic) IBOutlet UIButton *changePasswordButton;
@property (strong, readwrite, nonatomic) IBOutlet UISwitch *passwordHashSwitch;
@property (strong, readwrite, nonatomic) IBOutlet UISwitch *recentSitesSwitch;
@property (strong, readwrite, nonatomic) IBOutlet UISegmentedControl *timeoutSegment;
@property (strong, readwrite, nonatomic) IBOutlet UIImageView *statusImageView;
@property (strong, readwrite, nonatomic) IBOutlet UIImageView *welcomeImageView;
@property (strong, readwrite, nonatomic) IBOutlet NSLayoutConstraint *upperPasswordTextFieldTopConstraint;
@property (strong, readwrite, nonatomic) IBOutlet NSLayoutConstraint *lowerPasswordTextFieldTopConstraint;
@property (assign, readwrite, nonatomic) int prevLowerPasswordTextFieldTopConstraintConstant;
@property (copy, readwrite, nonatomic) NSString *password;
- (IBAction)editingChanged:(id)sender;
- (IBAction)addSafariBookmarklet;
- (IBAction)done;
- (IBAction)cancel;
@end

@implementation SettingsViewController

#pragma mark Public

- (void)resetForActivate {
  if (self.canCancel) {
    self.canCancel = NO;
    [self removeCancelButton];
  }
  
  self.upperPasswordTextField.text = self.lowerPasswordTextField.text = nil;

  [self.upperPasswordTextField becomeFirstResponder];
  [self editingChanged:nil];
}

#pragma mark UIViewController

- (void)viewDidLoad {
  [super viewDidLoad];
  
  self.greyImage = [UIImage imageNamed:@"GreyStatus"];
  self.greenImage = [UIImage imageNamed:@"GreenStatus"];
  self.yellowImage = [UIImage imageNamed:@"YellowStatus"];
  self.redImage = [UIImage imageNamed:@"RedStatus"];

  if (!self.canCancel) {
    [self removeCancelButton];
  }
  
  if (PasswordGenerator.sharedGenerator.hash != nil) {
    self.upperPasswordTextField.returnKeyType = UIReturnKeyDefault;

    self.prevLowerPasswordTextFieldTopConstraintConstant = self.lowerPasswordTextFieldTopConstraint.constant;
    self.lowerPasswordTextFieldTopConstraint.constant = self.upperPasswordTextFieldTopConstraint.constant;
    self.lowerPasswordTextField.hidden = YES;
  }
  else {
    self.changePasswordButton.hidden = YES;
  }
  
  self.recentSitesSwitch.on = self.remembersRecentSites;
  
  if (self.backgroundTimeout == 300) {
    self.timeoutSegment.selectedSegmentIndex = 2;
  }
  else if (self.backgroundTimeout == 60) {
    self.timeoutSegment.selectedSegmentIndex = 1;
  }
  
  if ([NSUserDefaults.standardUserDefaults boolForKey:WelcomeShownKey]) {
    [self.welcomeImageView removeFromSuperview];
    self.welcomeImageView = nil;
  }
  else {
    [NSUserDefaults.standardUserDefaults setBool:YES forKey:WelcomeShownKey];
  }
  
  [self editingChanged:nil];

  if (self.welcomeImageView == nil) {
    [self.upperPasswordTextField becomeFirstResponder];
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
  if ([segue.identifier isEqualToString:ShowHelpSegue]) {
    HelpViewController *controller = segue.destinationViewController;
    
    controller.documentName = @"SettingsHelp";
    controller.delegate = self;
  }
}

#pragma mark Actions

- (IBAction)editingChanged:(id)sender {
  NSString *upperText = self.upperPasswordTextField.text;
  NSString *lowerText = self.lowerPasswordTextField.text;
  UIImage *statusImage = self.greyImage;
  BOOL done = NO;

  // If the upper password field was just edited to match the hash, set the lower field too.
  
  if (sender == self.upperPasswordTextField && [PasswordGenerator.sharedGenerator textMatchesHash:upperText]) {
    self.lowerPasswordTextField.text = lowerText = upperText;
  }
  
  // Status image.
  
  if (upperText.length > 0 && lowerText.length > 0) {
    if ([upperText isEqualToString:lowerText]) {
      statusImage = self.greenImage;
      done = YES;
    }
    else if ([upperText hasPrefix:lowerText] || [lowerText hasPrefix:upperText]) {
      statusImage = self.yellowImage;
    }
    else {
      statusImage = self.redImage;
    }
  }
  
  self.statusImageView.image = statusImage;
  
  // Done button.
  
  self.doneButtonItem.enabled = done;
  
  // Password text fields.
  
  if (done) {
    [self.upperPasswordTextField resignFirstResponder];
    [self.lowerPasswordTextField resignFirstResponder];
  }
  
  // Animate status images if done.

  if (done) {
    CGRect frame = self.statusImageView.frame;
    
    [UIView animateWithDuration:0.4
                     animations:^{
                       self.statusImageView.frame = CGRectInset(self.statusImageView.frame, -12, -12);
                     }
                     completion:^(BOOL finished) {
                       [UIView animateWithDuration:0.6
                                        animations:^{
                                          self.statusImageView.frame = frame;
                                        }
                       ];
                     }
     ];
  }  
}

- (IBAction)changePassword {
  [UIView animateWithDuration:0.3
                   animations:^{
                     self.lowerPasswordTextFieldTopConstraint.constant = self.prevLowerPasswordTextFieldTopConstraintConstant;
                     [self.view layoutIfNeeded];
                   }
                   completion:^(BOOL finished){
                     [UIView transitionWithView:self.lowerPasswordTextField
                                       duration:0.3
                                        options:UIViewAnimationOptionTransitionCrossDissolve
                                     animations:^{
                                       self.changePasswordButton.hidden = YES;
                                       self.upperPasswordTextField.returnKeyType = UIReturnKeyNext;
                                       [self.upperPasswordTextField reloadInputViews];
                                       self.lowerPasswordTextField.hidden = NO;
                                     }
                                     completion:nil];
                     }
   ];
}

- (IBAction)addSafariBookmarklet {
  [UIPasteboard.generalPasteboard setString:@"javascript:location.href='ubergenpass:'+location.href"];
  [UIApplication.sharedApplication openURL:[NSURL URLWithString:@"http://camazotz.com/ubergenpass/bookmarklet"]];
}

- (IBAction)done {
  int timeouts[] = {0, 60, 300};
  
  self.password = self.upperPasswordTextField.text;
  self.remembersRecentSites = self.recentSitesSwitch.on;
  self.backgroundTimeout = timeouts[self.timeoutSegment.selectedSegmentIndex];
  
  [self.delegate settingsViewControllerDidFinish:self];
}

- (IBAction)cancel {
  [self.delegate settingsViewControllerDidCancel:self];
}

#pragma mark UITextFieldDelegate

- (BOOL)textFieldShouldReturn:(UITextField *)textField {
  if (textField == self.upperPasswordTextField) {
    if (!self.lowerPasswordTextField.hidden) {
      [self.lowerPasswordTextField becomeFirstResponder];
    }
  }
  else if (textField == self.lowerPasswordTextField) {
    [self.upperPasswordTextField becomeFirstResponder];
  }

  return NO;
}

#pragma mark HelpViewControllerDelegate

- (void)helpViewControllerDidFinish:(HelpViewController *)controller {
  [self dismissViewControllerAnimated:YES completion:nil];
}

#pragma mark Private

- (void)removeCancelButton {
  ((UINavigationItem *)self.navigationBar.items[0]).leftBarButtonItem = nil;
}

@end
