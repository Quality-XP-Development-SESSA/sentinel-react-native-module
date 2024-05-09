import Foundation
import shared

@objc(LocationsModule)
class LocationsModule: RCTEventEmitter {
  
  private let cloudProvider = SentinelProvider.shared.cloudProvider
  private let sessionProvider = SentinelProvider.shared.sessionProvider
  private var locationsServices: LocationsServices
  
  override func supportedEvents() -> [String]! {
    return ["hasSession", "LocationList"]
  }
  
  @objc
  override init () {
    self.locationsServices = cloudProvider.locationsCloudServices
    super.init()
    collectFlow()
    // TODO: comment this back in when we have access to the shared library.
    //        sessionProvider.hasActiveSession.collect {
    //            var event = Arguments.createMap()
    //            event.putBoolean("localSession", sessionProvider.hasActiveSession.value)
    //            sendEvent("hasSession", event)
    //        }
  }
  
  func collectFlow() {
    Task { @MainActor in
      do {
        print("COLLECT DATA LOCATIONS")
        
        let collector = FlowCollector<Locations> { result in
          print("Data collect: \(result)")
          
          switch result {
          case .success(let locations):
            do {
              if let locationsArray = locations as? [Locations] {
                let locationsDictionaryArray = locationsArray.map { location in
                  let locationDictionary: [String: Any] = [
                    "id": location.id,
                    "name": location.name,
                    "description": location.description_,
                    "lat": location.lat,
                    "long": location.long_,
                    "customerId": location.customerId
                  ]
                  return locationDictionary
                }
                let jsonData = try JSONSerialization.data(withJSONObject: locationsDictionaryArray, options: [])
                if let jsonString = String(data: jsonData, encoding: .utf8) {
                  self.sendEvent(withName: "LocationList", body: ["data": jsonString])
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
        self.locationsServices.locations.collect(collector: collector) { error in
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
  func getLocations(_ customerId: String, resolve: @escaping RCTPromiseResolveBlock, reject: @escaping RCTPromiseRejectBlock) {
    Task { @MainActor in
      do {
        print("getLocations::Promise")
        let locationsResult = try await locationsServices.getLocation(customerId: customerId)
        
        if (locationsResult.success) {
          if let locationsArray = locationsResult.data as? [Locations] {
            let locationsDictionaryArray = locationsArray.map { location in
              let locationDictionary: [String: Any] = [
                "id": location.id,
                "name": location.name,
                "description": location.description_,
                "lat": location.lat,
                "long": location.long_,
                "customerId": location.customerId
              ]
              return locationDictionary
            }
            let jsonData = try JSONSerialization.data(withJSONObject: locationsDictionaryArray, options: [])
            if let jsonString = String(data: jsonData, encoding: .utf8) {
              resolve(jsonString)
            } else {
              reject("ERROR_JSON_ENCODING", "Failed to encode JSON", nil)
            }
          } else {
            reject("ERROR_INVALID_DATA", "Invalid data format for DeviceSensor array", nil)
          }
        } else {
          let error = NSError(domain: "", code: locationsResult.errorCode as? Int ?? 0, userInfo: ["${result.errorCode}": "${result.errorCode}"])
          reject("ERROR_SIGNIN", "There was an error sign in", error)
        }
        
      }
      catch {
        print("Request failed with Exception ${error.localizedDescription}")
        print(error)
        let error = NSError(domain: "", code: 0, userInfo: ["${0}": error.localizedDescription])
        reject("ERROR_SIGNIN", "Exception", error)
      }
    }
  }
  
  @objc
  func getLocations(_ customerId: String, failureCallback: @escaping RCTResponseSenderBlock, successCallback: @escaping RCTResponseSenderBlock) {
    print("getLocations::Callback")
    Task {
      do {
        let locationsResult = try await locationsServices.getLocation(customerId: customerId)
        
        if (locationsResult.success) {
          if let locationsArray = locationsResult.data as? [Locations] {
            let locationsDictionaryArray = locationsArray.map { location in
              let locationDictionary: [String: Any] = [
                "id": location.id,
                "name": location.name,
                "description": location.description_,
                "lat": location.lat,
                "long": location.long_,
                "customerId": location.customerId
              ]
              return locationDictionary
            }
            let jsonData = try JSONSerialization.data(withJSONObject: locationsDictionaryArray, options: [])
            if let jsonString = String(data: jsonData, encoding: .utf8) {
              successCallback([jsonString])
            } else {
              failureCallback(["ERROR_JSON_ENCODING", "Failed to encode JSON", nil])
            }
          } else {
            failureCallback(["ERROR_INVALID_DATA", "Invalid data format for DeviceSensor array", nil])
          }
        } else {
          let error = NSError(domain: "", code: locationsResult.errorCode as? Int ?? 0, userInfo: ["${result.errorCode}": "${result.errorCode}"])
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
  func getFilterLocationList(_ filterValue: String, customerId: String, resolve: @escaping RCTPromiseResolveBlock, reject: @escaping RCTPromiseRejectBlock) {
    Task { @MainActor in
      do {
        print("getFilterLocationList::Promise")
        let locationsResult = try await locationsServices.filterLocationList(filterValue: filterValue, customerId: customerId)
        
        if (locationsResult.success) {
          if let locationsArray = locationsResult.data as? [Locations] {
            let locationsDictionaryArray = locationsArray.map { location in
              let locationDictionary: [String: Any] = [
                "id": location.id,
                "name": location.name,
                "description": location.description_,
                "lat": location.lat,
                "long": location.long_,
                "customerId": location.customerId
              ]
              return locationDictionary
            }
            let jsonData = try JSONSerialization.data(withJSONObject: locationsDictionaryArray, options: [])
            if let jsonString = String(data: jsonData, encoding: .utf8) {
              resolve(jsonString)
            } else {
              reject("ERROR_JSON_ENCODING", "Failed to encode JSON", nil)
            }
          } else {
            reject("ERROR_INVALID_DATA", "Invalid data format for DeviceSensor array", nil)
          }
        } else {
          let error = NSError(domain: "", code: locationsResult.errorCode as? Int ?? 0, userInfo: ["${result.errorCode}": "${result.errorCode}"])
          reject("ERROR_SIGNIN", "There was an error sign in", error)
        }
        
      }
      catch {
        print("Request failed with Exception ${error.localizedDescription}")
        print(error)
        let error = NSError(domain: "", code: 0, userInfo: ["${0}": error.localizedDescription])
        reject("ERROR_SIGNIN", "Exception", error)
      }
    }
  }
  
  @objc
  func getFilterLocationList(_ filterValue: String, customerId: String, failureCallback: @escaping RCTResponseSenderBlock, successCallback: @escaping RCTResponseSenderBlock) {
    print("getFilterLocationList::Callback")
    Task {
      do {
        let locationsResult = try await locationsServices.filterLocationList(filterValue: filterValue, customerId: customerId)
        
        if (locationsResult.success) {
          if let locationsArray = locationsResult.data as? [Locations] {
            let locationsDictionaryArray = locationsArray.map { location in
              let locationDictionary: [String: Any] = [
                "id": location.id,
                "name": location.name,
                "description": location.description_,
                "lat": location.lat,
                "long": location.long_,
                "customerId": location.customerId
              ]
              return locationDictionary
            }
            let jsonData = try JSONSerialization.data(withJSONObject: locationsDictionaryArray, options: [])
            if let jsonString = String(data: jsonData, encoding: .utf8) {
              successCallback([jsonString])
            } else {
              failureCallback(["ERROR_JSON_ENCODING", "Failed to encode JSON", nil])
            }
          } else {
            failureCallback(["ERROR_INVALID_DATA", "Invalid data format for DeviceSensor array", nil])
          }
        } else {
          let error = NSError(domain: "", code: locationsResult.errorCode as? Int ?? 0, userInfo: ["${result.errorCode}": "${result.errorCode}"])
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
  func deleteLocation(_ locationId: Int, transferLocationId: String?, resolve: @escaping RCTPromiseResolveBlock, reject: @escaping RCTPromiseRejectBlock) {
    Task { @MainActor in
      do {
        print("deleteLocation::Promise")
        let deleteLocationResult = try await locationsServices.deleteLocation(id: Int32(exactly: locationId)!, targetLocation: transferLocationId)
        
        if (deleteLocationResult.success) {
          resolve(deleteLocationResult.data)
        } else {
          let error = NSError(domain: "", code: deleteLocationResult.errorCode as? Int ?? 0, userInfo: ["${result.errorCode}": deleteLocationResult.errorCode as Any])
          reject("ERROR_DELETELOCATION", "There was an error sign in", error)
        }
      }
      catch {
        print("Request failed with Exception ", error.localizedDescription)
        print(error)
        let error = NSError(domain: "", code: 0, userInfo: ["${0}": error.localizedDescription])
        reject("ERROR_DELETELOCATION", "Exception", error)
      }
    }
  }
  
  @objc
  func deleteLocation(_ locationId: Int, transferLocationId: String?, failureCallback: @escaping RCTResponseSenderBlock, successCallback: @escaping RCTResponseSenderBlock) {
    Task { @MainActor in
      do {
        print("deleteLocation::Callback")
        let deleteLocationResult = try await locationsServices.deleteLocation(id: Int32(exactly: locationId)!, targetLocation: transferLocationId)
        
        if (deleteLocationResult.success) {
          successCallback([deleteLocationResult.data])
        } else {
          let error = NSError(domain: "", code: deleteLocationResult.errorCode as? Int ?? 0, userInfo: ["${result.errorCode}": deleteLocationResult.errorCode as Any])
          failureCallback(["ERROR_DELETELOCATION", "There was an error sign in", error])
        }
      }
      catch {
        print("Request failed with Exception ", error.localizedDescription)
        print(error)
        let error = NSError(domain: "", code: 0, userInfo: ["${0}": error.localizedDescription])
        failureCallback(["ERROR_DELETELOCATION", "Exception", error])
      }
    }
  }
  
  @objc
  func getSensors(_ locationId: String, filterValue: String, resolve: @escaping RCTPromiseResolveBlock, reject: @escaping RCTPromiseRejectBlock) {
    Task { @MainActor in
      do {
        print("getSensors::Promise")
        let locationSensorsResult = try await locationsServices.getSensors(locationId: locationId, filter: filterValue)
        
        if (locationSensorsResult.success) {
          if let sensorsArray = locationSensorsResult.data as? [DeviceSensor] {
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
          let error = NSError(domain: "", code: Int(truncating: locationSensorsResult.errorCode ?? 0), userInfo: ["errorCode": "\(locationSensorsResult.errorCode ?? 0)"])
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
  func getSensors(_ locationId: String, filterValue: String, failureCallback: @escaping RCTResponseSenderBlock, successCallback: @escaping RCTResponseSenderBlock) {
    Task { @MainActor in
      do {
        print("getSensors::Callback")
        let locationSensorsResult = try await locationsServices.getSensors(locationId: locationId, filter: filterValue)
        
        if (locationSensorsResult.success) {
          if let sensorsArray = locationSensorsResult.data as? [DeviceSensor] {
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
              successCallback([jsonString])
            } else {
              failureCallback(["ERROR_JSON_ENCODING", "Failed to encode JSON", nil])
            }
          } else {
            failureCallback(["ERROR_INVALID_DATA", "Invalid data format for DeviceSensor array", nil])
          }
        } else {
          let error = NSError(domain: "", code: Int(truncating: locationSensorsResult.errorCode ?? 0), userInfo: ["errorCode": "\(locationSensorsResult.errorCode ?? 0)"])
          failureCallback(["ERROR_GETLOCATIONSENSORS", "There was an error signing in", error])
        }
      }
      catch {
        print("Request failed with Exception \(error.localizedDescription)")
        print(error)
        let error = NSError(domain: "", code: 0, userInfo: ["0": error.localizedDescription])
        failureCallback(["ERROR_GETLOCATIONSENSORS", "Exception", error])
      }
    }
  }
  
  @objc
  func getGateways(_ locationId: String, filterValue: String?, resolve: @escaping RCTPromiseResolveBlock, reject: @escaping RCTPromiseRejectBlock) {
    Task { @MainActor in
      do {
        print("getGateways::Promise")
        let gatewaysResult = try await locationsServices.getGateways(locationId: locationId, filter: filterValue)
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
  func getGateways(_ locationId: String, filterValue: String?, failureCallback: @escaping RCTResponseSenderBlock, successCallback: @escaping RCTResponseSenderBlock) {
    print("getGateways::Callback")
    Task {
      do {
        let gatewaysResult = try await locationsServices.getGateways(locationId: locationId, filter: filterValue)
        
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
  func addLocation(_ name: String, description: String, latitude: Double, longitude: Double, customerId: Int, resolve: @escaping RCTPromiseResolveBlock, reject: @escaping RCTPromiseRejectBlock) {
    Task { @MainActor in
      do {
        print("addLocation::Promise")
        let addLocationResponse = try await locationsServices.addLocation(location: LocationData(name: name, description: description, lat: latitude, long: longitude, customerId: KotlinInt(nonretainedObject: customerId)))
        
        if (addLocationResponse.success){
          if let location = addLocationResponse.data {
            let locationDictionary: [String: Any] = [
              "id": location.id,
              "name": location.name,
              "description": location.description_,
              "lat": location.lat,
              "long": location.long_,
              "customerId": location.customerId
            ]
            let jsonData = try JSONSerialization.data(withJSONObject: locationDictionary, options: [])
            if let jsonString = String(data: jsonData, encoding: .utf8) {
              resolve(jsonString)
            } else {
              reject("ERROR_JSON_ENCODING", "Failed to encode JSON", nil)
            }
          } else {
            reject("ERROR_INVALID_DATA", "Invalid data format for DeviceSensor array", nil)
          }
          
        } else {
          let error = NSError(domain: "", code: addLocationResponse.errorCode as? Int ?? 0, userInfo: ["${result.errorCode}": addLocationResponse.errorCode as Any])
          reject("ERROR_DELETELOCATION", "There was an error sign in", error)
        }
      }
      catch {
        print("Request failed with Exception \(error.localizedDescription)")
        print(error)
        let error = NSError(domain: "", code: 0, userInfo: ["0": error.localizedDescription])
        reject("ERROR_ADDLOCATION", "Exception", error)
      }
    }
  }
  
  @objc
  func refreshLocation(_ customerId: String?, resolve: @escaping RCTPromiseResolveBlock, reject: @escaping RCTPromiseRejectBlock) {
    Task { @MainActor in
      do {
        print("getGateways::Promise")
        try await locationsServices.refreshLocation(customerId: customerId)
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
  func refreshLocation(_ customerId: String?) {
    print("refreshLocation::Callback")
    Task {
      do {
        try await locationsServices.refreshLocation(customerId: customerId)
      }
      catch {
        print("Request failed with Exception ${error.localizedDescription}")
        print(error)
        let error = NSError(domain: "", code: 0, userInfo: ["${0}": error.localizedDescription])
      }
    }
  }
  
  override static func requiresMainQueueSetup() -> Bool {
    return true;
  }
}
