#import <Foundation/Foundation.h>
NS_ASSUME_NONNULL_BEGIN
FOUNDATION_EXPORT BOOL KARPAAppendHistory(NSDictionary *report, NSString *directory, NSError * _Nullable * _Nullable error);
FOUNDATION_EXPORT NSArray<NSDictionary *> *KARPAReadHistory(NSString *directory, NSError * _Nullable * _Nullable error);
NS_ASSUME_NONNULL_END
