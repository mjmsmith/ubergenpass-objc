//
//  UberGenPassTests.m
//  UberGenPassTests
//
//  Copyright (c) 2012 Camazotz Limited. All rights reserved.
//

#import "PasswordGenerator.h"
#import "PasswordGeneratorTests.h"

@interface UberGenPassTests ()
@property (strong, readwrite, nonatomic) PasswordGenerator *generator;
@end

@implementation UberGenPassTests

- (void)setUp {
  self.generator = [[PasswordGenerator alloc] init];
  [self.generator updateMasterPassword:@"t0pS3cr3t"];
}

- (void)tearDown {
  self.generator = nil;
}

- (void)testURLs {
  NSArray *urls = @[
    @"http://example.com",
    @"http://example.com/foo",
    @"http://example.com?foo",

    @"http://www.example.com",
    @"http://www.example.com/foo",
    @"http://www.example.com?foo",
  ];

  for (NSString *url in urls) {
    XCTAssertEqualObjects([self.generator passwordForSite:url length:10], @"sTX7smlm3O");
  }
}

- (void)testDomains {
  XCTAssertEqualObjects([self.generator passwordForSite:@"example.com" length:10], @"sTX7smlm3O");
  XCTAssertEqualObjects([self.generator passwordForSite:@"example.com/foo" length:10], @"sTX7smlm3O");
  
  XCTAssertEqualObjects([self.generator passwordForSite:@"www.example.com" length:10], @"u8zU8AndAo");
  XCTAssertEqualObjects([self.generator passwordForSite:@"www.example.com/foo" length:10], @"u8zU8AndAo");
}

- (void)testTLDs {
  XCTAssertEqualObjects([self.generator passwordForSite:@"example.co.uk" length:10], @"dyqtqDL83O");
  XCTAssertEqualObjects([self.generator passwordForSite:@"example.com.au" length:10], @"m1DnmJ4c4Q");
  
}

- (void)testLengths {
  for (int i = 4; i < 24; ++i) {
    XCTAssertEqualObjects([self.generator passwordForSite:@"http://example.com" length:i],
                         [@"sTX7smlm3OiNOKgHC3gjpQAA" substringToIndex:i]);
  }
}

- (void)testGarbage {
  NSArray *urls = @[
    @"",
    @"...",
    @"http:",
    @"x",
  ];

  for (NSString *url in urls) {
    XCTAssertNil([self.generator passwordForSite:url length:10]);
  }
}

@end
