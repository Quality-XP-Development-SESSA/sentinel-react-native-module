#import <Foundation/Foundation.h>
#import "React/RCTBridgeModule.h"
#import "React/RCTEventEmitter.h"

@interface
RCT_EXTERN_MODULE(AuthModule, RCTEventEmitter);
RCT_EXTERN_METHOD(isLoggedIn: (RCTPromiseResolveBlock)resolve reject:(RCTPromiseRejectBlock)reject)
RCT_EXTERN_METHOD(signIn: (NSString*)username password:(NSString*)password resolve:(RCTPromiseResolveBlock)resolve reject:(RCTPromiseRejectBlock)reject)
// TODO: Enable Callback support later
//RCT_EXTERN_METHOD(signIn: (NSString*)username password:(NSString*)password failureCallback:(RCTResponseSenderBlock)failureCallback successCallback:(RCTResponseSenderBlock)successCallback)
RCT_EXTERN_METHOD(recoverPassword: (NSString)email resolve:(RCTPromiseResolveBlock)resolve reject:(RCTPromiseRejectBlock)reject)
//RCT_EXTERN_METHOD(recoverPassword: (NSString)email failureCallback:(RCTResponseSenderBlock)failureCallback successCallback:(RCTResponseSenderBlock)successCallback)
RCT_EXTERN_METHOD(signOut: (RCTPromiseResolveBlock)resolve reject:(RCTPromiseRejectBlock)reject)
//RCT_EXTERN_METHOD(signOut: (RCTResponseSenderBlock)failureCallback successCallback:(RCTResponseSenderBlock)successCallback)
RCT_EXTERN_METHOD(accountType:(RCTPromiseResolveBlock)resolve reject:(RCTPromiseRejectBlock)reject)

@end
