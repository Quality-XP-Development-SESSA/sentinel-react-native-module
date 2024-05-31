import Foundation
import shared

@objc(AppInfoModule)
class AppInfoModule: RCTEventEmitter {
  
  @objc
  func readInfo(_ resolve: RCTPromiseResolveBlock, reject: RCTPromiseRejectBlock) {
    var info = [String: Any]()
    info["app_version"] = "\(Bundle.main.infoDictionary?["CFBundleShortVersionString"] ?? "")(\(Bundle.main.infoDictionary?["CFBundleVersion"] ?? ""))"
    info["sdk_version"] = "\(Bundle(identifier: "com.qxdev.sentinelSdk.shared")?.infoDictionary?["CFBundleVersion"] ?? "")"

    resolve(info)
  }

  override static func requiresMainQueueSetup() -> Bool {
    return true;
  }
}