import Foundation
import shared
import React

@objc(CustomersModule)
class CustomersModule: RCTEventEmitter {
  
  private let cloudProvider = SentinelProvider.shared.cloudProvider
  private let sessionProvider = SentinelProvider.shared.sessionProvider
  private var customersServices: CustomerServices
  
  override func supportedEvents() -> [String]! {
    return ["hasSession", "CustomerList"]
  }
  
  @objc
  override init () {
    self.customersServices = cloudProvider.customersCloudServices
    super.init()
    collectFlow()
    // TODO: comment this back in when we have access to the shared library.
    //            sessionProvider.hasActiveSession.collect {
    //                var event = Arguments.createMap()
    //                event.putBoolean("localSession", sessionProvider.hasActiveSession.value)
    //                sendEvent("hasSession", event)
    //            }
  }
  
  func collectFlow() {
    Task { @MainActor in
      do {
        let collector = FlowCollector<Customer> { result in
          print("Data collect: \(result)")
            
          switch result {
          case .success(let customers):
            do {
              if let customersArray = customers as? [Customer] {
                let customersDictionaryArray = customersArray.map { customer in
                  let customerDictionary: [String: Any] = [
                    "id": customer.id,
                    "name": customer.name,
                    "phone": customer.phone,
                    "status": customer.status,
                    "code": customer.code,
                    "email": customer.email,
                    "company": customer.company
                  ]
                  return customerDictionary
                }
                let jsonData = try JSONSerialization.data(withJSONObject: customersDictionaryArray, options: [])
                if let jsonString = String(data: jsonData, encoding: .utf8) {
                  self.sendEvent(withName: "CustomerList", body: ["data": jsonString])
                } else {
                  print("ERROR_JSON_ENCODING", "Failed to encode JSON")
                }
              } else {
                print("ERROR_INVALID_DATA", "Invalid data format for customer array")
              }
            } catch {
              print("Error encoding JSON: \(error)")
            }
          case .failure(let error):
            print("Error collecting flow: \(error)")
          }
        }
        self.customersServices.customers.collect(collector: collector) { error in
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
  func getCustomerList(_ resolve: @escaping RCTPromiseResolveBlock, reject: @escaping RCTPromiseRejectBlock) {
    Task { @MainActor in
      do {
        print("getCustomer::Promise")
        let customersResult = try await customersServices.getCustomerList()
        
        if (customersResult.success) {
          if let customersArray = customersResult.data as? [Customer] {
            let customersDictionaryArray = customersArray.map { customer in
              let customerDictionary: [String: Any] = [
                "id": customer.id,
                "name": customer.name,
                "phone": customer.phone,
                "status": customer.status,
                "code": customer.code,
                "email": customer.email,
                "company": customer.company
              ]
              return customerDictionary
            }
            let jsonData = try JSONSerialization.data(withJSONObject: customersDictionaryArray, options: [])
            if let jsonString = String(data: jsonData, encoding: .utf8) {
              resolve(jsonString)
            } else {
              reject("ERROR_JSON_ENCODING", "Failed to encode JSON", nil)
            }
          } else {
            reject("ERROR_INVALID_DATA", "Invalid data format for customer array", nil)
          }
        } else {
          let error = NSError(domain: "", code: customersResult.errorCode as? Int ?? 0, userInfo: ["${result.errorCode}": "${result.errorCode}"])
          reject("ERROR_CUSTOMERLIST", "There was an error customer list", error)
        }
        
      }
      catch {
        print("Request failed with Exception ${error.localizedDescription}")
        print(error)
        let error = NSError(domain: "", code: 0, userInfo: ["${0}": error.localizedDescription])
        reject("ERROR_CUSTOMERLIST", "Exception", error)
      }
    }
  }
  
  @objc
  func getCustomerList(_ failureCallback: @escaping RCTResponseSenderBlock, successCallback: @escaping RCTResponseSenderBlock) {
    print("getLocations::Callback")
    Task {
      do {
        let customersResult = try await customersServices.getCustomerList()
        
        if (customersResult.success) {
          if let customersArray = customersResult.data as? [Customer] {
            let customersDictionaryArray = customersArray.map { customer in
              let customerDictionary: [String: Any] = [
                "id": customer.id,
                "name": customer.name,
                "phone": customer.phone,
                "status": customer.status,
                "code": customer.code,
                "email": customer.email,
                "company": customer.company
              ]
              return customerDictionary
            }
            let jsonData = try JSONSerialization.data(withJSONObject: customersDictionaryArray, options: [])
            if let jsonString = String(data: jsonData, encoding: .utf8) {
              successCallback([jsonString])
            } else {
              failureCallback(["ERROR_JSON_ENCODING", "Failed to encode JSON", nil])
            }
          } else {
            failureCallback(["ERROR_INVALID_DATA", "Invalid data format for DeviceSensor array", nil])
          }
        } else {
          let error = NSError(domain: "", code: customersResult.errorCode as? Int ?? 0, userInfo: ["${result.errorCode}": "${result.errorCode}"])
          failureCallback(["ERROR_CUSTOMERLIST", "There was an error customer list", error])
        }
        
      }
      catch {
        print("Request failed with Exception ${error.localizedDescription}")
        print(error)
        let error = NSError(domain: "", code: 0, userInfo: ["${0}": error.localizedDescription])
        failureCallback(["ERROR_CUSTOMERLIST", "Exception", error])
      }
    }
  }
  
  @objc
  func getFilterCustomerList(_ filterValue: String, resolve: @escaping RCTPromiseResolveBlock, reject: @escaping RCTPromiseRejectBlock) {
    Task { @MainActor in
      do {
        print("filterCustomerList::Promise")
        let customersResult = try await customersServices.filterCustomerList(filterValue: filterValue)
        
        if (customersResult.success) {
          if let customersArray = customersResult.data as? [Customer] {
            let customersDictionaryArray = customersArray.map { customer in
              let customerDictionary: [String: Any] = [
                "id": customer.id,
                "name": customer.name,
                "phone": customer.phone,
                "status": customer.status,
                "code": customer.code,
                "email": customer.email,
                "company": customer.company
              ]
              return customerDictionary
            }
            let jsonData = try JSONSerialization.data(withJSONObject: customersDictionaryArray, options: [])
            if let jsonString = String(data: jsonData, encoding: .utf8) {
              resolve(jsonString)
            } else {
              reject("ERROR_JSON_ENCODING", "Failed to encode JSON", nil)
            }
          } else {
            reject("ERROR_INVALID_DATA", "Invalid data format for DeviceSensor array", nil)
          }
        } else {
          let error = NSError(domain: "", code: customersResult.errorCode as? Int ?? 0, userInfo: ["${result.errorCode}": "${result.errorCode}"])
          reject("ERROR_CUSTOMERFILTER", "There was an error customer filter", error)
        }
        
      }
      catch {
        print("Request failed with Exception ${error.localizedDescription}")
        print(error)
        let error = NSError(domain: "", code: 0, userInfo: ["${0}": error.localizedDescription])
        reject("ERROR_CUSTOMERFILTER", "Exception", error)
      }
    }
  }
  
  @objc
  func getFilterCustomerList(_ filterValue: String, failureCallback: @escaping RCTResponseSenderBlock, successCallback: @escaping RCTResponseSenderBlock) {
    print("getFilterLocationList::Callback")
    Task {
      do {
        let customersResult = try await customersServices.filterCustomerList(filterValue: filterValue)
        
        if (customersResult.success) {
          if let customersArray = customersResult.data as? [Customer] {
            let customersDictionaryArray = customersArray.map { customer in
              let customerDictionary: [String: Any] = [
                "id": customer.id,
                "name": customer.name,
                "phone": customer.phone,
                "status": customer.status,
                "code": customer.code,
                "email": customer.email,
                "company": customer.company
              ]
              return customerDictionary
            }
            let jsonData = try JSONSerialization.data(withJSONObject: customersDictionaryArray, options: [])
            if let jsonString = String(data: jsonData, encoding: .utf8) {
              successCallback([jsonString])
            } else {
              failureCallback(["ERROR_JSON_ENCODING", "Failed to encode JSON", nil])
            }
          } else {
            failureCallback(["ERROR_INVALID_DATA", "Invalid data format for DeviceSensor array", nil])
          }
        } else {
          let error = NSError(domain: "", code: customersResult.errorCode as? Int ?? 0, userInfo: ["${result.errorCode}": "${result.errorCode}"])
          failureCallback(["ERROR_CUSTOMERFILTER", "There was an error customer filter", error])
        }
        
      }
      catch {
        print("Request failed with Exception ${error.localizedDescription}")
        print(error)
        let error = NSError(domain: "", code: 0, userInfo: ["${0}": error.localizedDescription])
        failureCallback(["ERROR_CUSTOMERFILTER", "Exception", error])
      }
    }
  }
  
  @objc
  func refreshCustomers(_ resolve: @escaping RCTPromiseResolveBlock, reject: @escaping RCTPromiseRejectBlock){
    Task { @MainActor in
      do {
        print("refreshCustomers::Promise")
        try await customersServices.refreshCustomers()
      }
      catch {
        print("Request failed with Exception ${error.localizedDescription}")
        print(error)
        let error = NSError(domain: "", code: 0, userInfo: ["${0}": error.localizedDescription])
        reject("ERROR_CUSTOMERLIST", "Exception", error)
      }
    }
  }
  
  @objc
  func refreshCustomers(_ failureCallback: @escaping RCTResponseSenderBlock, successCallback: @escaping RCTResponseSenderBlock) {
    print("getFilterLocationList::Callback")
    Task {
      do {
        try await customersServices.refreshCustomers()
      }
      catch {
        print("Request failed with Exception ${error.localizedDescription}")
        print(error)
        let error = NSError(domain: "", code: 0, userInfo: ["${0}": error.localizedDescription])
        failureCallback(["ERROR_CUSTOMERFILTER", "Exception", error])
      }
    }
  }
}
