#import "KARPAObjectiveCInspector.h"
#import "KARPATypeEncodingParser.h"
#import <objc/runtime.h>
#import <dlfcn.h>

static NSString *KARPAHex(const void *p) { return p ? [NSString stringWithFormat:@"0x%llx", (unsigned long long)(uintptr_t)p] : @"0x0"; }
static NSDictionary *KARPAAddressInfo(const void *p) { Dl_info i={0}; if(!dladdr(p,&i)) return @{ @"resolutionStatus":@"UNRESOLVED",@"image":@"<unresolved>",@"pointerAuthentication":@"NOT_STRIPPED" }; NSMutableDictionary *d=[@{ @"resolutionStatus":@"RESOLVED",@"image":i.dli_fname?[NSString stringWithUTF8String:i.dli_fname]?:@"<invalid-utf8>":@"<unknown>",@"pointerAuthentication":@"NOT_STRIPPED" } mutableCopy]; uintptr_t a=(uintptr_t)p,b=(uintptr_t)i.dli_fbase; d[@"runtimeAddress"]=[NSString stringWithFormat:@"0x%llx",(unsigned long long)a]; d[@"imageBase"]=[NSString stringWithFormat:@"0x%llx",(unsigned long long)b]; d[@"imageRelativeAddress"]=[NSString stringWithFormat:@"0x%llx",(unsigned long long)(a-b)]; if(i.dli_sname)d[@"symbol"]= [NSString stringWithUTF8String:i.dli_sname]?:@"<invalid-utf8>"; if(i.dli_saddr)d[@"symbolAddress"]=[NSString stringWithFormat:@"0x%llx",(unsigned long long)(uintptr_t)i.dli_saddr]; return d; }
static NSDictionary *KARPAMethod(Method m, BOOL isClass, BOOL direct) {
    SEL s=method_getName(m); const char *te=method_getTypeEncoding(m); IMP imp=method_getImplementation(m);
    NSMutableDictionary *d=[@{ @"selector": NSStringFromSelector(s) ?: @"", @"kind": isClass?@"class":@"instance", @"direct": @(direct), @"typeEncoding": te?[NSString stringWithUTF8String:te]:@"", @"imp": KARPAHex((const void *)imp), @"encodingParsed": KARPAParseTypeEncoding(te?[NSString stringWithUTF8String:te]:@"") } mutableCopy]; [d addEntriesFromDictionary:KARPAAddressInfo((const void *)imp)]; return d;
}
static NSArray *KARPAMethodsForClass(Class cls, BOOL isClass, BOOL inherited) {
    unsigned int n=0; Method *list=class_copyMethodList(isClass?object_getClass(cls):cls,&n); NSMutableArray *a=[NSMutableArray arrayWithCapacity:n];
    for(unsigned int i=0;i<n;i++) [a addObject:KARPAMethod(list[i],isClass,!inherited)]; free(list);
    if(inherited){ Class sup=class_getSuperclass(cls); if(sup)[a addObjectsFromArray:KARPAMethodsForClass(sup,isClass,YES)]; }
    return a;
}
static NSArray *KARPAProperties(Class cls) { unsigned int n=0; objc_property_t *p=class_copyPropertyList(cls,&n); NSMutableArray *a=[NSMutableArray arrayWithCapacity:n]; for(unsigned int i=0;i<n;i++){ const char *name=property_getName(p[i]), *attrs=property_getAttributes(p[i]); [a addObject:@{ @"name":name?[NSString stringWithUTF8String:name]:@"", @"attributes":attrs?[NSString stringWithUTF8String:attrs]:@"" }]; } free(p); return a; }
static NSArray *KARPAIvars(Class cls) { unsigned int n=0; Ivar *v=class_copyIvarList(cls,&n); NSMutableArray *a=[NSMutableArray arrayWithCapacity:n]; for(unsigned int i=0;i<n;i++){ const char *name=ivar_getName(v[i]), *te=ivar_getTypeEncoding(v[i]); [a addObject:@{ @"name":name?[NSString stringWithUTF8String:name]:@"", @"typeEncoding":te?[NSString stringWithUTF8String:te]:@"", @"offset":@(ivar_getOffset(v[i])) }]; } free(v); return a; }
static NSDictionary *KARPAProtocolDetails(Protocol *p) {
    NSMutableDictionary *d=[NSMutableDictionary dictionary]; const char *name=protocol_getName(p); d[@"name"]=name?[NSString stringWithUTF8String:name]:@"";
    NSMutableArray *methods=[NSMutableArray array]; for(NSNumber *req in @[@YES,@NO]) for(NSNumber *inst in @[@YES,@NO]) { unsigned int n=0; struct objc_method_description *list=protocol_copyMethodDescriptionList(p,&n,req.boolValue,inst.boolValue); for(unsigned int i=0;i<n;i++){ if(list[i].name) [methods addObject:@{ @"selector":NSStringFromSelector(list[i].name),@"typeEncoding":list[i].types? [NSString stringWithUTF8String:list[i].types]:@"",@"required":req,@"instance":inst }]; } free(list); } d[@"methods"]=methods;
    unsigned int pn=0; objc_property_t *props=protocol_copyPropertyList(p,&pn); NSMutableArray *pa=[NSMutableArray array]; for(unsigned int i=0;i<pn;i++){ const char *n=property_getName(props[i]),*a=property_getAttributes(props[i]); [pa addObject:@{ @"name":n?[NSString stringWithUTF8String:n]:@"",@"attributes":a?[NSString stringWithUTF8String:a]:@"" }]; } free(props); d[@"properties"]=pa;
    unsigned int in=0; Protocol *__unsafe_unretained *parents=protocol_copyProtocolList(p,&in); NSMutableArray *sup=[NSMutableArray array]; for(unsigned int i=0;i<in;i++){const char *n=protocol_getName(parents[i]);if(n)[sup addObject:[NSString stringWithUTF8String:n]];} free(parents); d[@"inherits"]=sup; return d;
}
static NSArray *KARPAProtocols(Class cls) { unsigned int n=0; Protocol *__unsafe_unretained *p=class_copyProtocolList(cls,&n); NSMutableArray *a=[NSMutableArray arrayWithCapacity:n]; for(unsigned int i=0;i<n;i++) [a addObject:KARPAProtocolDetails(p[i])]; free(p); return a; }

NSDictionary *KARPAInspectObjectiveCRuntime(KARPAOptions *o, NSError **error) {
    int count=0, got=0; Class __unsafe_unretained *classes=NULL; for(int attempt=0;attempt<4;attempt++){ count=objc_getClassList(NULL,0); if(count<0)break; Class __unsafe_unretained *candidate=(Class __unsafe_unretained *)realloc(classes,(size_t)count*sizeof(Class)); if(!candidate){free(classes);classes=NULL;break;} classes=candidate; got=objc_getClassList(classes,count); if(got<=count)break; }
    if(!classes || got<0){ if(error)*error=[NSError errorWithDomain:KARPAErrorDomain code:1 userInfo:@{NSLocalizedDescriptionKey:@"objc_getClassList allocation or enumeration failed"}]; free(classes); return @{}; }
    if(got>count)got=count; NSMutableArray *out=[NSMutableArray arrayWithCapacity:got]; NSUInteger methodCount=0, propCount=0, ivarCount=0;
    for(int i=0;i<got;i++){ Class c=classes[i]; NSMutableDictionary *d=[NSMutableDictionary dictionary]; NSString *name=NSStringFromClass(c)?:@""; d[@"name"]=name; Class sup=class_getSuperclass(c); d[@"superclass"]=sup?NSStringFromClass(sup):[NSNull null]; d[@"metaclass"]=KARPAHex((__bridge const void *)object_getClass(c)); d[@"instanceSize"]=@(class_getInstanceSize(c)); const char *img=class_getImageName(c); d[@"image"]=img?[NSString stringWithUTF8String:img]:@"<unknown>";
        NSArray *im=KARPAMethodsForClass(c,NO,o.includeInheritedMethods); NSArray *cm=KARPAMethodsForClass(c,YES,o.includeInheritedMethods); methodCount+=im.count+cm.count; d[@"methods"]=im; d[@"classMethods"]=cm;
        if(o.includeProperties){ NSArray *p=KARPAProperties(c); propCount+=p.count; d[@"properties"]=p; } if(o.includeIvars){ NSArray *v=KARPAIvars(c); ivarCount+=v.count; d[@"ivars"]=v; } if(o.includeProtocols)d[@"protocols"]=KARPAProtocols(c);
        BOOL media=!o.mediaOnly; if(!media){ NSArray *terms=@[@"media",@"photo",@"video",@"image",@"audio",@"forward",@"download",@"library",@"player"]; NSString *low=name.lowercaseString; for(NSString *t in terms)if([low containsString:t]){media=YES;break;} if(!media){ for(NSDictionary *m in im)for(NSString *t in terms)if([[m[@"selector"] lowercaseString] containsString:t]){media=YES;break;} } }
        if(media)[out addObject:d];
    } free(classes); return @{ @"classes":out, @"classCountObserved":@(got), @"methodsObserved":@(methodCount), @"propertiesObserved":@(propCount), @"ivarsObserved":@(ivarCount), @"limitations":@[@"Direct runtime enumeration does not guarantee recovery of every category or Swift metadata.", @"IMP image ownership is resolved only when dladdr can identify it."] };
}
