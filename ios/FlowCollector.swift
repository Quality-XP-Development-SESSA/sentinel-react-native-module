import Foundation
import React

class FlowCollector<T>: Kotlinx_coroutines_coreFlowCollector {
  let callback: (Result<[T], Error>) -> Void
  
  init(callback: @escaping (Result<[T], Error>) -> Void) {
    self.callback = callback
  }
  
  func emit(value: Any?, completionHandler: (Error?) -> Void) {
    if let items = value as? [T] {
      callback(.success(items))
    } else {
      callback(.failure(NSError(domain: "InvalidData", code: 0, userInfo: nil)))
    }
    completionHandler(nil)
  }
}