import Foundation
import shared

struct ResponseData: Codable {
    let devices: [String]
}

@objc(FirmwareModule)
class FirmwareModule: RCTEventEmitter {
    
    private let cloudProvider = SentinelProvider.shared.cloudProvider
    private let sessionProvider = SentinelProvider.shared.sessionProvider
    private var firmwareServices: FirmwareServices
    
    @objc
    override init () {
      self.firmwareServices = cloudProvider.firmwareCloudServices
      super.init()
    }
  
    @objc
  func updateFirmware(_ devices: String, resolve: @escaping RCTPromiseResolveBlock, reject: @escaping RCTPromiseRejectBlock) {
    Task { @MainActor in
      do {
        print("updateFirmware::Promise")
        let devicesArray = devices.split(separator: " ").compactMap { String($0) as NSString }
        let kotlinStringArray = KotlinArray(size: Int32(devicesArray.count)) { index in
            return devicesArray[Int(truncating: index)]
        }
        let response = try await firmwareServices.updateFirware(devices: kotlinStringArray)
        
        if (response.success) {
          let jsonData = response.data
          let responseData = try JSONSerialization.data(withJSONObject: jsonData as Any, options: [])
          if let jsonString = String(data: responseData, encoding: .utf8) {
            resolve(jsonString)
          } else {
            reject("ERROR_JSON_ENCODING", "Failed to encode JSON", nil)
          }
        } else {
          let error = NSError(domain: "", code: response.errorCode as? Int ?? 0, userInfo: ["${result.errorCode}": response.errorCode as Any])
          reject("ERROR_DELETESENSOR", "There was an error sign in", error)
        }
      }
      catch {
        print("Request failed with Exception ", error.localizedDescription)
        print(error)
        let error = NSError(domain: "", code: 0, userInfo: ["${0}": error.localizedDescription])
        reject("ERROR_DELETESENSOR", "Exception", error)
      }
    }
  }
  
  override static func requiresMainQueueSetup() -> Bool {
    return true;
  }
}