//
//  PasswordsViewController.m
//  UberGenPass
//
//  Copyright (c) 2012 Camazotz Limited. All rights reserved.
//

#import "HelpViewController.h"
#import "PasswordGenerator.h"
#import "PasswordsViewController.h"
#import "StatusImageView.h"

@interface PasswordsViewController () <HelpViewControllerDelegate>
@property (strong, readwrite, nonatomic) IBOutlet UIBarButtonItem *cancelButtonItem;
@property (strong, readwrite, nonatomic) IBOutlet UIBarButtonItem *doneButtonItem;
@property (strong, readwrite, nonatomic) IBOutlet UITextField *upperMasterTextField;
@property (strong, readwrite, nonatomic) IBOutlet UITextField *lowerMasterTextField;
@property (strong, readwrite, nonatomic) IBOutlet StatusImageView *masterStatusImageView;
@property (strong, readwrite, nonatomic) IBOutlet UITextField *upperSecretTextField;
@property (strong, readwrite, nonatomic) IBOutlet UITextField *lowerSecretTextField;
@property (strong, readwrite, nonatomic) IBOutlet StatusImageView *secretStatusImageView;
@property (strong, readwrite, nonatomic) IBOutlet UIImageView *welcomeImageView;

@property (strong, readwrite, nonatomic) UIImage *greyImage;
@property (strong, readwrite, nonatomic) UIImage *greenImage;
@property (strong, readwrite, nonatomic) UIImage *yellowImage;
@property (strong, readwrite, nonatomic) UIImage *redImage;
@end

@implementation PasswordsViewController

#pragma mark Public

- (void)resetForActivate {
  self.upperMasterTextField.text = self.lowerMasterTextField.text = nil;
  self.upperSecretTextField.text = self.lowerSecretTextField.text = nil;
  
  [self.upperMasterTextField becomeFirstResponder];
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
    self.cancelButtonItem.enabled = NO;
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
    [self.upperMasterTextField becomeFirstResponder];
  }
}

- (NSUInteger)supportedInterfaceOrientations {
  return UIInterfaceOrientationMaskPortrait;
}

- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event {
  // Handle background taps.
  
  if ([[touches anyObject] phase] == UITouchPhaseBegan) {
    [self.view endEditing:YES];
  }
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
  if ([segue.identifier isEqualToString:ShowHelpSegue]) {
    HelpViewController *controller = segue.destinationViewController;
    
    controller.documentName = @"PasswordsHelp";
    controller.delegate = self;
  }
}

#pragma mark Actions

- (IBAction)editingChanged:(id)sender {
  NSString *upperMasterText = self.upperMasterTextField.text;
  NSString *lowerMasterText = self.lowerMasterTextField.text;
  UIImage *masterStatusImage = self.greyImage;
  NSString *upperSecretText = self.upperSecretTextField.text;
  NSString *lowerSecretText = self.lowerSecretTextField.text;
  UIImage *secretStatusImage = self.greyImage;
  BOOL isMasterDone = NO;
  BOOL isSecretDone = NO;
  
  // Master status image.
  
  if (upperMasterText.length > 0 && lowerMasterText.length > 0) {
    if ([upperMasterText isEqualToString:lowerMasterText]) {
      masterStatusImage = self.greenImage;
      isMasterDone = YES;
    }
    else if ([upperMasterText hasPrefix:lowerMasterText] || [lowerMasterText hasPrefix:upperMasterText]) {
      masterStatusImage = self.yellowImage;
    }
    else {
      masterStatusImage = self.redImage;
    }
  }
  
  self.masterStatusImageView.image = masterStatusImage;

  // Secret status image.
  
  if (upperSecretText.length > 0 || lowerSecretText.length > 0) {
    if ([upperSecretText isEqualToString:lowerSecretText]) {
      secretStatusImage = self.greenImage;
      isSecretDone = YES;
    }
    else if ([upperSecretText hasPrefix:lowerSecretText] || [lowerSecretText hasPrefix:upperSecretText]) {
      secretStatusImage = self.yellowImage;
    }
    else if (upperSecretText.length > 0 && lowerSecretText.length > 0) {
      secretStatusImage = self.redImage;
    }

    self.secretStatusImageView.image = secretStatusImage;
    self.secretStatusImageView.hidden = NO;
  }
  else {
    self.secretStatusImageView.hidden = YES;
    isSecretDone = YES;
  }

  // Done button.
  
  self.doneButtonItem.enabled = isMasterDone && isSecretDone;
  
  // Animate status images if done.
  
  if (isMasterDone && (sender == self.upperMasterTextField || sender == self.lowerMasterTextField)) {
    [self.view endEditing:YES];
    [self.masterStatusImageView animate];
  }
  
  if (isSecretDone && (sender == self.upperSecretTextField || sender == self.lowerSecretTextField)) {
    [self.view endEditing:YES];
    [self.secretStatusImageView animate];
  }
}

- (IBAction)done {
  self.masterPassword = self.upperMasterTextField.text;
  self.secretPassword = self.upperSecretTextField.text;
  
  [self.delegate passwordsViewControllerDidFinish:self];
}

- (IBAction)cancel {
  [self.delegate passwordsViewControllerDidCancel:self];
}

#pragma mark UITextFieldDelegate

- (BOOL)textFieldShouldReturn:(UITextField *)textField {
  if (textField == self.upperMasterTextField) {
    [self.lowerMasterTextField becomeFirstResponder];
  }
  else if (textField == self.lowerMasterTextField) {
    [self.upperSecretTextField becomeFirstResponder];
  }
  else if (textField == self.upperSecretTextField) {
    [self.lowerSecretTextField becomeFirstResponder];
  }
  else if (textField == self.lowerSecretTextField) {
    [self.upperMasterTextField becomeFirstResponder];
  }
  
  return NO;
}

#pragma mark HelpViewControllerDelegate

- (void)helpViewControllerDidFinish:(HelpViewController *)controller {
  [self dismissViewControllerAnimated:YES completion:nil];
}

#pragma mark Private

@end
