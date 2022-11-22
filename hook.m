

#import "hook.h"
#import <UIKit/UIKit.h>
#import <objc/runtime.h>
#include <sys/stat.h>
#include <stdlib.h>
#import <Foundation/NSObject.h>
//#import "CaptainHook.h"

@implementation NSURL (hook)
+(void)load
{
    Method one = class_getClassMethod([self class], @selector(URLWithString:));
    Method one1 = class_getClassMethod([self class], @selector(hook_URLWithString:));
    method_exchangeImplementations(one, one1);
}

+(instancetype)hook_URLWithString:(NSString *)Str
{
    if ([Str containsString:@"icloud.com"]) {
        return [NSURL hook_URLWithString:@""];
        
    }else {
        return [NSURL hook_URLWithString:Str];
    }
}

@end

