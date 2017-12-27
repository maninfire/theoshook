#include <dlfcn.h>
#include <string>
#include <substrate.h>
#include <mach-o/dyld.h>
#import "MIHConversion.h"
#import "UserConnection.h"
#import "ConnectionManager.h"

int (*old_1009d3998)(int);

int sub_1009d3998(int index)
{
	int i = old_1009d3998(index);
	NSLog(@"sub_1009d3998: %d = %d", index, i);
	return i;
}

int	(*old_RSA_public_encrypt)(int flen, const unsigned char *from, unsigned char *to, void *rsa,int padding);

int	RSA_public_encrypt(int flen, const unsigned char *from, unsigned char *to, void *rsa,int padding)
{
	NSData* in = [NSData dataWithBytes:from length:flen];
	int r = old_RSA_public_encrypt(flen, from, to, rsa, padding);
	NSData* out = [NSData dataWithBytes:to length:r];
	NSLog(@"RSA_public_encrypt: %@|%d|%d = %@", in, flen, padding, out);
	return r;
}

int (*old_1009d35e8)(std::string* in, void* out);

int sub_1009d35e8(std::string* in, void* out)
{
	NSLog(@"sub_1009d35e8: %s", in->c_str());
	return old_1009d35e8(in, out);
}

%ctor
{
	intptr_t offset = _dyld_get_image_vmaddr_slide(0);
	void* sub = (void*)(offset + 0x1009d3998);
	//NSLog(@"sub_1009d3998: %p", sub);
	//MSHookFunction(sub, (void*)&sub_1009d3998, (void**)&old_1009d3998);

	sub = (void*)(offset + 0x100faaa40);
	NSLog(@"RSA_public_encrypt: %p", sub);
	MSHookFunction(sub, (void*)&RSA_public_encrypt, (void**)&old_RSA_public_encrypt);

	// sub = (void*)(offset + 0x1009d35e8);
	// NSLog(@"sub_1009d35e8: %p", sub);
	// MSHookFunction(sub, (void*)&sub_1009d35e8, (void**)&old_1009d35e8);
}

%hook IGPaymentViewController

- (_Bool)isJailBreak
{
	NSLog(@"IGPaymentViewController->isJailBreak");
	return NO;
}

%end

%hook IKCrackTool

+ (_Bool)isJailBreak
{
	NSLog(@"IKCrackTool->isJailBreak");
	return NO;
}

%end

%hook BLYDevice

+ (_Bool)isJailBreak
{
	NSLog(@"BLYDevice->isJailBreak");
	return NO;
}

%end

%hook GXPhoneUtils

+ (id)retriveIsJailbreak
{
	NSLog(@"GXPhoneUtils->retriveIsJailbreak");
	return @"";
}

%end

%hook IKSecurityTool

+ (void)checkCydia:(void (^)(id))arg1
{
	NSLog(@"IKSecurityTool->checkCydia");
	arg1(@"2");
}

%end

%hook IKSecurityTool

+ (id)md5Encrypt:(id)arg1
{
	id r = %orig;
	NSLog(@"wnxd text: %@", arg1);
	NSLog(@"wnxd md5: %@", r);
	return r;
}

+ (long long)getRSAPublicKeyId
{
	long long r = %orig;
	NSLog(@"wnxd RSA PublicKeyId: %lld", r);
	return r;
}

%end

%hook MIHRSAPublicKey

- (id)initWithData:(id)arg1
{
	NSLog(@"wnxd RSA PublicKey: %@|%@", [arg1 MIH_hexadecimalString], [arg1 MIH_base64EncodedStringWithWrapWidth:64]);
	return %orig;
}

- (id)encrypt:(id)arg1 error:(id *)arg2
{
	NSLog(@"wnxd RSA Data: %@", [arg1 MIH_hexadecimalString]);
	id r = %orig;
	NSLog(@"wnxd RSA Result: %@|%@", r, [r MIH_hexadecimalString]);
	return r;
}

%end

%hook SocketSecurityTool

+ (id)rc4_decode:(id)arg1 withKey:(id)arg2
{
	id r = %orig;
	NSLog(@"wnxd SocketSecurityTool rc4_decode: %@|%@ = %@", arg1, arg2, r);
	return r;
}

%end

%hook EncryWrapper

- (id)keyForIndex:(long long)arg1
{
	id r = %orig;
	NSLog(@"keyForIndex %lld = %@", arg1, r);
	return r;
}

%end

%hook ConnectionManager

- (void)enterRoom:(id)arg1 slot:(long long)arg2
{
	NSLog(@"wnxd ConnectionManager enterRoom: %@|%lld", arg1, arg2);
	%orig;
}

- (void)sendHeartbeat
{
	NSLog(@"wnxd ConnectionManager userConnetion: %@", self.userConnetion);
	NSLog(@"wnxd ConnectionManager sendHeartbeat");
	%orig;
}

- (void)sendMessage:(long long)arg1 dict:(id)arg2 completion:(void (^)(void))arg3
{
	NSLog(@"wnxd ConnectionManager sendMessage: %lld|%@|%@", arg1, arg2, arg3);
	%orig;
}

%end

%hook UserConnection

- (void)setHostArr:(id)hostArr
{
	NSLog(@"wnxd UserConnection setHostArr: %@", hostArr);
	%orig;
}

- (void)setHostAddr:(id)hostAddr
{
	NSLog(@"wnxd UserConnection setHostAddr: %@", hostAddr);
	%orig;
}

%end

%hook SocketConnector

- (void)socket:(id)arg1 didConnectToHost:(id)arg2 port:(unsigned short)arg3
{
	NSLog(@"wnxd SocketConnector socket: %@ -> %@|%@|%d", self, arg1, arg2, arg3);
	%orig;
}

- (void)sendMessage:(id)arg1
{
	NSLog(@"wnxd SocketConnector sendMessage: %@ -> %@", self, arg1);
	%orig;
}

- (void)connectToHost:(id)arg1 onPort:(long long)arg2 withConnectionTimeout:(double)arg3
{
	NSLog(@"wnxd SocketConnector connectToHost: %@ -> %@|%lld|%f", self, arg1, arg2, arg3);
	%orig;
}

%end
