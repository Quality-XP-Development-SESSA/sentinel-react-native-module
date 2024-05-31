#import <Foundation/Foundation.h>
#import "React/RCTBridgeModule.h"
#import "React/RCTEventEmitter.h"

@interface
RCT_EXTERN_MODULE(FirmwareModule, RCTEventEmitter);
RCT_EXTERN_METHOD(updateFirmware: (NSString*)devices resolve: (RCTPromiseResolveBlock)resolve reject:(RCTPromiseRejectBlock)reject)

@end