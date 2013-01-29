//
//  AboutViewController.h
//  UberGenPass
//
//  Copyright (c) 2012 Camazotz Limited. All rights reserved.
//


#import "AboutViewController.h"
#import "GradientButton.h"

#define AppStoreReviewsURL @"itms-apps://ax.itunes.apple.com/WebObjects/MZStore.woa/wa/viewContentsUserReviews?type=Purple+Software&id=588224057"

@interface AboutViewController ()
@property (strong, readwrite, nonatomic) IBOutlet UIImageView *iconImageView;
@property (strong, readwrite, nonatomic) IBOutlet UILabel *nameLabel;
@property (strong, readwrite, nonatomic) IBOutlet GradientButton *rateButton;
@property (strong, readwrite, nonatomic) IBOutlet UIWebView *webView;
@end

@implementation AboutViewController

#pragma mark Lifecycle

- (void)dealloc {
  self.webView.delegate = nil;
}

#pragma mark UIViewController

- (void)viewDidLoad {
  [super viewDidLoad];
  
  self.nameLabel.text = [NSString stringWithFormat:@"%@ %@",
                         [NSBundle.mainBundle objectForInfoDictionaryKey:@"CFBundleDisplayName"],
                         [NSBundle.mainBundle objectForInfoDictionaryKey:@"CFBundleShortVersionString"]];
  
  self.iconImageView.layer.masksToBounds = YES;
  self.iconImageView.layer.cornerRadius = 10;
  
  [self.rateButton useAlertStyle];
}

- (NSUInteger)supportedInterfaceOrientations {
  return UIInterfaceOrientationMaskPortrait;
}

#pragma mark Actions

- (IBAction)done {
  [self.delegate aboutViewControllerDidFinish:self];
}

- (IBAction)rate {
  [[UIApplication sharedApplication] openURL:[NSURL URLWithString:AppStoreReviewsURL]];
}

@end
