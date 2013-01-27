//
//  HelpViewController.h
//  UberGenPass
//
//  Copyright (c) 2012 Camazotz Limited. All rights reserved.
//

@class HelpViewController;

@protocol HelpViewControllerDelegate
- (void)helpViewControllerDidFinish:(HelpViewController *)controller;
@end

@interface HelpViewController : UIViewController
@property (copy, readwrite, nonatomic) NSString *documentName;
@property (weak, readwrite, nonatomic) id <HelpViewControllerDelegate> delegate;
@end
