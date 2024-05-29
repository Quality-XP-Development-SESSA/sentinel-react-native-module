package com.sentinelsdk

import com.facebook.react.bridge.Arguments
import com.facebook.react.bridge.Promise
import com.facebook.react.bridge.ReactApplicationContext
import com.facebook.react.bridge.ReactContextBaseJavaModule
import com.facebook.react.bridge.ReactMethod
import com.facebook.react.bridge.WritableArray
import com.qxdev.sentinel_sdk.SentinelProvider
import kotlinx.coroutines.CoroutineScope
import kotlinx.coroutines.Dispatchers
import kotlinx.coroutines.Job
import kotlinx.coroutines.launch
import kotlinx.serialization.encodeToString
import kotlinx.serialization.json.Json

class FirmwareModule(context: ReactApplicationContext) :
  ReactContextBaseJavaModule(context) {
    override fun getName(): String = "FirmwareModule"

    private val coroutineScope = CoroutineScope(Dispatchers.IO + Job())
    private val cloudProvider = SentinelProvider.cloudProvider
    private val firmwareServices = cloudProvider.firmwareCloudServices

    @ReactMethod
    fun updateFirmware(devices: String, promise: Promise) {
        val devicesList: Array<String> = arrayOf(devices)
        coroutineScope.launch {
            val updateFirmwareResult = kotlin.runCatching {
                firmwareServices.updateFirware(devicesList)
            }
            val result = updateFirmwareResult.getOrNull()
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
                println("Request failed with Exception ${updateFirmwareResult.exceptionOrNull()?.message}")
                promise.reject("${0}", "0")
            }
        }
    }
}