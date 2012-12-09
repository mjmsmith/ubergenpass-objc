//
//  HelpViewController.m
//  UberGenPass
//
//  Created by Mark Smith on 12/7/12.
//  Copyright (c) 2012 Camazotz Limited. All rights reserved.
//

#import "HelpViewController.h"

@interface HelpViewController ()
- (IBAction)done;
@end

@implementation HelpViewController

#pragma mark UIViewController

- (void)viewDidLoad {
 [super viewDidLoad];
}

- (NSUInteger)supportedInterfaceOrientations {
  return UIInterfaceOrientationMaskAllButUpsideDown;
}

#pragma mark Actions

- (IBAction)done {
  [self.delegate helpViewControllerDidFinish:self];
}

@end
