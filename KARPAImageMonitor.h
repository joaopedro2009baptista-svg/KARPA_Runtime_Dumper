#import <Foundation/Foundation.h>
NS_ASSUME_NONNULL_BEGIN
@interface KARPAImageMonitor : NSObject
@property(nonatomic,readonly) BOOL running;
@property(nonatomic,copy,nullable) void (^imageChanged)(NSString *path, BOOL added);
- (void)start; - (void)stop;
@end
@interface KARPAClassMonitor : NSObject
@property(nonatomic,readonly) BOOL running;
@property(nonatomic) NSTimeInterval interval;
@property(nonatomic,copy,nullable) void (^classesChanged)(NSSet<NSString *> *added, NSSet<NSString *> *removed);
- (void)start; - (void)stop;
@end
NS_ASSUME_NONNULL_END
