#import <Foundation/Foundation.h>
#import "React/RCTBridgeModule.h"
#import "React/RCTEventEmitter.h"

@interface
RCT_EXTERN_MODULE(LocationsModule, RCTEventEmitter);
RCT_EXTERN_METHOD(getLocations: (NSString*)customerId resolve:(RCTPromiseResolveBlock)resolve reject:(RCTPromiseRejectBlock)reject)
RCT_EXTERN_METHOD(getFilterLocationList: (NSString*)filterValue customerId:(NSString*)customerId resolve:(RCTPromiseResolveBlock)resolve reject:(RCTPromiseRejectBlock)reject)
RCT_EXTERN_METHOD(deleteLocation: (int)locationId transferLocationId:(NSString*)transferLocationId resolve:(RCTPromiseResolveBlock)resolve reject:(RCTPromiseRejectBlock)reject)
RCT_EXTERN_METHOD(getSensors: (NSString*)locationId filterValue:(NSString*)filterValue resolve:(RCTPromiseResolveBlock)resolve reject:(RCTPromiseRejectBlock)reject)
RCT_EXTERN_METHOD(getGateways: (NSString*)locationId filterValue:(NSString*)filterValue resolve:(RCTPromiseResolveBlock)resolve reject:(RCTPromiseRejectBlock)reject)
RCT_EXTERN_METHOD(addLocation: (NSString*)name description:(NSString*)description latitude:(double)latitude longitude:(double)longitude customerId:(int)customerId resolve:(RCTPromiseResolveBlock)resolve reject:(RCTPromiseRejectBlock)reject)
RCT_EXTERN_METHOD(refreshLocation: (NSString*)customerId resolve:(RCTPromiseResolveBlock)resolve reject:(RCTPromiseRejectBlock)reject)

@end