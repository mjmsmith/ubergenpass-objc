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
  [self.generator updateMasterPassword:@"abra" secretPassword:@"cadabra"];
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

  // MD5
  
  for (NSString *url in urls) {
    XCTAssertEqualObjects([self.generator passwordForSite:url length:10 type:PasswordTypeMD5], @"vECk329fUo");
  }

  // SHA
  
  for (NSString *url in urls) {
    XCTAssertEqualObjects([self.generator passwordForSite:url length:10 type:PasswordTypeSHA], @"qUk8Mt3Kdg");
  }
}

- (void)testDomains {
  // MD5
  
  XCTAssertEqualObjects([self.generator passwordForSite:@"example.com" length:10 type:PasswordTypeMD5], @"vECk329fUo");
  XCTAssertEqualObjects([self.generator passwordForSite:@"example.com/foo" length:10 type:PasswordTypeMD5], @"vECk329fUo");
  
  XCTAssertEqualObjects([self.generator passwordForSite:@"www.example.com" length:10 type:PasswordTypeMD5], @"bqH11xlQ4h");
  XCTAssertEqualObjects([self.generator passwordForSite:@"www.example.com/foo" length:10 type:PasswordTypeMD5], @"bqH11xlQ4h");

  // SHA
  
  XCTAssertEqualObjects([self.generator passwordForSite:@"example.com" length:10 type:PasswordTypeSHA], @"qUk8Mt3Kdg");
  XCTAssertEqualObjects([self.generator passwordForSite:@"example.com/foo" length:10 type:PasswordTypeSHA], @"qUk8Mt3Kdg");
  
  XCTAssertEqualObjects([self.generator passwordForSite:@"www.example.com" length:10 type:PasswordTypeSHA], @"cl4IEJYsVB");
  XCTAssertEqualObjects([self.generator passwordForSite:@"www.example.com/foo" length:10 type:PasswordTypeSHA], @"cl4IEJYsVB");
}

- (void)testTLDs {
  // MD5
  
  XCTAssertEqualObjects([self.generator passwordForSite:@"example.co.uk" length:10 type:PasswordTypeMD5], @"lqmq7iHtdE");
  XCTAssertEqualObjects([self.generator passwordForSite:@"example.com.au" length:10 type:PasswordTypeMD5], @"wC3efbHg4M");
  
  // SHA
  
  XCTAssertEqualObjects([self.generator passwordForSite:@"example.co.uk" length:10 type:PasswordTypeSHA], @"nCY8DK8zuz");
  XCTAssertEqualObjects([self.generator passwordForSite:@"example.com.au" length:10 type:PasswordTypeSHA], @"zwwpWW95d9");
}

- (void)testLengths {
  // MD5
  
  XCTAssertEqualObjects([self.generator passwordForSite:@"http://example.com" length:4 type:PasswordTypeMD5], @"sG0h");
  for (int i = 5; i < 24; ++i) {
    XCTAssertEqualObjects([self.generator passwordForSite:@"http://example.com" length:i type:PasswordTypeMD5],
                         [@"vECk329fUoS5hG82rn89MAAA" substringToIndex:i]);
  }

  // SHA
  
  for (int i = 4; i < 24; ++i) {
    XCTAssertEqualObjects([self.generator passwordForSite:@"http://example.com" length:i type:PasswordTypeSHA],
                          [@"qUk8Mt3KdgS09faw1mdrOqRb" substringToIndex:i]);
  }
}

- (void)testGarbage {
  NSArray *urls = @[
    @"",
    @"...",
    @"http:",
    @"x",
  ];

  // MD5
  
  for (NSString *url in urls) {
    XCTAssertNil([self.generator passwordForSite:url length:10 type:PasswordTypeMD5]);
  }

  // SHA
  
  for (NSString *url in urls) {
    XCTAssertNil([self.generator passwordForSite:url length:10 type:PasswordTypeSHA]);
  }
}

@end
