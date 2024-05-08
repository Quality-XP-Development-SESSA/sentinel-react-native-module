#import <Foundation/Foundation.h>
#import "React/RCTBridgeModule.h"
#import "React/RCTEventEmitter.h"

@interface
RCT_EXTERN_MODULE(DevicesModule, RCTEventEmitter);
RCT_EXTERN_METHOD(getSensors: (NSString*)filter resolve: (RCTPromiseResolveBlock)resolve reject:(RCTPromiseRejectBlock)reject)
RCT_EXTERN_METHOD(getGateways: (NSString*)filter resolve: (RCTPromiseResolveBlock)resolve reject:(RCTPromiseRejectBlock)reject)
RCT_EXTERN_METHOD(deleteSensors: (NSString*)ids resolve: (RCTPromiseResolveBlock)resolve reject:(RCTPromiseRejectBlock)reject)
RCT_EXTERN_METHOD(deleteGateway: (NSString*)id resolve: (RCTPromiseResolveBlock)resolve reject:(RCTPromiseRejectBlock)reject)
RCT_EXTERN_METHOD(editSensorName: (NSString*)id name:(NSString*)name resolve: (RCTPromiseResolveBlock)resolve reject:(RCTPromiseRejectBlock)reject)
RCT_EXTERN_METHOD(editGatewayName: (NSString*)id name:(NSString*)name resolve: (RCTPromiseResolveBlock)resolve reject:(RCTPromiseRejectBlock)reject)
RCT_EXTERN_METHOD(refreshSensors: (NSString*)filter resolve: (RCTPromiseResolveBlock)resolve reject:(RCTPromiseRejectBlock)reject)
RCT_EXTERN_METHOD(refreshGateways: (NSString*)filter resolve: (RCTPromiseResolveBlock)resolve reject:(RCTPromiseRejectBlock)reject)

@end
