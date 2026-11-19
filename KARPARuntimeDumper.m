#import "KARPARuntimeDumper.h"
#import "KARPAObjectiveCInspector.h"
#import "KARPAMachOInspector.h"
#import "KARPAMediaInvestigator.h"
#import "KARPAStorage.h"
#import "KARPADiagnostics.h"
#import "KARPACrossReference.h"
#import "KARPASwiftInspector.h"
NSString * const KARPAErrorDomain=@"com.example.authorized.KARPA";
@implementation KARPAOptions
+ (instancetype)defaultOptions{KARPAOptions *o=[self new];o.includeInheritedMethods=NO;o.mediaOnly=NO;o.includeMachOImages=YES;o.includeProtocols=YES;o.includeProperties=YES;o.includeIvars=YES;o.outputDirectory=@"";return o;}
- (id)copyWithZone:(NSZone *)z{KARPAOptions *o=[KARPAOptions new];o.includeInheritedMethods=_includeInheritedMethods;o.mediaOnly=_mediaOnly;o.includeMachOImages=_includeMachOImages;o.includeProtocols=_includeProtocols;o.includeProperties=_includeProperties;o.includeIvars=_includeIvars;o.outputDirectory=[_outputDirectory copy];return o;}
@end
NSDictionary *KARPACapabilities(void){return @{ @"version":@"0.1.0",@"publicObjectiveCRuntime":@YES,@"machOImages":@YES,@"mutation":@NO,@"network":@NO,@"automaticStart":@NO,@"note":@"Read-only collection for an authorized host process."};}
NSDictionary *KARPACollect(KARPAOptions *o,NSError **e){if(!o)o=[KARPAOptions defaultOptions]; NSDictionary *rt=KARPAInspectObjectiveCRuntime(o,e); if(!rt.count)return @{}; NSArray *im=o.includeMachOImages?KARPAInspectLoadedImages(e):@[]; return @{ @"schema":@"karpa.runtime.v2",@"capabilities":KARPACapabilities(),@"runtime":rt,@"images":im,@"media":KARPAInvestigateMedia(rt),@"crossReference":KARPABuildCrossReference(rt),@"swift":KARPAInspectSwiftImages(im),@"diagnostics":KARPADiagnosticsReport()};}
BOOL KARPACollectToDirectory(KARPAOptions *o,NSString *d,NSError **e){NSDictionary *r=KARPACollect(o,e);if(!r.count)return NO;return KARPAWriteReports(r,d,e);}
#if KARPA_AUTOSTART
__attribute__((constructor)) static void KARPAConstructor(void){ @autoreleasepool { NSString *dir=[NSTemporaryDirectory() stringByAppendingPathComponent:@"KARPA_DUMPS"]; KARPAOptions *o=[KARPAOptions defaultOptions]; o.outputDirectory=dir; KARPACollectToDirectory(o,dir,NULL); } }
#endif
