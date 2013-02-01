//
//  AboutViewController.h
//  UberGenPass
//
//  Copyright (c) 2012 Camazotz Limited. All rights reserved.
//

#import <UIKit/UIKit.h>

@class AboutViewController;

@protocol AboutViewControllerDelegate
- (void)aboutViewControllerDidFinish:(AboutViewController *)controller;
@end

@interface AboutViewController : UIViewController
@property (weak, readwrite, nonatomic) id <AboutViewControllerDelegate> delegate;
@end
