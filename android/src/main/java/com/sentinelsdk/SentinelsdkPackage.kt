package com.sentinelsdk

import com.facebook.react.ReactPackage
import com.facebook.react.bridge.NativeModule
import com.facebook.react.bridge.ReactApplicationContext
import com.facebook.react.uimanager.ViewManager
import org.koin.core.context.GlobalContext.startKoin
import org.koin.dsl.module
import com.qxdev.sentinel_sdk.di.Koin
import com.qxdev.sentinel_sdk.onboarding.ConnectionToDevice
import com.qxdev.sentinel_sdk.onboarding.interfaces.WifiManager
import com.qxdev.sentinel_sdk.database.DatabaseDriverFactory

class SentinelsdkPackage : ReactPackage {
  override fun createNativeModules(reactContext: ReactApplicationContext): List<NativeModule> {
    startKoin {
      modules(module {
          modules(module {
            single<WifiManager> { ConnectionToDevice(reactContext) }
          }, Koin.sentinelSDKModule("https://app-stage.sensys-iot.com", DatabaseDriverFactory(reactContext)))
      })
    }
    return mutableListOf(
      SentinelsdkModule(reactContext),
      AuthModule(reactContext),
      CustomerModule(reactContext),
      LocationsModule(reactContext),
      DevicesModule(reactContext),
      ControllerModule(reactContext),
    )
  }

  override fun createViewManagers(reactContext: ReactApplicationContext): List<ViewManager<*, *>> {
    return mutableListOf()
  }
}
