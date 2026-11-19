#import "KARPARuntimeDumper.h"

/// Call this from an app-owned debug screen or test harness, never from an unknown host.
void KARPARunAuthorizedDebugCollection(NSString *documentsDirectory) {
    KARPAOptions *o=[KARPAOptions defaultOptions];
    o.mediaOnly=YES;
    o.includeInheritedMethods=YES;
    o.outputDirectory=[documentsDirectory stringByAppendingPathComponent:@"KARPA_DUMPS"];
    NSError *error=nil;
    if(!KARPACollectToDirectory(o,o.outputDirectory,&error)){
        NSLog(@"KARPA collection failed: %@",error);
    }
}
