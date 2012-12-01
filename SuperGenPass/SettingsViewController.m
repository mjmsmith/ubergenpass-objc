//
//  SettingsViewController.m
//  SuperGenPass
//
//  Created by Mark Smith on 11/27/12.
//  Copyright (c) 2012 Camazotz Limited. All rights reserved.
//

#import "PasswordGenerator.h"
#import "SettingsViewController.h"

@interface SettingsViewController ()
@property (strong, readwrite, nonatomic) IBOutlet UINavigationBar *navigationBar;
@property (strong, readwrite, nonatomic) IBOutlet UIBarButtonItem *doneButtonItem;
@property (strong, readwrite, nonatomic) IBOutlet UIBarButtonItem *cancelButtonItem;
@property (strong, readwrite, nonatomic) IBOutlet UITextField *upperPasswordTextField;
@property (strong, readwrite, nonatomic) IBOutlet UIImageView *upperPasswordImageView;
@property (strong, readwrite, nonatomic) IBOutlet UITextField *lowerPasswordTextField;
@property (strong, readwrite, nonatomic) IBOutlet UIImageView *lowerPasswordImageView;
@property (strong, readwrite, nonatomic) IBOutlet UISwitch *hashSwitch;
@property (copy, readwrite, nonatomic) NSString *password;
@end

@implementation SettingsViewController

#pragma mark UIViewController

- (void)viewDidLoad {
  [super viewDidLoad];

  if (!self.canCancel) {
    ((UINavigationItem *)self.navigationBar.items[0]).leftBarButtonItem = nil;
  }

  self.hashSwitch.on = self.storesHash;
  
  [self updateState];
  [self.upperPasswordTextField becomeFirstResponder];
}

- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event {
  UITouch *touch = [touches anyObject];
  
  if (touch.phase == UITouchPhaseBegan) {
    [self.view endEditing:YES];
  }
}

#pragma mark Actions

- (IBAction)done {
  self.password = self.upperPasswordTextField.text;
  self.storesHash = self.hashSwitch.on;
  [self.delegate settingsViewControllerDidFinish:self];
}

- (IBAction)cancel {
  [self.delegate settingsViewControllerDidCancel:self];
}

- (IBAction)textFieldEditChanged:(id)sender {
  [self updateState];
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
#pragma mark Private

- (void)updateState {
  NSString *upperText = self.upperPasswordTextField.text;
  NSString *lowerText = self.lowerPasswordTextField.text;
  NSString *upperImageName = @"grey";
  NSString *lowerImageName = @"grey";
  
  // Upper password.
  
  if (upperText.length > 0 && [self.hash isEqualToData:[PasswordGenerator sha256:upperText]]) {
    upperImageName = @"green";
  }
  
  // Lower password.
  
  if ([upperImageName isEqualToString:@"green"]) {
    self.lowerPasswordTextField.text = upperText;
    self.lowerPasswordTextField.enabled = NO;
    lowerImageName = @"green";
  }
  else {
    if (!self.lowerPasswordTextField.enabled) {
      lowerText = @"";
      self.lowerPasswordTextField.text = lowerText;
      self.lowerPasswordTextField.enabled = YES;
    }
    
    if (lowerText.length > 0) {
      if ([upperText isEqualToString:lowerText]) {
        upperImageName = @"green";
        lowerImageName = @"green";
      }
      else {
        if (lowerText.length < upperText.length && [[upperText substringToIndex:lowerText.length] isEqualToString:lowerText]) {
          lowerImageName = @"yellow";
        }
        else {
          lowerImageName = @"red";
        }
      }
    }
  }

  BOOL done = [upperImageName isEqualToString:@"green"];
  
  // Set images.
  
  self.upperPasswordImageView.image = [UIImage imageNamed:upperImageName];
  self.lowerPasswordImageView.image = [UIImage imageNamed:lowerImageName];

  // Done button.
  
  self.doneButtonItem.enabled = done;
  
  // Return key.
  
  self.upperPasswordTextField.returnKeyType = done ? UIReturnKeyDone : UIReturnKeyNext;
  self.lowerPasswordTextField.returnKeyType = done ? UIReturnKeyDone : UIReturnKeyNext;

  [self.upperPasswordTextField reloadInputViews];
  [self.lowerPasswordTextField reloadInputViews];
}

@end
