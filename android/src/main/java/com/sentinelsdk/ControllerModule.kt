package com.sentinelsdk

import com.facebook.react.bridge.ReactApplicationContext
import com.facebook.react.bridge.ReactContextBaseJavaModule
import com.facebook.react.bridge.ReactMethod
import com.facebook.react.bridge.Promise
import com.facebook.react.bridge.Arguments

import com.facebook.react.bridge.WritableArray
import com.facebook.react.bridge.WritableMap
import com.facebook.react.modules.core.DeviceEventManagerModule
import com.qxdev.sentinel_sdk.onboarding.DeviceOnboardingControllerImpl

import kotlinx.coroutines.CoroutineScope
import kotlinx.coroutines.Dispatchers
import kotlinx.coroutines.Job
import kotlinx.coroutines.launch
import kotlinx.serialization.encodeToString
import kotlinx.serialization.json.Json

class ControllerModule(reactContext: ReactApplicationContext) :
  ReactContextBaseJavaModule(reactContext) {

  override fun getName(): String {
    return NAME
  }

  private val coroutineScope = CoroutineScope(Dispatchers.IO + Job())
  private val deviceConnect = DeviceOnboardingControllerImpl()

  override fun initialize() {
    super.initialize()
    coroutineScope.launch {
      deviceConnect.addNetworkChangeListener { result ->
        val event = Arguments.createMap()
        event.putBoolean("isConnected", result)
        sendEvent("connectionListener", event)
      }
    }
  }

  @ReactMethod
  fun connectDevice(ssid: String, promise: Promise) {
    coroutineScope.launch {
      try {
        deviceConnect.connectToDevice(ssid) { result ->
          promise.resolve(result)
        }
      } catch (e: Exception) {
        println("Request failed with Exception ${e.message}")
        promise.reject("${0}", "0")
      }
    }
  }

  private fun sendEvent(eventName: String, params: WritableMap) {
    reactApplicationContext
      .getJSModule(DeviceEventManagerModule.RCTDeviceEventEmitter::class.java)
      .emit(eventName, params)
  }

  @ReactMethod
  fun getNetworksAvailable(promise: Promise) {
    coroutineScope.launch {
      try {
        val result = deviceConnect.listNetworks()
        val jsonList = Json.encodeToString(result)
        val array: WritableArray = Arguments.createArray()
        array.pushString(jsonList)
        promise.resolve(array)
      } catch (e: Exception) {
        println("Request failed with Exception ${e.message}")
        promise.reject("${0}", "0")
      }
    }
  }

  @ReactMethod
  fun setupOnboarding(
    id_Location: String,
    ssid: String,
    password: String,
    customerId: String?,
    deviceType: String,
    api_key: String?,
    gateway_id: String?,
    promise: Promise
  ) {
    coroutineScope.launch {
      val useStaging = BuildConfig.FLAVOR !== "production"
      val resultado = kotlin.runCatching {
        deviceConnect.startOnboarding(
          id_Location,
          ssid,
          password,
          customerId,
          deviceType,
          gateway_id,
          api_key,
          useStaging
        )
      }
      val result = resultado.getOrNull()

      if (result != null) {
        if (result.success) {
          promise.resolve(Json.encodeToString(result.data))
        } else {
          promise.reject("${result.errorCode}")
        }
      } else {
        promise.reject("$result", "$result")
      }
    }
  }

  companion object {
    const val NAME = "ControllerModule"
  }
}
