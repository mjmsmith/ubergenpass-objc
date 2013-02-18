//
//  PasswordGenerator.m
//  UberGenPass
//
//  Copyright (c) 2012 Camazotz Limited. All rights reserved.
//

#import <CommonCrypto/CommonDigest.h>
#import "Keychain.h"
#import "NSData+Base64.h"
#import "PasswordGenerator.h"

static NSMutableSet *TLDs;

@interface PasswordGenerator ()
@property (retain, readwrite, nonatomic) NSString *masterPassword;
@property (copy, readwrite, nonatomic) NSData *hash;
@property (retain, readwrite, nonatomic) NSRegularExpression *lowerCasePattern;
@property (retain, readwrite, nonatomic) NSRegularExpression *upperCasePattern;
@property (retain, readwrite, nonatomic) NSRegularExpression *digitPattern;
@property (retain, readwrite, nonatomic) NSRegularExpression *domainPattern;
@end

@implementation PasswordGenerator

#pragma mark Lifecycle

+ (void)initialize {
  if (self == PasswordGenerator.class) {
    NSError *error = nil;
    NSString *path = [NSBundle.mainBundle.resourcePath stringByAppendingPathComponent:@"TopLevelDomains.txt"];
    NSString *text = [NSString stringWithContentsOfFile:path encoding:NSUTF8StringEncoding error:&error];
    NSRegularExpression *whitespace = [NSRegularExpression regularExpressionWithPattern:@"\\s" options:0 error:nil];
    
    NSAssert((error == nil), @"read error in tlds");
    NSAssert(([text rangeOfString:@"$"].location == NSNotFound), @"$ in tlds");
    
    text = [text stringByReplacingOccurrencesOfString:@"\n" withString:@"$"];
    NSAssert(([whitespace numberOfMatchesInString:text options:0 range:NSMakeRange(0, text.length)] == 0), @"whitespace in tlds");
    
    TLDs = [NSMutableSet setWithArray:[text componentsSeparatedByString:@"$"]];
    [TLDs removeObject:@""];
  }
}

- (id)init {
  if ((self = [super init]) != nil) {
    self.hash = [NSData dataFromBase64String:[Keychain stringForKey:PasswordHashKey]];
    
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
    NSData *md5 = [self.class md5:password];
    password = [md5 base64EncodedString];
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
      
      if ([TLDs containsObject:domain]) {
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

- (BOOL)savesHash {
  return [Keychain stringForKey:PasswordHashKey] != nil;
}

- (void)setSavesHash:(BOOL)savesHash {
  if (savesHash) {
    NSAssert((self.masterPassword != nil), @"master password must exist before hash can be saved");
    [Keychain setString:[self.hash base64EncodedString] forKey:PasswordHashKey];
  }
  else {
    [Keychain removeStringForKey:PasswordHashKey];
  }
}

- (BOOL)textMatchesHash:(NSString *)text {
  return [self.hash isEqualToData:[self.class sha256:text]];
}

- (void)updateMasterPassword:(NSString *)masterPassword {
  self.masterPassword = masterPassword;
  self.hash = [self.class sha256:masterPassword];
}

#pragma mark Private

- (BOOL)isValidPassword:(NSString *)password {
  NSRange range = NSMakeRange(0, password.length);
  
  return [self.lowerCasePattern rangeOfFirstMatchInString:password options:0 range:range].location == 0 &&
         [self.upperCasePattern numberOfMatchesInString:password options:0 range:range] != 0 &&
         [self.digitPattern numberOfMatchesInString:password options:0 range:range] != 0;
}

@end
