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
@property (strong, readwrite, nonatomic) IBOutlet UITextField *upperPasswordTextField;
@property (strong, readwrite, nonatomic) IBOutlet UIImageView *upperStatusImageView;
@property (strong, readwrite, nonatomic) IBOutlet UITextField *lowerPasswordTextField;
@property (strong, readwrite, nonatomic) IBOutlet UIImageView *lowerStatusImageView;
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
    [self.upperPasswordTextField becomeFirstResponder];
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
  NSString *upperText = self.upperPasswordTextField.text;
  NSString *lowerText = self.lowerPasswordTextField.text;
  UIImage *upperImage = self.greyImage;
  UIImage *lowerImage = self.greyImage;
  BOOL done = NO;

  // If the upper password field was just edited to match the hash, set the lower field too.
  
  if (sender == self.upperPasswordTextField && [self.hash isEqualToData:[PasswordGenerator sha256:upperText]]) {
    self.lowerPasswordTextField.text = lowerText = upperText;
  }
  
  // Status images.
  
  if (upperText.length > 0 && lowerText.length > 0) {
    if ([upperText isEqualToString:lowerText]) {
      upperImage = lowerImage = self.greenImage;
      done = YES;
    }
    else if ([upperText hasPrefix:lowerText] || [lowerText hasPrefix:upperText]) {
      lowerImage = self.yellowImage;
    }
    else {
      lowerImage = self.redImage;
    }
  }
  
  self.upperStatusImageView.image = upperImage;
  self.lowerStatusImageView.image = lowerImage;
  
  // Done button.
  
  self.doneButtonItem.enabled = done;
  
  // Password text fields.
  
  self.upperPasswordTextField.returnKeyType = done ? UIReturnKeyDone : UIReturnKeyNext;
  self.lowerPasswordTextField.returnKeyType = done ? UIReturnKeyDone : UIReturnKeyNext;
  
  [self.upperPasswordTextField reloadInputViews];
  [self.lowerPasswordTextField reloadInputViews];

  // Animate status images if done.

  if (done) {
    CGRect upperFrame = self.upperStatusImageView.frame;
    CGRect lowerFrame = self.lowerStatusImageView.frame;
    
    [UIView animateWithDuration:0.5
                          delay:0.0
                        options:UIViewAnimationCurveEaseOut
                     animations:^{
                       self.upperStatusImageView.frame = CGRectInset(self.upperStatusImageView.frame, -6, -6);
                       self.lowerStatusImageView.frame = CGRectInset(self.lowerStatusImageView.frame, -6, -6);
                       self.upperStatusImageView.frame = upperFrame;
                       self.lowerStatusImageView.frame = lowerFrame;
                     }
                     completion:^(BOOL finished){
                       if (!finished) {
                         self.upperStatusImageView.frame = upperFrame;
                         self.lowerStatusImageView.frame = lowerFrame;
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
  
  self.password = self.upperPasswordTextField.text;
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
    if (textField == self.upperPasswordTextField) {
      [self.lowerPasswordTextField becomeFirstResponder];
    }
    else {
      [self.upperPasswordTextField becomeFirstResponder];
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
