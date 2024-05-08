#import <Foundation/Foundation.h>
#import "React/RCTBridgeModule.h"
#import "React/RCTEventEmitter.h"

@interface
RCT_EXTERN_MODULE(AppInfoModule, RCTEventEmitter);
RCT_EXTERN_METHOD(readInfo: (RCTPromiseResolveBlock)resolve reject:(RCTPromiseRejectBlock)reject)
@end