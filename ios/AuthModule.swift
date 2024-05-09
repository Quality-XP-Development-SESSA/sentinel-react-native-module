import Foundation
import shared

@objc(AuthModule)
class AuthModule: RCTEventEmitter {
    
    private let cloudProvider = SentinelProvider.shared.cloudProvider
    private let sessionProvider = SentinelProvider.shared.sessionProvider
    private var authServices: AuthServices
    
    override func supportedEvents() -> [String]! {
        return ["hasSession"]
    }
    
    @objc
    override init () {
        self.authServices = cloudProvider.authCloudServices
        super.init()
        // TODO: comment this back in when we have access to the shared library.
//        sessionProvider.hasActiveSession.collect {
//            var event = Arguments.createMap()
//            event.putBoolean("localSession", sessionProvider.hasActiveSession.value)
//            sendEvent("hasSession", event)
//        }
    }
    
    @objc
    func isLoggedIn(_ resolve: RCTPromiseResolveBlock, reject: RCTPromiseRejectBlock) {
        resolve(sessionProvider.hasActiveSession.value)
    }
        
    @objc
    func signIn(_ username: String, password: String, resolve: @escaping RCTPromiseResolveBlock, reject: @escaping RCTPromiseRejectBlock) {
        Task { @MainActor in
            do {
                print("signIn::Promise")
                let loginResult = try await authServices.login(user: User(email: username.trimmingCharacters(in: .whitespacesAndNewlines), password: password.trimmingCharacters(in: .whitespacesAndNewlines)))
                
                if (loginResult.success) {
                    resolve("${result.data}")
                } else {
                    let error = NSError(domain: "", code: loginResult.errorCode as? Int ?? 0, userInfo: ["${result.errorCode}": "${result.errorCode}"])
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
    func signIn(_ username: String, password: String, failureCallback: @escaping RCTResponseSenderBlock, successCallback: @escaping RCTResponseSenderBlock) {
        print("signIn::Callback")
        Task {
            do {
                let result = try await authServices.login(user: User(email: username.trimmingCharacters(in: .whitespacesAndNewlines), password: password.trimmingCharacters(in: .whitespacesAndNewlines)))
                
                if (result.success) {
                    successCallback(["${result.data}"])
                } else {
                    failureCallback(["${result.errorCode}", "${result.errorCode}"])
                }
            } catch {
                print(error)
                let error = NSError(domain: "", code: 0, userInfo: ["${0}": error.localizedDescription])
                failureCallback(["ERROR_SIGNIN", "Exception", error])
            }
        }
    }
    
    @objc
    func recoverPassword(_ email: String, resolve: @escaping RCTPromiseResolveBlock, reject: @escaping RCTPromiseRejectBlock) {
        Task { @MainActor in
            do {
                let changePasswordResult = try await authServices.changePassword(email: UserData(email: email.trimmingCharacters(in: .whitespacesAndNewlines)))
                
                if (changePasswordResult.success) {
                    resolve("${changePasswordResult.data}")
                } else {
                    let error = NSError(domain: "", code: changePasswordResult.errorCode as? Int ?? 0, userInfo: ["${changePasswordResult.errorCode}": "${changePasswordResult.errorCode}"])
                    reject("ERROR_RECOVERPASSWORD", "There was an error recovering the password", error)
                }
            } catch {
                let error = NSError(domain: "", code: 0, userInfo: ["Error": "Exception"])
                reject("ERROR_RECOVERPASSWORD", "An exception happen while recovering the password", error)
            }
        }
    }
    
    @objc
    func recoverPassword(_ email: String, failureCallback: @escaping RCTResponseSenderBlock, successCallback: @escaping RCTResponseSenderBlock) {
        Task { @MainActor in
            do {
                let  changePasswordResult = try await authServices.changePassword(email: UserData(email: email.trimmingCharacters(in: .whitespacesAndNewlines)))
                if (changePasswordResult.success) {
                    successCallback(["${changePasswordResult.data}"])
                } else {
                    failureCallback(["${changePasswordResult.errorCode}", "${changePasswordResult.errorCode}"])
                }
            } catch {
                let error = NSError(domain: "", code: 0, userInfo: ["${0}": error.localizedDescription])
                failureCallback(["ERROR_SIGNIN", "Exception", error])
            }

        }
    }
    
    @objc
    func signOut(_ resolve: @escaping RCTPromiseResolveBlock, reject: @escaping RCTPromiseRejectBlock) {
        Task { @MainActor in
            do {
                let signOutResult = try await authServices.logout()
                
                if (signOutResult.success) {
                    resolve("${signOutResult.data}")
                } else {
                    let error = NSError(domain: "", code: signOutResult.errorCode as! Int, userInfo: ["${signOutResult.errorCode}": "${signOutResult.errorCode}"])
                    reject("ERROR_LOGINOUT", "There was an error login out", error)
                }
            }
            catch {
                print("Request failed with Exception ${error.localizedDescription}")
                print(error)
                let error = NSError(domain: "", code: 0, userInfo: ["${0}": error.localizedDescription])
                reject("ERROR_LOGINOUT", "Exception", error)
            }
        }
    }
    
    @objc
    func signOut(_ failureCallback: @escaping RCTResponseSenderBlock, successCallback: @escaping RCTResponseSenderBlock) {
        Task { @MainActor in
            do {
                let signOutResult = try await authServices.logout()
                if (signOutResult.success) {
                    successCallback(["${signOutResult.data}"])
                } else {
                    failureCallback(["${signOutResult.errorCode}", "${result.errorCode}"])
                }
            } catch {
                let error = NSError(domain: "", code: 0, userInfo: ["${0}": error.localizedDescription])
                failureCallback(["ERROR_SIGNIN", "Exception", error])
            }
        }
    }
    
    @objc
    func accountType(_ resolve: @escaping RCTPromiseResolveBlock, reject: @escaping RCTPromiseRejectBlock) {
        
        Task { @MainActor in
            do {
                var accountTypeResult = try await authServices.getAccountType()
                if (accountTypeResult != "") {
                    resolve(accountTypeResult)
                } else {
                    let error = NSError(domain: "", code: 0, userInfo: ["$accountTypeResult": "$accountTypeResult"])
                    reject("ERROR_ACCOUNTTYPE", "An error happen while getting the account type", error)
                }
            } catch {
                let error = NSError(domain: "", code: 0, userInfo: ["${0}": error.localizedDescription])
                reject("ERROR_ACCOUNTYPE", "Exception", error)
            }
        }
    }
    
    override static func requiresMainQueueSetup() -> Bool {
        return true;
    }
}
