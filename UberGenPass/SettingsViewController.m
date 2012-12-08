//
//  SettingsViewController.m
//  UberGenPass
//
//  Created by Mark Smith on 11/27/12.
//  Copyright (c) 2012 Camazotz Limited. All rights reserved.
//

#import "PasswordGenerator.h"
#import "SettingsViewController.h"

@interface SettingsViewController ()
@property (strong, readwrite, nonatomic) UIImage *greyImage;
@property (strong, readwrite, nonatomic) UIImage *greenImage;
@property (strong, readwrite, nonatomic) UIImage *yellowImage;
@property (strong, readwrite, nonatomic) UIImage *redImage;
@property (strong, readwrite, nonatomic) IBOutlet UINavigationBar *navigationBar;
@property (strong, readwrite, nonatomic) IBOutlet UIBarButtonItem *doneButtonItem;
@property (strong, readwrite, nonatomic) IBOutlet UIBarButtonItem *cancelButtonItem;
@property (strong, readwrite, nonatomic) IBOutlet UITextField *leftPasswordTextField;
@property (strong, readwrite, nonatomic) IBOutlet UITextField *rightPasswordTextField;
@property (strong, readwrite, nonatomic) IBOutlet UIImageView *statusImageView;
@property (strong, readwrite, nonatomic) IBOutlet UIImageView *welcomeImageView;
@property (strong, readwrite, nonatomic) IBOutlet UISwitch *hashSwitch;
@property (strong, readwrite, nonatomic) IBOutlet UISegmentedControl *timeoutSegment;
@property (copy, readwrite, nonatomic) NSString *password;
- (IBAction)editingChanged:(id)sender;
- (IBAction)done;
- (IBAction)cancel;
- (IBAction)addSafariBookmarklet;
@end

@implementation SettingsViewController

#pragma mark UIViewController

- (void)viewDidLoad {
  [super viewDidLoad];
  
  self.greyImage = [UIImage imageNamed:@"grey"];
  self.greenImage = [UIImage imageNamed:@"green"];
  self.yellowImage = [UIImage imageNamed:@"yellow"];
  self.redImage = [UIImage imageNamed:@"red"];

  if (!self.canCancel) {
    ((UINavigationItem *)self.navigationBar.items[0]).leftBarButtonItem = nil;
  }

  self.hashSwitch.on = self.storesHash;
  
  if (self.backgroundTimeout == 300) {
    self.timeoutSegment.selectedSegmentIndex = 2;
  }
  else if (self.backgroundTimeout == 60) {
    self.timeoutSegment.selectedSegmentIndex = 1;
  }
  
  if ([NSUserDefaults.standardUserDefaults boolForKey:@"welcomeShown"]) {
    self.welcomeImageView.hidden = YES;
  }
  else {
    [NSUserDefaults.standardUserDefaults setBool:YES forKey:@"welcomeShown"];
  }
  
  [self editingChanged:nil];

  if (self.welcomeImageView.hidden) {
    [self.leftPasswordTextField becomeFirstResponder];
  }
}

- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event {
  UITouch *touch = [touches anyObject];
  
  if (touch.phase == UITouchPhaseBegan) {
    [self.view endEditing:YES];
  }
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
  if ([segue.identifier isEqualToString:@"showHelp"]) {
    HelpViewController *controller = segue.destinationViewController;
    
    controller.delegate = self;
  }
}

#pragma mark Actions

- (IBAction)editingChanged:(id)sender {
  NSString *leftText = self.leftPasswordTextField.text;
  NSString *rightText = self.rightPasswordTextField.text;
  UIImage *statusImage = self.greyImage;
  BOOL done = NO;

  // If the left password field was just edited to match the hash, set the right field too.
  
  if (sender == self.leftPasswordTextField && [self.hash isEqualToData:[PasswordGenerator sha256:leftText]]) {
    self.rightPasswordTextField.text = leftText;
  }
  
  // Status image.
  
  if (leftText.length > 0 && rightText.length > 0) {
    if ([leftText isEqualToString:rightText]) {
      statusImage = self.greenImage;
      done = YES;
    }
    else if ([leftText hasPrefix:rightText] || [rightText hasPrefix:leftText]) {
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
  
  self.leftPasswordTextField.returnKeyType = done ? UIReturnKeyDone : UIReturnKeyNext;
  self.rightPasswordTextField.returnKeyType = done ? UIReturnKeyDone : UIReturnKeyNext;
  
  [self.leftPasswordTextField reloadInputViews];
  [self.rightPasswordTextField reloadInputViews];

  // Animate status images if done.

  if (done) {
    CGRect frame = self.statusImageView.frame;
    
    [UIView animateWithDuration:0.5
                          delay:0.0
                        options:UIViewAnimationCurveEaseOut
                     animations:^{
                       self.statusImageView.frame = CGRectInset(self.statusImageView.frame, -6, -6);
                       self.statusImageView.frame = frame;
                     }
                     completion:^(BOOL finished){
                       if (!finished) {
                         self.statusImageView.frame = frame;
                       }
                     }
     ];
  }  
}

- (IBAction)addSafariBookmarklet {
  [UIApplication.sharedApplication openURL:[NSURL URLWithString:@"http://camazotz.com/ubergenpass/bookmark"]];
}

- (IBAction)done {
  int timeouts[] = {0, 60, 300};
  
  self.password = self.leftPasswordTextField.text;
  self.storesHash = self.hashSwitch.on;
  self.backgroundTimeout = timeouts[self.timeoutSegment.selectedSegmentIndex];
  
  [self.delegate settingsViewControllerDidFinish:self];
}

- (IBAction)cancel {
  [self.delegate settingsViewControllerDidCancel:self];
}

#pragma mark UITextFieldDelegate

- (BOOL)textFieldShouldReturn:(UITextField *)textField {
  if (self.doneButtonItem.enabled) {
    [self done];
  }
  else {
    if (textField == self.leftPasswordTextField) {
      [self.rightPasswordTextField becomeFirstResponder];
    }
    else {
      [self.leftPasswordTextField becomeFirstResponder];
    }
  }
  
  return NO;
}

#pragma mark HelpViewControllerDelegate

- (void)helpViewControllerDidFinish:(HelpViewController *)controller {
  [self dismissViewControllerAnimated:YES completion:nil];
}

#pragma mark Private

@end
