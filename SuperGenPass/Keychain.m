//
// Keychain.h
//
// Based on code by Michael Mayo at http://overhrd.com/?p=208
//

#import "Keychain.h"
#import <Security/Security.h>

@implementation Keychain

+ (void)setString:(NSString *)inputString forKey:(NSString *)account {
	NSMutableDictionary *query = [NSMutableDictionary dictionary];
	
	[query setObject:(__bridge id)kSecClassGenericPassword forKey:(__bridge id)kSecClass];
	[query setObject:account forKey:(__bridge id)kSecAttrAccount];
	[query setObject:(__bridge id)kSecAttrAccessibleWhenUnlocked forKey:(__bridge id)kSecAttrAccessible];
	
	OSStatus status = SecItemCopyMatching((__bridge CFDictionaryRef)query, NULL);

	if (status == errSecSuccess) {
		NSDictionary *attributesToUpdate = [NSDictionary dictionaryWithObject:[inputString dataUsingEncoding:NSUTF8StringEncoding]
                                                                   forKey:(__bridge id)kSecValueData];
		
		status = SecItemUpdate((__bridge CFDictionaryRef)query, (__bridge CFDictionaryRef)attributesToUpdate);
		if (status != errSecSuccess) {
      NSLog(@"SecItemUpdate failed: %ld", status);
    }
	}
  else if (status == errSecItemNotFound) {
		[query setObject:[inputString dataUsingEncoding:NSUTF8StringEncoding] forKey:(__bridge id)kSecValueData];
		
		status = SecItemAdd((__bridge CFDictionaryRef)query, NULL);
		if (status != errSecSuccess) {
      NSLog(@"SecItemAdd failed: %ld", status);
    }
	}
  else {
		NSLog(@"SecItemCopyMatching failed: %ld", status);
	}
}

+ (NSString *)stringForKey:(NSString *)account {
	NSMutableDictionary *query = [NSMutableDictionary dictionary];

	[query setObject:(__bridge id)kSecClassGenericPassword forKey:(__bridge id)kSecClass];
	[query setObject:account forKey:(__bridge id)kSecAttrAccount];
	[query setObject:(id)kCFBooleanTrue forKey:(__bridge id)kSecReturnData];

	CFDataRef dataFromKeychain = NULL;
	NSString *string = nil;

	if (SecItemCopyMatching((__bridge CFDictionaryRef)query, (CFTypeRef *)&dataFromKeychain) == errSecSuccess) {
		string = [[NSString alloc] initWithData:(__bridge id)dataFromKeychain encoding:NSUTF8StringEncoding];
    CFRelease(dataFromKeychain);
	}
  
	return string;
}

+ (void)removeStringForKey:(NSString *)account {
	NSMutableDictionary *query = [NSMutableDictionary dictionary];
	
	[query setObject:(__bridge id)kSecClassGenericPassword forKey:(__bridge id)kSecClass];
	[query setObject:account forKey:(__bridge id)kSecAttrAccount];
		
	OSStatus status = SecItemDelete((__bridge CFDictionaryRef)query);
	if (status != errSecSuccess) {
		NSLog(@"SecItemDelete failed: %ld", status);
	}
}

@end