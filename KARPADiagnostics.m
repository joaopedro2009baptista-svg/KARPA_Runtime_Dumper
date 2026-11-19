#import "KARPADiagnostics.h"
#import <UIKit/UIKit.h>
#include <TargetConditionals.h>
#include <sys/utsname.h>
NSDictionary *KARPADiagnosticsReport(void){struct utsname u;uname(&u);NSString *machine=[NSString stringWithUTF8String:u.machine];return @{ @"os":UIDevice.currentDevice.systemName?:@"unknown",@"osVersion":UIDevice.currentDevice.systemVersion?:@"unknown",@"deviceArchitecture":machine?:@"unknown",@"bundleIdentifier":NSBundle.mainBundle.bundleIdentifier?:@"unknown",@"sourceImplemented":@YES,@"compiled":@NO,@"unitTested":@NO,@"deviceTested":@NO,@"status":@"NOT_VERIFIED_IN_THIS_ENVIRONMENT",@"note":@"Build and device fields must be updated only after actual Xcode/device validation."};}
