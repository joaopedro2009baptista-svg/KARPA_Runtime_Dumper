#import "KARPAStorage.h"
#import "KARPAExporter.h"
#import "KARPAZipExporter.h"
#import "KARPAHistory.h"

BOOL KARPAWriteReports(NSDictionary *r, NSString *dir, NSError **e) {
    if (![dir isKindOfClass:NSString.class] || dir.length == 0 || ![r isKindOfClass:NSDictionary.class]) {
        if (e) *e=[NSError errorWithDomain:@"com.example.authorized.KARPA" code:2 userInfo:@{NSLocalizedDescriptionKey:@"Invalid report or output directory"}];
        return NO;
    }
    NSFileManager *fm=NSFileManager.defaultManager;
    if (![fm createDirectoryAtPath:dir withIntermediateDirectories:YES attributes:nil error:e]) return NO;
    NSError *x=nil;
    NSData *j=[NSJSONSerialization dataWithJSONObject:r options:NSJSONWritingPrettyPrinted error:&x];
    if (!j || ![j writeToFile:[dir stringByAppendingPathComponent:@"runtime_dump.json"] options:NSDataWritingAtomic error:&x]) { if(e)*e=x; return NO; }
    NSDictionary *runtime=r[@"runtime"]?:@{};
    NSMutableString *t=[NSMutableString stringWithFormat:@"KARPA Runtime Dumper\nclasses=%@ methods=%@ properties=%@ ivars=%@\n",runtime[@"classCountObserved"]?:@0,runtime[@"methodsObserved"]?:@0,runtime[@"propertiesObserved"]?:@0,runtime[@"ivarsObserved"]?:@0];
    [t appendFormat:@"images=%@\nmediaClasses=%@\n",[r[@"images"] count],[r[@"media"][@"classes"] count]];
    if (![t writeToFile:[dir stringByAppendingPathComponent:@"runtime_dump.txt"] atomically:YES encoding:NSUTF8StringEncoding error:&x]) { if(e)*e=x; return NO; }
    NSDictionary *cov=@{ @"classCountObserved":runtime[@"classCountObserved"]?:@0, @"methodsObserved":runtime[@"methodsObserved"]?:@0, @"propertiesObserved":runtime[@"propertiesObserved"]?:@0, @"ivarsObserved":runtime[@"ivarsObserved"]?:@0, @"imagesInspected":@([r[@"images"] count]), @"limitations":runtime[@"limitations"]?:@[], @"diagnostics":r[@"diagnostics"]?:@{} };
    NSData *cd=[NSJSONSerialization dataWithJSONObject:cov options:NSJSONWritingPrettyPrinted error:&x];
    if (!cd || ![cd writeToFile:[dir stringByAppendingPathComponent:@"coverage_report.json"] options:NSDataWritingAtomic error:&x]) { if(e)*e=x; return NO; }
    NSDictionary *m=r[@"media"]?:@{}; NSData *md=[NSJSONSerialization dataWithJSONObject:m options:NSJSONWritingPrettyPrinted error:&x];
    if (!md || ![md writeToFile:[dir stringByAppendingPathComponent:@"media_investigation.json"] options:NSDataWritingAtomic error:&x]) { if(e)*e=x; return NO; }
    NSData *im=[NSJSONSerialization dataWithJSONObject:r[@"images"]?:@[] options:NSJSONWritingPrettyPrinted error:&x];
    if (!im || ![im writeToFile:[dir stringByAppendingPathComponent:@"mach_o_report.json"] options:NSDataWritingAtomic error:&x]) { if(e)*e=x; return NO; }
    NSData *cr=[NSJSONSerialization dataWithJSONObject:r[@"crossReference"]?:@{} options:NSJSONWritingPrettyPrinted error:&x];
    if (!cr || ![cr writeToFile:[dir stringByAppendingPathComponent:@"selector_index.json"] options:NSDataWritingAtomic error:&x]) { if(e)*e=x; return NO; }
    NSData *sw=[NSJSONSerialization dataWithJSONObject:r[@"swift"]?:@{} options:NSJSONWritingPrettyPrinted error:&x];
    if (!sw || ![sw writeToFile:[dir stringByAppendingPathComponent:@"swift_report.json"] options:NSDataWritingAtomic error:&x]) { if(e)*e=x; return NO; }
    if (!KARPAWriteCSVAndDependencyReport(r,dir,e)) return NO;
    if (!KARPAAppendHistory(r,dir,e)) return NO;
    return KARPAWriteZIPForDirectory(dir,[dir stringByAppendingPathComponent:@"KARPA_DUMPS.zip"],e);
}
