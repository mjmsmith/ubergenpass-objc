//
//  HelpViewController.m
//  UberGenPass
//
//  Copyright (c) 2012 Camazotz Limited. All rights reserved.
//

#import "HelpViewController.h"

@interface HelpViewController () <UIWebViewDelegate>
@property (strong, readwrite, nonatomic) IBOutlet UIWebView *webView;
@property (strong, readwrite, nonatomic) IBOutlet UIBarButtonItem *backButtonItem;
@property (strong, readwrite, nonatomic) IBOutlet UIBarButtonItem *forwardButtonItem;
@property (strong, readwrite, nonatomic) IBOutlet NSLayoutConstraint *navigationBarHeightConstraint;
@property (strong, readwrite, nonatomic) IBOutlet NSLayoutConstraint *toolBarHeightConstraint;
- (IBAction)done;
- (IBAction)back;
- (IBAction)forward;
@end

@implementation HelpViewController

#pragma mark Lifecycle

- (void)dealloc {
  self.webView.delegate = nil;
}

#pragma mark UIViewController

- (void)viewDidLoad {
  [super viewDidLoad];
  
  self.backButtonItem.enabled = self.webView.canGoBack;
  self.forwardButtonItem.enabled = self.webView.canGoForward;
  
  [self.webView loadRequest:[NSURLRequest requestWithURL:[NSBundle.mainBundle URLForResource:self.documentName withExtension:@"html"]]];
}

- (void)viewWillAppear:(BOOL)animated {
  [self willRotateToInterfaceOrientation:UIApplication.sharedApplication.statusBarOrientation duration:0];
  [super viewWillAppear:animated];
}

- (NSUInteger)supportedInterfaceOrientations {
  return UIInterfaceOrientationMaskAllButUpsideDown;
}

- (void)willRotateToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation duration:(NSTimeInterval)duration {
  self.navigationBarHeightConstraint.constant = UIInterfaceOrientationIsLandscape(toInterfaceOrientation) ? NavigationBarLandscapeHeight : NavigationBarPortraitHeight;
  self.toolBarHeightConstraint.constant = UIInterfaceOrientationIsLandscape(toInterfaceOrientation) ? ToolBarLandscapeHeight : ToolBarPortraitHeight;
}

#pragma mark UIWebViewDelegate

- (void)webViewDidFinishLoad:(UIWebView *)webView {
  self.backButtonItem.enabled = self.webView.canGoBack;
  self.forwardButtonItem.enabled = self.webView.canGoForward;
}

#pragma mark Actions

- (IBAction)done {
  [self.delegate helpViewControllerDidFinish:self];
}

- (IBAction)back {
  [self.webView goBack];
}

- (IBAction)forward {
  [self.webView goForward];
}

@end
