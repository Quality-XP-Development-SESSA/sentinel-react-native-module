package com.sentinelsdk

import com.facebook.react.bridge.ReactApplicationContext
import com.facebook.react.bridge.ReactContextBaseJavaModule
import com.facebook.react.bridge.ReactMethod
import com.facebook.react.bridge.Promise
import com.qxdev.sentinel_sdk.SentinelProvider
import com.qxdev.sentinel_sdk.cloud.data.Response
import kotlinx.coroutines.CoroutineScope
import kotlinx.coroutines.Dispatchers
import kotlinx.coroutines.Job
import kotlinx.coroutines.launch

import com.qxdev.sentinel_sdk.cloud.data.LocationData

import com.facebook.react.bridge.WritableArray
import com.facebook.react.bridge.WritableMap
import com.facebook.react.bridge.Arguments
import kotlinx.serialization.encodeToString
import kotlinx.serialization.json.Json
import com.facebook.react.modules.core.DeviceEventManagerModule

class LocationsModule(reactContext: ReactApplicationContext) :
  ReactContextBaseJavaModule(reactContext) {

  override fun getName(): String {
    return NAME
  }

  private val coroutineScope = CoroutineScope(Dispatchers.IO + Job())
  private val cloudProvider = SentinelProvider.cloudProvider
  private val locationsServices = cloudProvider.locationsCloudServices

  override fun initialize() {
    super.initialize()
    coroutineScope.launch {
      locationsServices.locations.collect {
        val event = Arguments.createMap()
        val jsonList = Json.encodeToString(it)
        val array: WritableArray = Arguments.createArray()
        array.pushString(jsonList)
        event.putArray("data", array)
        sendEvent("LocationList", event)
      }
    }
  }

  private fun sendEvent(eventName: String, params: WritableMap) {
    reactApplicationContext
      .getJSModule(DeviceEventManagerModule.RCTDeviceEventEmitter::class.java)
      .emit(eventName, params)
  }

  @ReactMethod
  fun addListener(type: String?) {
    // Keep: Required for RN built in Event Emitter Calls.
  }

  @ReactMethod
  fun removeListeners(type: Int?) {
    // Keep: Required for RN built in Event Emitter Calls.
  }

  @ReactMethod
  fun getLocations(customerId: String, promise: Promise) {
    coroutineScope.launch {
      val response = kotlin.runCatching {
        locationsServices.getLocation(customerId)
      }
      val result = response.getOrNull()

      if (result != null) {
        if (result.success) {
          val jsonList = Json.encodeToString(result.data)
          val array: WritableArray = Arguments.createArray()
          array.pushString(jsonList)
          promise.resolve(array)
        } else {
          promise.reject("${result.errorCode}", "${result.errorCode}")
        }
      } else {
        println("Request failed with Exception ${response.exceptionOrNull()?.message}")
        promise.reject("${0}", "0")
      }
    }
  }

  @ReactMethod
  fun getFilterLocationList(filterValue: String, customerId: String, promise: Promise) {
    coroutineScope.launch {
      val response = kotlin.runCatching {
        locationsServices.filterLocationList(filterValue, customerId)
      }
      val result = response.getOrNull()

      if (result != null) {
        if (result.success) {
          val jsonList = Json.encodeToString(result.data)
          val array: WritableArray = Arguments.createArray()
          array.pushString(jsonList)
          promise.resolve(array)
        } else {
          promise.reject("${result.errorCode}", "${result.errorCode}")
        }
      } else {
        println("Request failed with Exception ${response.exceptionOrNull()?.message}")
        promise.reject("${0}", "0")
      }
    }
  }

  @ReactMethod
  fun getSensors(locationId: String, filterValue: String, promise: Promise) {
    coroutineScope.launch {
      val response = kotlin.runCatching {
        locationsServices.getSensors(locationId, filterValue)
      }
      val result = response.getOrNull()

      if (result != null) {
        if (result.success) {
          val jsonList = Json.encodeToString(result.data)
          val array: WritableArray = Arguments.createArray()
          array.pushString(jsonList)
          promise.resolve(array)
        } else {
          promise.reject("${result.errorCode}", "${result.errorCode}")
        }
      } else {
        println("Request failed with Exception ${response.exceptionOrNull()?.message}")
        promise.reject("${0}", "0")
      }
    }
  }

  @ReactMethod
  fun getGateways(locationId: String, filterValue: String, promise: Promise) {
    coroutineScope.launch {
      val response = kotlin.runCatching {
        locationsServices.getGateways(locationId, filterValue)
      }

      val result = response.getOrNull()

      if (result != null) {
        if (result.success) {
          val jsonList = Json.encodeToString(result.data)
          val array: WritableArray = Arguments.createArray()
          array.pushString(jsonList)
          promise.resolve(array)
        } else {
          promise.reject("${result.errorCode}", "${result.errorCode}")
        }
      } else {
        println("Request failed with Exception ${response.exceptionOrNull()?.message}")
        promise.reject("${0}", "0")
      }
    }
  }

  @ReactMethod
  fun deleteLocation(locationId: Int, transferLocationId: String?, promise: Promise) {
    coroutineScope.launch {
      val response = kotlin.runCatching {
        locationsServices.deleteLocation(locationId, transferLocationId)
      }

      val result = response.getOrNull()

      if (result != null) {
        if (result.success) {
          promise.resolve("${result.data}")
        } else {
          promise.reject("${result.errorCode}", "${result.errorCode}")
        }
      } else {
        println("Request failed with Exception ${response.exceptionOrNull()?.message}")
        promise.reject("${0}", "0")
      }
    }
  }

  @ReactMethod
  fun addLocation(
    name: String,
    description: String,
    latitude: Double,
    longitude: Double,
    customerId: Int?,
    promise: Promise
  ) {
    coroutineScope.launch {
      val response = kotlin.runCatching {
        locationsServices.addLocation(
          LocationData(
            name,
            description,
            latitude,
            longitude,
            customerId
          )
        )
      }
      val result = response.getOrNull()

      if (result != null) {
        if (result.success) {
          promise.resolve(Json.encodeToString(result.data))
        } else {
          promise.reject("${result.errorCode}", "${result.errorCode}")
        }
      } else {
        println("Request failed with Exception ${response.exceptionOrNull()?.message}")
        promise.reject("${0}", "0")
      }
    }
  }

  @ReactMethod
  fun refreshLocation(customerId: String) {
    coroutineScope.launch {
      kotlin.runCatching {
        locationsServices.refreshLocation(customerId)
      }
    }
  }

  companion object {
    const val NAME = "LocationsModule"
  }
}
