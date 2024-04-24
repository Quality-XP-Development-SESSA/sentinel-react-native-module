package com.sentinelsdk

import com.facebook.react.bridge.ReactApplicationContext
import com.facebook.react.bridge.ReactContextBaseJavaModule
import com.facebook.react.bridge.ReactMethod
import com.facebook.react.bridge.Callback
import com.facebook.react.bridge.Promise
import com.qxdev.sentinel_sdk.SentinelProvider
import com.qxdev.sentinel_sdk.cloud.data.Response
import com.qxdev.sentinel_sdk.cloud.data.auth.User
import com.qxdev.sentinel_sdk.cloud.data.auth.UserData
import kotlinx.coroutines.CoroutineScope
import kotlinx.coroutines.Dispatchers
import kotlinx.coroutines.Job
import kotlinx.coroutines.launch

import com.facebook.react.bridge.WritableMap
import com.facebook.react.bridge.Arguments

import com.facebook.react.modules.core.DeviceEventManagerModule

class AuthModule(reactContext: ReactApplicationContext) :
  ReactContextBaseJavaModule(reactContext) {

  override fun getName(): String {
    return NAME
  }

  private val coroutineScope = CoroutineScope(Dispatchers.IO + Job())
  private val cloudProvider = SentinelProvider.cloudProvider
  private val sessionProvider = SentinelProvider.sessionProvider
  private val authServices = cloudProvider.authCloudServices

  // Example method
  // See https://reactnative.dev/docs/native-modules-android

  override fun initialize() {
    super.initialize()
    coroutineScope.launch {
      sessionProvider.hasActiveSession.collect {
        val event = Arguments.createMap()
        event.putBoolean("localSession", sessionProvider.hasActiveSession.value)
        sendEvent("hasSession", event)
      }
    }
  }

  @ReactMethod
  fun isLoggedIn(promise: Promise) {
    promise.resolve(sessionProvider.hasActiveSession.value)
  }

  private fun sendEvent(eventName: String, params: WritableMap) {
    reactApplicationContext
      .getJSModule(DeviceEventManagerModule.RCTDeviceEventEmitter::class.java)
      .emit(eventName, params)
  }

  @ReactMethod
  fun signIn(username: String, password: String, promise: Promise) {
    coroutineScope.launch {
      val resultado = kotlin.runCatching {
        authServices.login(User(username.trim(), password.trim()))
      }
      val result = resultado.getOrNull()

      if (result != null) {
        if (result.success) {
          promise.resolve("${result.data}")
        } else {
          promise.reject("${result.errorCode}", "${result.errorCode}")
        }
      } else {
        println("Request failed with Exception ${resultado.exceptionOrNull()?.message}")
        promise.reject("${0}", "0")
      }
    }
  }

  @ReactMethod
  fun signIn(
    username: String,
    password: String,
    failureCallback: Callback,
    successCallback: Callback
  ) {
    coroutineScope.launch {
      val result: Response<Any> = authServices.login(User(username.trim(), password.trim()))
      if (result.success) {
        successCallback.invoke("${result.data}")
      } else {
        failureCallback.invoke("${result.errorCode}", "${result.errorCode}")
      }
    }
  }

  @ReactMethod
  fun recoverPassword(email: String, promise: Promise) {
    coroutineScope.launch {
      val result = authServices.changePassword(UserData(email.trim()))
      try {
        if (result.success) {
          promise.resolve("${result.data}")
        } else {
          promise.reject("${result.errorCode}", "${result.errorCode}")
        }
      } catch (error: Error) {
        promise.reject("Error", error)
      }
    }
  }

  @ReactMethod
  fun recoverPassword(email: String, failureCallback: Callback, successCallback: Callback) {
    coroutineScope.launch {
      val result = authServices.changePassword(UserData(email.trim()))
      if (result.success) {
        successCallback.invoke("${result.data}")
      } else {
        failureCallback.invoke("${result.errorCode}", "${result.errorCode}")
      }
    }
  }

  @ReactMethod
  fun signOut(promise: Promise) {
    coroutineScope.launch {
      try {
        val result = authServices.logout()
        if (result.success) {
          promise.resolve("${result.data}")
        } else {
          promise.reject("${result.errorCode}", "${result.errorCode}")
        }
      } catch (e: Exception) {
        sessionProvider.sessionData = null
        promise.reject("Error", e)
      }
    }
  }

  @ReactMethod
  fun signOut(failureCallback: Callback, successCallback: Callback) {
    coroutineScope.launch {
      val result = authServices.logout()
      if (result.success) {
        successCallback.invoke("${result.data}")
      } else {
        failureCallback.invoke("${result.errorCode}", "${result.errorCode}")
      }
    }
  }

  @ReactMethod
  fun accountType(promise: Promise) {
    coroutineScope.launch {
      val resultado = kotlin.runCatching {
        authServices.getAccountType()
      }
      val result = resultado.getOrNull()
      if (result != null) {
        promise.resolve("$result")
      } else {
        promise.reject("$result", "$result")
      }
    }
  }

  companion object {
    const val NAME = "AuthModule"
  }
}
