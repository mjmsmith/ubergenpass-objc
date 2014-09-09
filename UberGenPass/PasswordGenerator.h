//
//  PasswordGenerator.h
//  UberGenPass
//
//  Copyright (c) 2012 Camazotz Limited. All rights reserved.
//

typedef NS_ENUM(NSUInteger, PasswordType) {
  PasswordTypeMD5,
  PasswordTypeSHA,
};

@interface PasswordGenerator : NSObject
@property (assign, readonly, nonatomic) BOOL hasMasterPassword;
@property (copy, readonly, nonatomic) NSData *passwordHash;

+ (PasswordGenerator *)sharedGenerator;

- (NSString *)passwordForSite:(NSString *)site length:(NSUInteger)length type:(PasswordType)type;
- (NSString *)domainFromSite:(NSString *)site;

- (BOOL)setMasterPasswordForCurrentHash:(NSString *)masterPassword;
- (void)updateMasterPassword:(NSString *)masterPassword secretPassword:(NSString *)secretPassword;

- (BOOL)textMatchesHash:(NSString *)text;
@end
