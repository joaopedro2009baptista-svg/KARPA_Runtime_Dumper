#import "KARPAMachOInspector.h"
#import <mach-o/dyld.h>
#import <mach-o/loader.h>
#import <mach-o/uuid.h>

static NSString *KHex(uint64_t x){ return [NSString stringWithFormat:@"0x%llx",x]; }
static NSString *KName(const char *p){ return p ? [NSString stringWithUTF8String:p] ?: @"<invalid-utf8>" : @"<null>"; }

NSArray<NSDictionary *> *KARPAInspectLoadedImages(NSError **error){
    NSMutableArray *result=[NSMutableArray array]; uint32_t count=_dyld_image_count();
    for(uint32_t i=0;i<count;i++){
        const struct mach_header *h=_dyld_get_image_header(i); if(!h) continue;
        const char *rawPath=_dyld_get_image_name(i); intptr_t slide=_dyld_get_image_vmaddr_slide(i);
        NSMutableDictionary *d=[@{ @"index":@(i), @"path":KName(rawPath), @"slide":@(slide), @"slideHex":KHex((uint64_t)slide), @"header":KHex((uint64_t)(uintptr_t)h), @"magic":KHex(h->magic), @"fileType":@(h->filetype), @"cpuType":@(h->cputype), @"cpuSubtype":@(h->cpusubtype) } mutableCopy];
        NSMutableArray *segments=[NSMutableArray array], *commands=[NSMutableArray array], *errors=[NSMutableArray array]; NSString *uuid=@"<unavailable>"; BOOL supported=NO;
        if(h->magic==MH_MAGIC_64){
            supported=YES; const struct mach_header_64 *m=(const struct mach_header_64 *)h; uint64_t available=m->sizeofcmds; uint64_t cursor=0; const uint8_t *base=(const uint8_t *)(m+1);
            if(available>64ULL*1024ULL*1024ULL) [errors addObject:@"sizeofcmds exceeds safety limit"];
            while(cursor<available && errors.count==0){ if(available-cursor<sizeof(struct load_command)){[errors addObject:@"truncated load command header"];break;} const struct load_command *lc=(const struct load_command *)(base+cursor); if(lc->cmdsize<sizeof(struct load_command)||lc->cmdsize>available-cursor){[errors addObject:@"invalid load command size"];break;} [commands addObject:@{ @"cmd":@(lc->cmd),@"cmdsize":@(lc->cmdsize) }];
                if(lc->cmd==LC_UUID && lc->cmdsize>=sizeof(struct uuid_command)){ const struct uuid_command *u=(const struct uuid_command *)lc; uuid=[[NSUUID alloc] initWithUUIDBytes:u->uuid].UUIDString.lowercaseString; }
                else if(lc->cmd==LC_UUID) [errors addObject:@"truncated LC_UUID"];
                else if(lc->cmd==LC_SEGMENT_64 && lc->cmdsize>=sizeof(struct segment_command_64)){ const struct segment_command_64 *s=(const struct segment_command_64 *)lc; NSMutableDictionary *sd=[@{ @"name":KName(s->segname),@"vmAddress":KHex(s->vmaddr),@"vmSize":KHex(s->vmsize),@"fileOffset":KHex(s->fileoff),@"fileSize":KHex(s->filesize),@"maxProt":@(s->maxprot),@"initProt":@(s->initprot),@"executable":@((s->initprot&VM_PROT_EXECUTE)!=0),@"writable":@((s->initprot&VM_PROT_WRITE)!=0) } mutableCopy]; NSMutableArray *sections=[NSMutableArray array]; uint64_t need=sizeof(struct segment_command_64)+(uint64_t)s->nsects*sizeof(struct section_64); if(need<=lc->cmdsize){const struct section_64 *sec=(const struct section_64 *)(s+1);for(uint32_t q=0;q<s->nsects;q++) [sections addObject:@{ @"name":KName(sec[q].sectname),@"segment":KName(sec[q].segname),@"address":KHex(sec[q].addr),@"size":KHex(sec[q].size),@"offset":KHex(sec[q].offset),@"flags":KHex(sec[q].flags) }];} else [errors addObject:@"truncated section list"]; sd[@"sections"]=sections; [segments addObject:sd]; }
                cursor+=lc->cmdsize;
            }
        } else { [errors addObject:@"Only little-endian 64-bit Mach-O parsing is implemented"]; }
        d[@"uuid"]=uuid; d[@"segments"]=segments; d[@"loadCommands"]=commands; d[@"parseStatus"]=errors.count?@"PARTIAL":(supported?@"PARSED":@"UNSUPPORTED"); d[@"errors"]=errors; [result addObject:d];
    }
    return result;
}
