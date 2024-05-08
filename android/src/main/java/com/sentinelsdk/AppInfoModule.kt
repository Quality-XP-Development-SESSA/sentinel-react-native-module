package com.sentinelsdk

import com.facebook.react.bridge.ReactApplicationContext
import com.facebook.react.bridge.ReactContextBaseJavaModule
import com.facebook.react.bridge.ReactMethod
import com.facebook.react.bridge.Promise
import com.facebook.react.bridge.Arguments

import com.sentinelsdk.BuildConfig

import kotlinx.coroutines.CoroutineScope
import kotlinx.coroutines.Dispatchers
import kotlinx.coroutines.Job

class AppInfoModule(reactContext: ReactApplicationContext) :
  ReactContextBaseJavaModule(reactContext) {

  override fun getName(): String {
    return NAME
  }

  private val coroutineScope = CoroutineScope(Dispatchers.IO + Job())

  @ReactMethod
  fun readInfo(promise: Promise) {
    with(Arguments.createMap()) {
      putString(
        "app_version",
        "${BuildConfig.VERSION_NAME}(${BuildConfig.VERSION_CODE})${if (BuildConfig.DEBUG) "(DEBUG)" else ""}"
      )
      putString("sdk_version", BuildConfig.SDK_VERSION)

      promise.resolve(this)
    }
  }

  companion object {
    const val NAME = "AppInfoModule"
  }
}
