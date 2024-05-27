#import <SentinelSDK.h>
#import <shared/shared.h>

@implementation SentinelSDK

- (void)initKoin:(NSString *)host {
   SharedDatabaseDriverFactory *dbFactory = [[SharedDatabaseDriverFactory alloc] init];
   [SharedKoin.shared setupHost: host db:dbFactory];
}

@end
