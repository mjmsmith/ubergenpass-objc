//
//  PasswordGenerator.m
//  UberGenPass
//
//  Copyright (c) 2012 Camazotz Limited. All rights reserved.
//

#import <CommonCrypto/CommonDigest.h>
#import "Keychain.h"
#import "PasswordGenerator.h"

@interface PasswordGenerator ()
@property (retain, readwrite, nonatomic) NSMutableOrderedSet *tlds;
@property (retain, readwrite, nonatomic) NSString *masterPassword;
@property (copy, readwrite, nonatomic) NSData *hash;
@property (retain, readwrite, nonatomic) NSRegularExpression *lowerCasePattern;
@property (retain, readwrite, nonatomic) NSRegularExpression *upperCasePattern;
@property (retain, readwrite, nonatomic) NSRegularExpression *digitPattern;
@property (retain, readwrite, nonatomic) NSRegularExpression *domainPattern;
@end

@implementation PasswordGenerator

#pragma mark Lifecycle

- (id)init {
  if ((self = [super init]) != nil) {
    NSError *error = nil;
    NSString *path = [NSBundle.mainBundle.resourcePath stringByAppendingPathComponent:@"TopLevelDomains.json"];
    NSData *data = [NSData dataWithContentsOfFile:path];
    NSArray *array = [NSJSONSerialization JSONObjectWithData:data options:0 error:&error];
    NSString *hashStr = [Keychain stringForKey:PasswordHashKey];
    
    self.tlds = [NSMutableOrderedSet orderedSetWithArray:array];
    if (hashStr.length != 0) {
      self.hash = [[NSData alloc] initWithBase64EncodedString:hashStr options:0];
    }
    self.lowerCasePattern = [NSRegularExpression regularExpressionWithPattern:@"[a-z]" options:0 error:nil];
    self.upperCasePattern = [NSRegularExpression regularExpressionWithPattern:@"[A-Z]" options:0 error:nil];
    self.digitPattern = [NSRegularExpression regularExpressionWithPattern:@"[\\d]" options:0 error:nil];
    self.domainPattern = [NSRegularExpression regularExpressionWithPattern:@"[^.]+[.][^.]+" options:0 error:nil];
  }
  
  return self;
}

#pragma mark Public

+ (PasswordGenerator *)sharedGenerator {
  static PasswordGenerator *instance;
  static dispatch_once_t onceToken;

  dispatch_once(&onceToken, ^{
    instance = [[PasswordGenerator alloc] init];
  });
  
  return instance;
}

+ (NSData *)md5:(NSString *)str {
  const char *cStr = [str UTF8String];
  unsigned char digest[CC_MD5_DIGEST_LENGTH];
  
  CC_MD5(cStr, strlen(cStr), digest);
  
  return [NSData dataWithBytes:digest length:CC_MD5_DIGEST_LENGTH];
}

+ (NSData *)sha256:(NSString *)str {
  const char *cStr = [str UTF8String];
  unsigned char digest[CC_SHA256_DIGEST_LENGTH];
  
  CC_SHA256(cStr, strlen(cStr), digest);
  
  return [NSData dataWithBytes:digest length:CC_SHA256_DIGEST_LENGTH];
}

- (NSString *)passwordForSite:(NSString *)site length:(int)length {
  if (site == nil) {
    return nil;
  }
  
  NSString *domain = [self domainFromSite:site];
  
  if (domain == nil) {
    return nil;
  }
  
  NSString *password = [NSString stringWithFormat:@"%@:%@", self.masterPassword, domain];
  int count = 0;
  
  while (count < 10 || ![self isValidPassword:[password substringToIndex:length]]) {
    password = [[self.class md5:password] base64EncodedStringWithOptions:0];
    password = [password stringByReplacingOccurrencesOfString:@"=" withString:@"A"];
    password = [password stringByReplacingOccurrencesOfString:@"+" withString:@"9"];
    password = [password stringByReplacingOccurrencesOfString:@"/" withString:@"8"];
    count += 1;
  }
  
  return [password substringToIndex:length];
}

- (NSString *)domainFromSite:(NSString *)site {
  if (site == nil) {
    return nil;
  }
  
  if ([self.domainPattern numberOfMatchesInString:site options:0 range:NSMakeRange(0, site.length)] == 0) {
    return nil;
  }

  if ([site rangeOfString:@"://"].location == NSNotFound) {
    site = [@"//" stringByAppendingString:site];
  }

  NSString *domain = nil;
  NSURL *url = [NSURL URLWithString:site];
  NSString *host = [url.host lowercaseString];

  if ([site hasPrefix:@"//"]) {
    domain = host;
  }
  else {
    NSArray *parts = [host componentsSeparatedByString:@"."];

    if (parts.count >= 2) {
      domain = [[parts subarrayWithRange:NSMakeRange((parts.count - 2), 2)] componentsJoinedByString:@"."];
      
      if ([self.tlds containsObject:domain]) {
        if (parts.count >= 3) {
          domain = [[parts subarrayWithRange:NSMakeRange((parts.count - 3), 3)] componentsJoinedByString:@"."];
        }
        else {
          domain = nil;
        }
      }
    }
  }
  
  return domain;
}

- (BOOL)hasMasterPassword {
  return self.masterPassword != nil;
}

- (void)updateMasterPassword:(NSString *)masterPassword {
  self.masterPassword = masterPassword;
  self.hash = [self.class sha256:masterPassword];
  
  [Keychain setString:[self.hash base64EncodedStringWithOptions:0] forKey:PasswordHashKey];
}

- (BOOL)textMatchesHash:(NSString *)text {
  return [self.hash isEqualToData:[self.class sha256:text]];
}

#pragma mark Private

- (BOOL)isValidPassword:(NSString *)password {
  NSRange range = NSMakeRange(0, password.length);
  
  return [self.lowerCasePattern rangeOfFirstMatchInString:password options:0 range:range].location == 0 &&
         [self.upperCasePattern numberOfMatchesInString:password options:0 range:range] != 0 &&
         [self.digitPattern numberOfMatchesInString:password options:0 range:range] != 0;
}

@end
