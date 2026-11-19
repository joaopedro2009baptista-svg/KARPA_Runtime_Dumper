#import <Foundation/Foundation.h>
NS_ASSUME_NONNULL_BEGIN
FOUNDATION_EXPORT NSDictionary *KARPAComputeRuntimeDiff(NSDictionary *before, NSDictionary *after);
FOUNDATION_EXPORT BOOL KARPAWriteRuntimeDiffFromFiles(NSString *beforePath, NSString *afterPath, NSString *outputPath, NSError * _Nullable * _Nullable error);
NS_ASSUME_NONNULL_END
