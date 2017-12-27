#include <CommonCrypto/CommonDigest.h>
#include <substrate.h>

unsigned char *(*old_CC_MD5)(const void *data, CC_LONG len, unsigned char *md);

unsigned char *new_CC_MD5(const void *data, CC_LONG len, unsigned char *md)
{
	NSData* sd = [NSData dataWithBytes:data length:len];
	unsigned char *r = old_CC_MD5(data, len, md);
	NSString* ss = [[NSString alloc] initWithData:sd encoding:NSUTF8StringEncoding];
	NSData* rd = [NSData dataWithBytes:md length:16];
	NSLog(@"CC_MD5: %@ | \" %@ \" = %@", sd, ss, rd);
	NSLog(@"hello world");
	return r;
}

unsigned char *(*old_CC_SHA1)(const void *data, CC_LONG len, unsigned char *md);

unsigned char *new_CC_SHA1(const void *data, CC_LONG len, unsigned char *md)
{
	NSData* sd = [NSData dataWithBytes:data length:len];
	unsigned char *r = old_CC_SHA1(data, len, md);
	NSString* ss = [[NSString alloc] initWithData:sd encoding:NSUTF8StringEncoding];
	NSData* rd = [NSData dataWithBytes:md length:20];
	NSLog(@"CC_SHA1: %@ | %@ = %@", sd, ss, rd);
	return r;
}

%ctor
{
	MSHookFunction(&CC_MD5, &new_CC_MD5, &old_CC_MD5);
	MSHookFunction(&CC_SHA1, &new_CC_SHA1, &old_CC_SHA1);
}
