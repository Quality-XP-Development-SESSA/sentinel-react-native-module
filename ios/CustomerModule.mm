#import <Foundation/Foundation.h>
#import "React/RCTBridgeModule.h"
#import "React/RCTEventEmitter.h"

@interface
RCT_EXTERN_MODULE(CustomersModule, RCTEventEmitter);
RCT_EXTERN_METHOD(getCustomerList: (RCTPromiseResolveBlock)resolve reject:(RCTPromiseRejectBlock)reject)
RCT_EXTERN_METHOD(getFilterCustomerList: (NSString*)filterValue resolve:(RCTPromiseResolveBlock)resolve reject:(RCTPromiseRejectBlock)reject)
RCT_EXTERN_METHOD(refreshCustomers: (RCTPromiseResolveBlock)resolve reject:(RCTPromiseRejectBlock)reject)

@end