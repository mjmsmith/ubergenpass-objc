//
// Keychain.h
//
// Based on code by Michael Mayo at http://overhrd.com/?p=208
//

@interface Keychain : NSObject
+ (void)setString:(NSString *)string forKey:(NSString	*)account;
+ (NSString *)stringForKey:(NSString *)account;
+ (void)removeStringForKey:(NSString *)account;
@end