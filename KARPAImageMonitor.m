#import "KARPAImageMonitor.h"
#import <mach-o/dyld.h>
#import <objc/runtime.h>
#import <os/lock.h>
static KARPAImageMonitor *gImageMonitor;
static void KARPAAddImage(const struct mach_header *h, intptr_t slide){dispatch_async(dispatch_get_main_queue(),^{NSString *p=@"<unknown>";if(gImageMonitor.imageChanged)gImageMonitor.imageChanged(p,YES);});}
@implementation KARPAImageMonitor
- (void)start{if(_running)return;_running=YES;gImageMonitor=self;_dyld_register_func_for_add_image(KARPAAddImage);}
- (void)stop{_running=NO;if(gImageMonitor==self)gImageMonitor=nil;}
@end
@interface KARPAClassMonitor(){dispatch_source_t _timer; NSSet *_previous;}@end
@implementation KARPAClassMonitor
- (instancetype)init{if((self=[super init]))_interval=5.0;return self;}
- (void)start{if(_running)return;_running=YES;_previous=[self current];_timer=dispatch_source_create(DISPATCH_SOURCE_TYPE_TIMER,0,0,dispatch_get_main_queue());dispatch_source_set_timer(_timer,dispatch_time(DISPATCH_TIME_NOW,(int64_t)(_interval*NSEC_PER_SEC)),(uint64_t)(_interval*NSEC_PER_SEC),NSEC_PER_SEC/10);__weak typeof(self) w=self;dispatch_source_set_event_handler(_timer,^{typeof(self)s=w;if(!s)return;NSSet *now=[s current];NSMutableSet *a=[now mutableCopy];[a minusSet:s->_previous];NSMutableSet *r=[s->_previous mutableCopy];[r minusSet:now];s->_previous=now;if((a.count||r.count)&&s.classesChanged)s.classesChanged(a,r);});dispatch_resume(_timer);}
- (NSSet *)current{int n=objc_getClassList(NULL,0);Class __unsafe_unretained *c=(Class __unsafe_unretained *)calloc((size_t)n,sizeof(Class));int got=objc_getClassList(c,n);NSMutableSet *s=[NSMutableSet set];for(int i=0;i<got;i++){NSString *x=NSStringFromClass(c[i]);if(x)[s addObject:x];}free(c);return s;}
- (void)stop{if(!_running)return;_running=NO;if(_timer){dispatch_source_cancel(_timer);_timer=nil;}}
@end
