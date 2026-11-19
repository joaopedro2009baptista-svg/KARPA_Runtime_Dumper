#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

FOUNDATION_EXPORT NSString * const KARPAErrorDomain;

/// Options are intentionally explicit. No collection starts automatically unless KARPA_AUTOSTART is defined.
@interface KARPAOptions : NSObject <NSCopying>
@property(nonatomic) BOOL includeInheritedMethods;
@property(nonatomic) BOOL mediaOnly;
@property(nonatomic) BOOL includeMachOImages;
@property(nonatomic) BOOL includeProtocols;
@property(nonatomic) BOOL includeProperties;
@property(nonatomic) BOOL includeIvars;
@property(nonatomic, copy) NSString *outputDirectory;
+ (instancetype)defaultOptions;
@end

/// Collects metadata from the current, authorized host process and writes local reports.
/// This API does not modify classes, methods, executable memory, or application data.
FOUNDATION_EXPORT NSDictionary *KARPACollect(KARPAOptions *options, NSError * _Nullable * _Nullable error);
FOUNDATION_EXPORT BOOL KARPACollectToDirectory(KARPAOptions *options, NSString *directory, NSError * _Nullable * _Nullable error);

/// Returns the library version and build-time feature flags.
FOUNDATION_EXPORT NSDictionary *KARPACapabilities(void);

NS_ASSUME_NONNULL_END
