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

import com.facebook.react.bridge.WritableArray
import com.facebook.react.bridge.WritableMap
import com.facebook.react.bridge.Arguments
import kotlinx.serialization.encodeToString
import kotlinx.serialization.json.Json
import com.facebook.react.modules.core.DeviceEventManagerModule

class DevicesModule(reactContext: ReactApplicationContext) :
  ReactContextBaseJavaModule(reactContext) {

  override fun getName(): String {
    return NAME
  }

  private val coroutineScope = CoroutineScope(Dispatchers.IO + Job())
  private val cloudProvider = SentinelProvider.cloudProvider
  private val deviceServices = cloudProvider.devicesCloudServices

  override fun initialize() {
    super.initialize()
    coroutineScope.launch {
      deviceServices.gateways.collect {
        val event = Arguments.createMap()
        val jsonList = Json.encodeToString(it)
        val array: WritableArray = Arguments.createArray()
        array.pushString(jsonList)
        event.putArray("data", array)
        sendEvent("GatewaysList", event)
      }
    }
    coroutineScope.launch {
      deviceServices.sensors.collect {
        val event = Arguments.createMap()
        val jsonList = Json.encodeToString(it)
        val array: WritableArray = Arguments.createArray()
        array.pushString(jsonList)
        event.putArray("data", array)
        sendEvent("SensorsList", event)
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
  fun getSensors(filter: String?, promise: Promise) {
    coroutineScope.launch {
      val response = kotlin.runCatching {
        deviceServices.getSensors(filter)
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
  fun deleteSensors(ids: String, promise: Promise) {
    val sensors: Array<Int> = arrayOf(ids.toInt())
    coroutineScope.launch {
      val deleteSensorsResult = kotlin.runCatching {
        deviceServices.deleteSensors(sensors)
      }
      val result = deleteSensorsResult.getOrNull()

      if (result != null) {
        if (result.success) {
          promise.resolve("${result.data}")
        } else {
          promise.reject("${result.errorCode}", "${result.errorCode}")
        }
      } else {
        println("Request failed with Exception ${deleteSensorsResult.exceptionOrNull()?.message}")
        promise.reject("${0}", "0")
      }
    }
  }

    @ReactMethod
    fun editSensorName(id: String, name: String, promise: Promise) {
      coroutineScope.launch {
        val editNameResult = kotlin.runCatching {
          deviceServices.editSensorName(id.toInt(), name)
        }
        val result = editNameResult.getOrNull()

        if (result != null) {
          if (result.success) {
            promise.resolve("${result.data}")
          } else {
            promise.reject("${result.errorCode}", "${result.errorCode}")
          }
        } else {
          println("Request failed with Exception ${editNameResult.exceptionOrNull()?.message}")
          promise.reject("${0}", "0")
        }
      }
    }

    @ReactMethod
  fun getGateways(filter: String?, promise: Promise) {
    coroutineScope.launch {
      val response = kotlin.runCatching {
        deviceServices.getGateways(filter)
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
  fun deleteGateway(id: String, promise: Promise) {
    coroutineScope.launch {
      val deleteGatewaysResult = kotlin.runCatching {
        deviceServices.deleteGateway(id.toInt())
      }
      val result = deleteGatewaysResult.getOrNull()

      if (result != null) {
        if (result.success) {
          promise.resolve("${result.data}")
        } else {
          promise.reject("${result.errorCode}", "${result.errorCode}")
        }
      } else {
        println("Request failed with Exception ${deleteGatewaysResult.exceptionOrNull()?.message}")
        promise.reject("${0}", "0")
      }
    }
  }

  @ReactMethod
  fun editGatewayName(id: String, name: String, promise: Promise) {
    coroutineScope.launch {
      val editNameResult = kotlin.runCatching {
        deviceServices.editGateways(id.toInt(), name)
      }
      val result = editNameResult.getOrNull()

      if (result != null) {
        println(result.success)
        if (result.success) {
          promise.resolve("${result.data}")
        } else {
          promise.reject("${result.errorCode}", "${result.errorCode}")
        }
      } else {
        println("Request failed with Exception ${editNameResult.exceptionOrNull()?.message}")
        promise.reject("${0}", "0")
      }
    }
  }

  @ReactMethod
  fun getCustomerDevices(customerId: String, promise: Promise) {
    coroutineScope.launch {
      val response = kotlin.runCatching {
        deviceServices.getCustomerDevices(customerId)
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
  fun getGatewaysLora(filter: String?, locationId: String, promise: Promise) {
    coroutineScope.launch {
      val response = kotlin.runCatching {
        deviceServices.getGatewaysLora(filter, locationId)
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
  fun refreshGateways(filter: String?) {
    coroutineScope.launch {
      kotlin.runCatching {
        deviceServices.refreshGateways(filter)
      }
    }
  }

  @ReactMethod
  fun refreshSensors(filter: String?) {
    coroutineScope.launch {
      kotlin.runCatching {
        deviceServices.refreshSensors(filter)
      }
    }
  }

  companion object {
    const val NAME = "DevicesModule"
  }
}
