import Foundation
import shared

@objc(DevicesModule)
class DevicesModule: RCTEventEmitter {
  private let cloudProvider = SentinelProvider.shared.cloudProvider
  private let sessionProvider = SentinelProvider.shared.sessionProvider
  private var devicesServices: DeviceServices
  
  override func supportedEvents() -> [String]! {
    return ["hasSession", "GatewaysList", "SensorsList"]
  }

  @objc
  override init () {
    self.devicesServices = cloudProvider.devicesCloudServices
    super.init()
    collectFlowGateways()
    collectFlowSensors()
    // TODO: comment this back in when we have access to the shared library.
    //        sessionProvider.hasActiveSession.collect {
    //            var event = Arguments.createMap()
    //            event.putBoolean("localSession", sessionProvider.hasActiveSession.value)
    //            sendEvent("hasSession", event)
    //        }
  }

  func collectFlowGateways() {
    Task { @MainActor in
      do {
        print("COLLECT DATA GATEWAYS")
        
        let collector = FlowCollector<DeviceGateway> { result in
          print("Data collect: \(result)")
          
          switch result {
          case .success(let gateways):
            do {
              if let gatewaysArray = gateways as? [DeviceGateway] {
                let gatewaysDictionaryArray = gatewaysArray.map { gateway in
                  let gatewayDictionary: [String: Any] = [
                    "id": gateway.id,
                    "name": gateway.name,
                    "customerId": gateway.customerId,
                    "status": gateway.status,
                    "locationName": gateway.locationName,
                    "locationId": gateway.locationId,
                    "serialNumber": gateway.serialNumber,
                    "uuid": gateway.uuid,
                    "model": gateway.model,
                    "code": gateway.code
                  ]
                  return gatewayDictionary
                }
                
                let jsonData = try JSONSerialization.data(withJSONObject: gatewaysDictionaryArray, options: [])
                if let jsonString = String(data: jsonData, encoding: .utf8) {
                  self.sendEvent(withName: "GatewaysList", body: ["data": jsonString])
                } else {
                  print("ERROR_JSON_ENCODING", "Failed to encode JSON")
                }
              } else {
                print("ERROR_INVALID_DATA", "Invalid data format for DeviceSensor array")
              }
            } catch {
              print("Error enconding JSON: \(error)")
            }
          case .failure(let error):
            print("Error collecting flow: \(error)")
          }
        }
        self.devicesServices.gateways.collect(collector: collector) { error in
          if let error = error {
            print("Error collecting flow: \(error.localizedDescription)")
          } else {
            print("Flow collection completed successfully.")
          }
        }
      }
    }
  }
  
  func collectFlowSensors() {
    Task { @MainActor in
      do {
        print("COLLECT DATA SENSORS")
        
        let collector = FlowCollector<DeviceSensor> { result in
          print("Data collect: \(result)")
          
          switch result {
          case .success(let sensors):
            do {
              if let sensorsArray = sensors as? [DeviceSensor] {
                let sensorsDictionaryArray = sensorsArray.map { sensor in
                  let sensorDictionary: [String: Any] = [
                    "id": sensor.id,
                    "name": sensor.name,
                    "customerId": sensor.customerId,
                    "status": sensor.status,
                    "locationName": sensor.locationName,
                    "locationId": sensor.locationId,
                    "serialNumber": sensor.serialNumber,
                    "uuid": sensor.uuid,
                    "model": sensor.model,
                    "gatewayName": sensor.gatewayName ?? "",
                    "measureUnit": sensor.measureUnit,
                    "latestReport": [
                      "value": sensor.latestReport.value,
                      "date": sensor.latestReport.date
                    ],
                    "loraWanPendingStatus": sensor.loraWanPendingStatus
                  ]
                  return sensorDictionary
                }
                let jsonData = try JSONSerialization.data(withJSONObject: sensorsDictionaryArray, options: [])
                if let jsonString = String(data: jsonData, encoding: .utf8) {
                  self.sendEvent(withName: "SensorsList", body: ["data": jsonString])
                } else {
                  print("ERROR_JSON_ENCODING", "Failed to encode JSON")
                }
              } else {
                print("ERROR_INVALID_DATA", "Invalid data format for DeviceSensor array")
              }
            } catch {
              print("Error encoding JSON: \(error)")
            }
          case .failure(let error):
            print("Error collecting flow: \(error)")
          }
        }
        self.devicesServices.gateways.collect(collector: collector) { error in
          if let error = error {
            print("Error collecting flow: \(error.localizedDescription)")
          } else {
            print("Flow collection completed successfully.")
          }
        }
      }
    }
  }
    @objc
    func getSensors(_ filter: String?, resolve: @escaping RCTPromiseResolveBlock, reject: @escaping RCTPromiseRejectBlock) {
    Task { @MainActor in
      do {
        let sensorsResult = try await devicesServices.getSensors(filter: filter)
        if sensorsResult.success {
          if let sensorsArray = sensorsResult.data as? [DeviceSensor] {
            // Convert DeviceSensor objects to dictionaries
            let sensorsDictionaryArray = sensorsArray.map { sensor in
              var sensorDictionary: [String: Any] = [
                "id": sensor.id,
                "name": sensor.name,
                "customerId": sensor.customerId,
                "status": sensor.status,
                "locationName": sensor.locationName,
                "locationId": sensor.locationId,
                "serialNumber": sensor.serialNumber,
                "uuid": sensor.uuid,
                "model": sensor.model,
                "gatewayName": sensor.gatewayName ?? "",
                "measureUnit": sensor.measureUnit,
                "latestReport": [
                  "value": sensor.latestReport.value,
                  "date": sensor.latestReport.date
                ],
                "loraWanPendingStatus": sensor.loraWanPendingStatus
              ]
              return sensorDictionary
            }
            
            let jsonData = try JSONSerialization.data(withJSONObject: sensorsDictionaryArray, options: [])
            if let jsonString = String(data: jsonData, encoding: .utf8) {
              resolve(jsonString)
            } else {
              reject("ERROR_JSON_ENCODING", "Failed to encode JSON", nil)
            }
          } else {
            reject("ERROR_INVALID_DATA", "Invalid data format for DeviceSensor array", nil)
          }
        } else {
          let error = NSError(domain: "", code: Int(truncating: sensorsResult.errorCode ?? 0), userInfo: ["errorCode": "\(sensorsResult.errorCode ?? 0)"])
          reject("ERROR_SIGNIN", "There was an error signing in", error)
        }
      }
      catch {
        print("Request failed with Exception \(error.localizedDescription)")
        print(error)
        let error = NSError(domain: "", code: 0, userInfo: ["0": error.localizedDescription])
        reject("ERROR_SIGNIN", "Exception", error)
      }
    }
  }

  @objc
  func getSensors(_ filter: String?, failureCallback: @escaping RCTResponseSenderBlock, successCallback: @escaping RCTResponseSenderBlock) {
    print("getSensors::Callback")
    Task {
      do {
        let sensorsResult = try await devicesServices.getSensors(filter: filter)
        
        if (sensorsResult.success) {
          if let sensorsArray = sensorsResult.data as? [DeviceSensor] {
            // Convert DeviceSensor objects to dictionaries
            let sensorsDictionaryArray = sensorsArray.map { sensor in
              var sensorDictionary: [String: Any] = [
                "id": sensor.id,
                "name": sensor.name,
                "customerId": sensor.customerId,
                "status": sensor.status,
                "locationName": sensor.locationName,
                "locationId": sensor.locationId,
                "serialNumber": sensor.serialNumber,
                "uuid": sensor.uuid,
                "model": sensor.model,
                "firmwareVersion": sensor.firmwareVersion!,
                "firmwareUpdateStatus": sensor.firmwareUpdateStatus,
                "gatewayName": sensor.gatewayName ?? "",
                "measureUnit": sensor.measureUnit,
                "latestReport": [
                  "value": sensor.latestReport.value,
                  "date": sensor.latestReport.date
                ],
                "loraWanPendingStatus": sensor.loraWanPendingStatus,
                "attributes": sensor.attributes
              ]
              return sensorDictionary
            }
            
            let jsonData = try JSONSerialization.data(withJSONObject: sensorsDictionaryArray, options: [])
            if let jsonString = String(data: jsonData, encoding: .utf8) {
              successCallback([jsonString])
            } else {
              failureCallback(["ERROR_JSON_ENCODING", "Failed to encode JSON", nil])
            }
          } else {
            failureCallback(["ERROR_INVALID_DATA", "Invalid data format for DeviceSensor array", nil])
          }
        } else {
          let error = NSError(domain: "", code: sensorsResult.errorCode as? Int ?? 0, userInfo: ["${result.errorCode}": "${result.errorCode}"])
          failureCallback(["ERROR_SIGNIN", "There was an error sign in", error])
        }
      }
      catch {
        print("Request failed with Exception ${error.localizedDescription}")
        print(error)
        let error = NSError(domain: "", code: 0, userInfo: ["${0}": error.localizedDescription])
        failureCallback(["ERROR_SIGNIN", "Exception", error])
      }
    }
  }
  
  @objc
  func deleteSensors(_ ids: String, resolve: @escaping RCTPromiseResolveBlock, reject: @escaping RCTPromiseRejectBlock) {
    Task { @MainActor in
      do {
        let idsArray = ids.split(separator: " ").compactMap { Int($0) }
        // Convert Swift array to Kotlin array
        let kotlinIntArray = KotlinArray(size: Int32(idsArray.count)) { index in
          return KotlinInt(integerLiteral: idsArray[Int(truncating: index)])
        }
        print("deleteSensors::Promise")
        let deleteSensorsResult = try await devicesServices.deleteSensors(ids: kotlinIntArray)
        
        if (deleteSensorsResult.success) {
          resolve(deleteSensorsResult.data)
        } else {
          let error = NSError(domain: "", code: deleteSensorsResult.errorCode as? Int ?? 0, userInfo: ["${result.errorCode}": deleteSensorsResult.errorCode as Any])
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
  
  @objc
  func deleteSensors(_ ids: String, failureCallback: @escaping RCTResponseSenderBlock, successCallback: @escaping RCTResponseSenderBlock) {
    Task { @MainActor in
      do {
        let idsArray = ids.split(separator: " ").compactMap { Int($0) }
        // Convert Swift array to Kotlin array
        let kotlinIntArray = KotlinArray(size: Int32(idsArray.count)) { index in
          return KotlinInt(integerLiteral: idsArray[Int(truncating: index)])
        }
        print("deleteSensors::Callback")
        let deleteSensorsResult = try await devicesServices.deleteSensors(ids: kotlinIntArray)
        
        if (deleteSensorsResult.success) {
          successCallback([deleteSensorsResult.data])
        } else {
          let error = NSError(domain: "", code: deleteSensorsResult.errorCode as? Int ?? 0, userInfo: ["${result.errorCode}": deleteSensorsResult.errorCode as Any])
          failureCallback(["ERROR_DELETESENSOR", "There was an error sign in", error])
        }
      }
      catch {
        print("Request failed with Exception ", error.localizedDescription)
        print(error)
        let error = NSError(domain: "", code: 0, userInfo: ["${0}": error.localizedDescription])
        failureCallback(["ERROR_DELETESENSOR", "Exception", error])
      }
    }
  }
  
  @objc
  func editSensorName(_ id: String, name: String, resolve: @escaping RCTPromiseResolveBlock, reject: @escaping RCTPromiseRejectBlock) {
    Task { @MainActor in
      do {
        print("editSensorName::Promise")
        let editNameResult = try await devicesServices.editSensorName(id: Int32(id)!, name: name)
        
        if (editNameResult.success) {
          resolve(editNameResult.data)
        } else {
          let error = NSError(domain: "", code: editNameResult.errorCode as? Int ?? 0, userInfo: ["${result.errorCode}": editNameResult.errorCode as Any])
          reject("ERROR_EDITSENSOR", "There was an error sign in", error)
        }
      }
      catch {
        print("Request failed with Exception ", error.localizedDescription)
        print(error)
        let error = NSError(domain: "", code: 0, userInfo: ["${0}": error.localizedDescription])
        reject("ERROR_EDITSENSOR", "Exception", error)
      }
    }
  }
  
  @objc
  func editSensorName(_ id: String, name: String, failureCallback: @escaping RCTResponseSenderBlock, successCallback: @escaping RCTResponseSenderBlock) {
    Task { @MainActor in
      do {
        print("editSensorName::Promise")
        let editNameResult = try await devicesServices.editSensorName(id: Int32(id)!, name: name)
        
        if (editNameResult.success) {
          successCallback([editNameResult.data])
        } else {
          let error = NSError(domain: "", code: editNameResult.errorCode as? Int ?? 0, userInfo: ["${result.errorCode}": editNameResult.errorCode as Any])
          failureCallback(["ERROR_EDITSENSOR", "There was an error sign in", error])
        }
      }
      catch {
        print("Request failed with Exception ", error.localizedDescription)
        print(error)
        let error = NSError(domain: "", code: 0, userInfo: ["${0}": error.localizedDescription])
        failureCallback(["ERROR_EDITSENSOR", "Exception", error])
      }
    }
  }
  
  //GATEWAYS
  
  @objc
  func getGateways(_ filter: String?, resolve: @escaping RCTPromiseResolveBlock, reject: @escaping RCTPromiseRejectBlock) {
    Task { @MainActor in
      do {
        let gatewaysResult = try await devicesServices.getGateways(filter: filter)
        if gatewaysResult.success {
          if let gatewaysArray = gatewaysResult.data as? [DeviceGateway] {
            // Convert DeviceSensor objects to dictionaries
            let gatewaysDictionaryArray = gatewaysArray.map { gateway in
              var gatewayDictionary: [String: Any] = [
                "id": gateway.id,
                "name": gateway.name,
                "customerId": gateway.customerId,
                "status": gateway.status,
                "locationName": gateway.locationName,
                "locationId": gateway.locationId,
                "serialNumber": gateway.serialNumber,
                "uuid": gateway.uuid,
                "model": gateway.model,
                "firmwareVersion": gateway.firmwareVersion!,
                "firmwareUpdateStatus": gateway.firmwareUpdateStatus,
                "code": gateway.code
              ]
              return gatewayDictionary
            }
            
            let jsonData = try JSONSerialization.data(withJSONObject: gatewaysDictionaryArray, options: [])
            if let jsonString = String(data: jsonData, encoding: .utf8) {
              resolve(jsonString)
            } else {
              reject("ERROR_JSON_ENCODING", "Failed to encode JSON", nil)
            }
          } else {
            reject("ERROR_INVALID_DATA", "Invalid data format for DeviceSensor array", nil)
          }
        } else {
          let error = NSError(domain: "", code: Int(truncating: gatewaysResult.errorCode ?? 0), userInfo: ["errorCode": "\(gatewaysResult.errorCode ?? 0)"])
          reject("ERROR_SIGNIN", "There was an error signing in", error)
        }
      }
      catch {
        print("Request failed with Exception \(error.localizedDescription)")
        print(error)
        let error = NSError(domain: "", code: 0, userInfo: ["0": error.localizedDescription])
        reject("ERROR_SIGNIN", "Exception", error)
      }
    }
  }
  
  @objc
  func getGateways(_ filter: String?, failureCallback: @escaping RCTResponseSenderBlock, successCallback: @escaping RCTResponseSenderBlock) {
    print("getGateways::Callback")
    Task {
      do {
        let gatewaysResult = try await devicesServices.getGateways(filter: filter)
        
        if (gatewaysResult.success) {
          if let gatewaysArray = gatewaysResult.data as? [DeviceGateway] {
            // Convert DeviceSensor objects to dictionaries
            let gatewaysDictionaryArray = gatewaysArray.map { gateway in
              var gatewayDictionary: [String: Any] = [
                "id": gateway.id,
                "name": gateway.name,
                "customerId": gateway.customerId,
                "status": gateway.status,
                "locationName": gateway.locationName,
                "locationId": gateway.locationId,
                "serialNumber": gateway.serialNumber,
                "uuid": gateway.uuid,
                "model": gateway.model,
                "firmwareVersion": gateway.firmwareVersion!,
                "firmwareUpdateStatus": gateway.firmwareUpdateStatus,
                "code": gateway.code
              ]
              return gatewayDictionary
            }
            
            let jsonData = try JSONSerialization.data(withJSONObject: gatewaysDictionaryArray, options: [])
            if let jsonString = String(data: jsonData, encoding: .utf8) {
              successCallback([jsonString])
            } else {
              failureCallback(["ERROR_JSON_ENCODING", "Failed to encode JSON", nil])
            }
          } else {
            failureCallback(["ERROR_INVALID_DATA", "Invalid data format for DeviceSensor array", nil])
          }
        } else {
          let error = NSError(domain: "", code: gatewaysResult.errorCode as? Int ?? 0, userInfo: ["${result.errorCode}": "${result.errorCode}"])
          failureCallback(["ERROR_SIGNIN", "There was an error sign in", error])
        }
      }
      catch {
        print("Request failed with Exception ${error.localizedDescription}")
        print(error)
        let error = NSError(domain: "", code: 0, userInfo: ["${0}": error.localizedDescription])
        failureCallback(["ERROR_SIGNIN", "Exception", error])
      }
    }
  }
  
  @objc
  func deleteGateway(_ id: String, resolve: @escaping RCTPromiseResolveBlock, reject: @escaping RCTPromiseRejectBlock) {
    Task { @MainActor in
      do {
        print("deleteGateway::Promise")
        let deleteGatewayResult = try await devicesServices.deleteGateway(id: Int32(id)!)
        
        if (deleteGatewayResult.success) {
          resolve(deleteGatewayResult.data)
        } else {
          let error = NSError(domain: "", code: deleteGatewayResult.errorCode as? Int ?? 0, userInfo: ["${result.errorCode}": deleteGatewayResult.errorCode as Any])
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
  
  @objc
  func deleteGateway(_ id: String, failureCallback: @escaping RCTResponseSenderBlock, successCallback: @escaping RCTResponseSenderBlock) {
    Task { @MainActor in
      do {
        print("deleteGateway::Callback")
        let deleteGatewayResult = try await devicesServices.deleteGateway(id: Int32(id)!)
        
        if (deleteGatewayResult.success) {
          successCallback([deleteGatewayResult.data])
        } else {
          let error = NSError(domain: "", code: deleteGatewayResult.errorCode as? Int ?? 0, userInfo: ["${result.errorCode}": deleteGatewayResult.errorCode as Any])
          failureCallback(["ERROR_DELETESENSOR", "There was an error sign in", error])
        }
      }
      catch {
        print("Request failed with Exception ", error.localizedDescription)
        print(error)
        let error = NSError(domain: "", code: 0, userInfo: ["${0}": error.localizedDescription])
        failureCallback(["ERROR_DELETESENSOR", "Exception", error])
      }
    }
  }
  
  @objc
  func editGatewayName(_ id: String, name: String, resolve: @escaping RCTPromiseResolveBlock, reject: @escaping RCTPromiseRejectBlock) {
    Task { @MainActor in
      do {
        print("editSensorName::Promise")
        let editNameResult = try await devicesServices.editGateways(id: Int32(id)!, name: name)
        
        if (editNameResult.success) {
          resolve(editNameResult.data)
        } else {
          let error = NSError(domain: "", code: editNameResult.errorCode as? Int ?? 0, userInfo: ["${result.errorCode}": editNameResult.errorCode as Any])
          reject("ERROR_EDITSENSOR", "There was an error sign in", error)
        }
      }
      catch {
        print("Request failed with Exception ", error.localizedDescription)
        print(error)
        let error = NSError(domain: "", code: 0, userInfo: ["${0}": error.localizedDescription])
        reject("ERROR_EDITSENSOR", "Exception", error)
      }
    }
  }
  
  @objc
  func editGatewayName(_ id: String, name: String, failureCallback: @escaping RCTResponseSenderBlock, successCallback: @escaping RCTResponseSenderBlock) {
    Task { @MainActor in
      do {
        print("editSensorName::Promise")
        let editNameResult = try await devicesServices.editGateways(id: Int32(id)!, name: name)
        
        if (editNameResult.success) {
          successCallback([editNameResult.data as Any])
        } else {
          let error = NSError(domain: "", code: editNameResult.errorCode as? Int ?? 0, userInfo: ["${result.errorCode}": editNameResult.errorCode as Any])
          failureCallback(["ERROR_EDITSENSOR", "There was an error sign in", error])
        }
      }
      catch {
        print("Request failed with Exception ", error.localizedDescription)
        print(error)
        let error = NSError(domain: "", code: 0, userInfo: ["${0}": error.localizedDescription])
        failureCallback(["ERROR_EDITSENSOR", "Exception", error])
      }
    }
  }
  
  @objc
  func refreshGateways(_ filter: String?, resolve: @escaping RCTPromiseResolveBlock, reject: @escaping RCTPromiseRejectBlock) {
    Task { @MainActor in
      do {
        print("refreshGateways::Promise")
        try await devicesServices.refreshGateways(filter: filter)
      }
      catch {
        print("Request failed with Exception ", error.localizedDescription)
        print(error)
        let error = NSError(domain: "", code: 0, userInfo: ["${0}": error.localizedDescription])
        reject("ERROR_EDITSENSOR", "Exception", error)
      }
    }
  }
  
  @objc
  func refreshGateways(_ filter: String?, failureCallback: @escaping RCTResponseSenderBlock, successCallback: @escaping RCTResponseSenderBlock) {
    Task { @MainActor in
      do {
        print("refreshGateways::Callback")
        try await devicesServices.refreshGateways(filter: filter)
      }
      catch {
        print("Request failed with Exception ", error.localizedDescription)
        print(error)
        let error = NSError(domain: "", code: 0, userInfo: ["${0}": error.localizedDescription])
        failureCallback(["ERROR_EDITSENSOR", "Exception", error])
      }
    }
  }
  
  @objc
  func refreshSensors(_ filter: String?, resolve: @escaping RCTPromiseResolveBlock, reject: @escaping RCTPromiseRejectBlock) {
    Task { @MainActor in
      do {
        print("refreshSensors::Promise")
        try await devicesServices.refreshSensors(filter: filter)
      }
      catch {
        print("Request failed with Exception ", error.localizedDescription)
        print(error)
        let error = NSError(domain: "", code: 0, userInfo: ["${0}": error.localizedDescription])
        reject("ERROR_EDITSENSOR", "Exception", error)
      }
    }
  }
  
  @objc
  func refreshSensors(_ filter: String?, failureCallback: @escaping RCTResponseSenderBlock, successCallback: @escaping RCTResponseSenderBlock) {
    Task { @MainActor in
      do {
        print("refreshSensors::Callback")
        try await devicesServices.refreshSensors(filter: filter)
      }
      catch {
        print("Request failed with Exception ", error.localizedDescription)
        print(error)
        let error = NSError(domain: "", code: 0, userInfo: ["${0}": error.localizedDescription])
        failureCallback(["ERROR_EDITSENSOR", "Exception", error])
      }
    }
  }

  override static func requiresMainQueueSetup() -> Bool {
    return true;
  }

}