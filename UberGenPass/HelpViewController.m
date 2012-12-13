//
//  HelpViewController.m
//  UberGenPass
//
//  Copyright (c) 2012 Camazotz Limited. All rights reserved.
//

#import "HelpViewController.h"

@interface HelpViewController ()
@property (strong, readwrite, nonatomic) IBOutlet UIWebView *webView;
- (IBAction)done;
@end

@implementation HelpViewController

#pragma mark UIViewController

- (void)viewDidLoad {
  [super viewDidLoad];
  
  [self.webView loadRequest:[NSURLRequest requestWithURL:[NSBundle.mainBundle URLForResource:self.documentName withExtension:@"html"]]];
}

- (NSUInteger)supportedInterfaceOrientations {
  return UIInterfaceOrientationMaskAllButUpsideDown;
}

#pragma mark Actions

- (IBAction)done {
  [self.delegate helpViewControllerDidFinish:self];
}

@end
