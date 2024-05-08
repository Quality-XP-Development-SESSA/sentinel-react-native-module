package com.sentinelsdk

import com.facebook.react.bridge.ReactApplicationContext
import com.facebook.react.bridge.ReactContextBaseJavaModule
import com.facebook.react.bridge.ReactMethod
import com.facebook.react.bridge.Promise

import com.qxdev.sentinel_sdk.wifi.wifiDiscovery.WifiScannerImpl

import kotlinx.coroutines.CoroutineScope
import kotlinx.coroutines.Dispatchers
import kotlinx.coroutines.Job
import kotlinx.coroutines.launch

import com.facebook.react.bridge.WritableArray
import com.facebook.react.bridge.Arguments
import kotlinx.serialization.encodeToString
import kotlinx.serialization.json.Json

class WifiDiscoveryModule(reactContext: ReactApplicationContext) :
  ReactContextBaseJavaModule(reactContext) {

  override fun getName(): String {
    return NAME
  }

  private val coroutineScope = CoroutineScope(Dispatchers.IO + Job())
  private val wifiScanner = WifiScannerImpl(reactContext.applicationContext)

  @ReactMethod
  fun startScan(deviceType: String, promise: Promise) {
    coroutineScope.launch {
      try {
        wifiScanner.startScan(
          deviceType
        ) { result ->
          val jsonList = Json.encodeToString(result)
          val array: WritableArray = Arguments.createArray()
          array.pushString(jsonList)
          promise.resolve(array)
        }
      } catch (e: Exception) {
        println("Request failed with Exception ${e.message}")
        promise.reject("${0}", "0")
      }
    }
  }

  companion object {
    const val NAME = "WifiDiscoveryModule"
  }
}
