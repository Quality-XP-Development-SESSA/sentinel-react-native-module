package com.sentinelsdk

import com.facebook.react.bridge.ReactApplicationContext
import com.facebook.react.bridge.ReactContextBaseJavaModule
import com.facebook.react.bridge.ReactMethod
import com.facebook.react.bridge.Promise
import com.facebook.react.bridge.Arguments
import com.facebook.react.bridge.WritableArray
import kotlinx.serialization.encodeToString
import kotlinx.serialization.json.Json

class AuthModule(reactContext: ReactApplicationContext) : 
    ReactContextBaseJavaModule(reactContext) {

    override fun getName(): String = "AuthModule"

    @ReactMethod
    fun helloKotlin(promise: Promise) {
        val jsonList = Json.encodeToString("Hello Kotlin")
        val array: WritableArray = Arguments.createArray()
        array.pushString(jsonList)
        promise.resolve(array)
    }
}