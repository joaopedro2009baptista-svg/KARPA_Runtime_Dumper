#import "KARPARuntimeDiff.h"

static NSDictionary *MapClasses(NSDictionary *report) {
    id value = report[@"classes"];
    NSArray *classes = [value isKindOfClass:NSArray.class] ? value : @[];
    NSMutableDictionary *map = [NSMutableDictionary dictionary];
    for (id object in classes) {
        if (![object isKindOfClass:NSDictionary.class]) continue;
        NSDictionary *classInfo = object;
        NSString *name = classInfo[@"name"];
        if (name.length > 0) map[name] = classInfo;
    }
    return map;
}

static NSDictionary *MapMethods(NSDictionary *classInfo) {
    NSArray *instance = [classInfo[@"methods"] isKindOfClass:NSArray.class] ? classInfo[@"methods"] : @[];
    NSArray *classMethods = [classInfo[@"classMethods"] isKindOfClass:NSArray.class] ? classInfo[@"classMethods"] : @[];
    NSMutableDictionary *map = [NSMutableDictionary dictionary];
    for (id object in [instance arrayByAddingObjectsFromArray:classMethods]) {
        if (![object isKindOfClass:NSDictionary.class]) continue;
        NSDictionary *method = object;
        NSString *key = [NSString stringWithFormat:@"%@|%@", method[@"kind"] ?: @"", method[@"selector"] ?: @""];
        map[key] = method;
    }
    return map;
}

static NSDictionary *MapNamed(NSArray *items, NSString *key) {
    NSMutableDictionary *map = [NSMutableDictionary dictionary];
    for (id object in items ?: @[]) {
        if (![object isKindOfClass:NSDictionary.class]) continue;
        id name = [object objectForKey:key];
        if (name) map[name] = object;
    }
    return map;
}

NSDictionary *KARPAComputeRuntimeDiff(NSDictionary *before, NSDictionary *after) {
    NSDictionary *beforeRuntime = [before[@"runtime"] isKindOfClass:NSDictionary.class] ? before[@"runtime"] : before;
    NSDictionary *afterRuntime = [after[@"runtime"] isKindOfClass:NSDictionary.class] ? after[@"runtime"] : after;
    NSDictionary *beforeClasses = MapClasses(beforeRuntime);
    NSDictionary *afterClasses = MapClasses(afterRuntime);
    NSMutableArray *added = [NSMutableArray array];
    NSMutableArray *removed = [NSMutableArray array];
    NSMutableArray *changes = [NSMutableArray array];

    for (NSString *name in afterClasses) if (!beforeClasses[name]) [added addObject:name];
    for (NSString *name in beforeClasses) if (!afterClasses[name]) [removed addObject:name];

    for (NSString *name in afterClasses) {
        NSDictionary *afterClass = afterClasses[name];
        NSDictionary *beforeClass = beforeClasses[name];
        if (!beforeClass) continue;
        id beforeSuperclass = beforeClass[@"superclass"] ?: [NSNull null];
        id afterSuperclass = afterClass[@"superclass"] ?: [NSNull null];
        if (![afterSuperclass isEqual:beforeSuperclass]) {
            [changes addObject:@{ @"class": name, @"field": @"superclass", @"before": beforeSuperclass, @"after": afterSuperclass }];
        }

        NSDictionary *afterMethods = MapMethods(afterClass);
        NSDictionary *beforeMethods = MapMethods(beforeClass);
        for (NSString *key in afterMethods) if (!beforeMethods[key]) {
            [changes addObject:@{ @"class": name, @"field": @"method-added", @"method": afterMethods[key] }];
        }
        for (NSString *key in beforeMethods) if (!afterMethods[key]) {
            [changes addObject:@{ @"class": name, @"field": @"method-removed", @"method": beforeMethods[key] }];
        }
        for (NSString *key in afterMethods) {
            NSDictionary *afterMethod = afterMethods[key];
            NSDictionary *beforeMethod = beforeMethods[key];
            if (!beforeMethod) continue;
            if (![afterMethod[@"imp"] isEqual:beforeMethod[@"imp"]]) {
                [changes addObject:@{ @"class": name, @"field": @"imp-changed", @"before": beforeMethod, @"after": afterMethod }];
            }
            if (![afterMethod[@"typeEncoding"] isEqual:beforeMethod[@"typeEncoding"]]) {
                [changes addObject:@{ @"class": name, @"field": @"encoding-changed", @"before": beforeMethod[@"typeEncoding"] ?: @"", @"after": afterMethod[@"typeEncoding"] ?: @"" }];
            }
        }

        if (![MapNamed(afterClass[@"properties"], @"name") isEqual:MapNamed(beforeClass[@"properties"], @"name")]) {
            [changes addObject:@{ @"class": name, @"field": @"properties-changed" }];
        }
        if (![afterClass[@"protocols"] isEqual:beforeClass[@"protocols"]]) {
            [changes addObject:@{ @"class": name, @"field": @"protocols-changed" }];
        }
    }
    return @{ @"schema": @"karpa.runtime-diff.v2", @"addedClasses": added, @"removedClasses": removed, @"changes": changes, @"status": @"observed-differences-only" };
}

BOOL KARPAWriteRuntimeDiffFromFiles(NSString *beforePath, NSString *afterPath, NSString *outputPath, NSError **error) {
    NSData *beforeData = [NSData dataWithContentsOfFile:beforePath];
    NSData *afterData = [NSData dataWithContentsOfFile:afterPath];
    if (!beforeData || !afterData) {
        if (error) *error = [NSError errorWithDomain:@"com.example.authorized.KARPA" code:10 userInfo:@{ NSLocalizedDescriptionKey: @"Unable to read one or both snapshot files" }];
        return NO;
    }
    NSError *parseError = nil;
    NSDictionary *before = [NSJSONSerialization JSONObjectWithData:beforeData options:0 error:&parseError];
    NSDictionary *after = [NSJSONSerialization JSONObjectWithData:afterData options:0 error:&parseError];
    if (![before isKindOfClass:NSDictionary.class] || ![after isKindOfClass:NSDictionary.class]) {
        if (error) *error = parseError;
        return NO;
    }
    NSData *output = [NSJSONSerialization dataWithJSONObject:KARPAComputeRuntimeDiff(before, after) options:NSJSONWritingPrettyPrinted error:&parseError];
    if (!output || ![output writeToFile:outputPath options:NSDataWritingAtomic error:&parseError]) {
        if (error) *error = parseError;
        return NO;
    }
    return YES;
}
