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
  
  self.greyImage = [UIImage imageNamed:@"grey"];
  self.greenImage = [UIImage imageNamed:@"green"];
  self.yellowImage = [UIImage imageNamed:@"yellow"];
  self.redImage = [UIImage imageNamed:@"red"];

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
  UIImage *upperImage = self.greyImage;
  UIImage *lowerImage = self.greyImage;
  
  // Images.
  
  if (upperText.length > 0 && [self.hash isEqualToData:[PasswordGenerator sha256:upperText]]) {
    self.lowerPasswordTextField.text = upperText;
    upperImage = self.greenImage;
    lowerImage = self.greenImage;
  }
  else {
    if (upperText.length > 0 && lowerText.length > 0) {
      if ([upperText isEqualToString:lowerText]) {
        upperImage = self.greenImage;
        lowerImage = self.greenImage;
      }
      else if ([upperText hasPrefix:lowerText] || [lowerText hasPrefix:upperText]) {
        lowerImage = self.yellowImage;
      }
      else {
        lowerImage = self.redImage;
      }
    }
  }

  BOOL done = (upperImage == self.greenImage);
  
  // Set images.

  self.upperPasswordImageView.image = upperImage;
  self.lowerPasswordImageView.image = lowerImage;
  
  if (done) {
    CGRect upperFrame = self.upperPasswordImageView.frame;
    CGRect lowerFrame = self.lowerPasswordImageView.frame;
    
    [UIView animateWithDuration:0.5
                          delay:0.0
                        options:UIViewAnimationCurveEaseOut
                     animations:^{
                       self.upperPasswordImageView.frame = CGRectInset(self.upperPasswordImageView.frame, -4, -4);
                       self.lowerPasswordImageView.frame = CGRectInset(self.lowerPasswordImageView.frame, -4, -4);
                       self.upperPasswordImageView.frame = upperFrame;
                       self.lowerPasswordImageView.frame = lowerFrame;
                     }
                     completion:^(BOOL finished){
                       if (!finished) {
                         self.upperPasswordImageView.frame = upperFrame;
                         self.lowerPasswordImageView.frame = lowerFrame;
                       }
                     }
     ];
  }
  
  // Done button.
  
  self.doneButtonItem.enabled = done;
  
  // Return key.
  
  self.upperPasswordTextField.returnKeyType = done ? UIReturnKeyDone : UIReturnKeyNext;
  self.lowerPasswordTextField.returnKeyType = done ? UIReturnKeyDone : UIReturnKeyNext;

  [self.upperPasswordTextField reloadInputViews];
  [self.lowerPasswordTextField reloadInputViews];
}

@end
