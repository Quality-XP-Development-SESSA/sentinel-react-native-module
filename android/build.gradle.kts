import com.android.build.api.variant.BuildConfigField

buildscript {
  val kotlin_version = if (rootProject.extra.has("kotlinVersion")) {
      rootProject.extra["kotlinVersion"] as String
    } else {
      project.findProperty("Sentinelsdk_kotlinVersion") as String?
    }

  repositories {
    google()
    mavenCentral()
    mavenLocal()
  }

  dependencies {
    classpath("com.android.tools.build:gradle:7.2.1")
    classpath("org.jetbrains.kotlin:kotlin-gradle-plugin:$kotlin_version")
    classpath("com.google.gms:google-services:4.3.15")
  }
}

fun isNewArchitectureEnabled(): Boolean {
  return rootProject.hasProperty("newArchEnabled") && rootProject.property("newArchEnabled") == "true"
}

plugins {
  id("com.android.library")
  id("kotlin-android")
}

if (isNewArchitectureEnabled()) {
  apply(plugin = "com.facebook.react")
}

fun getExtOrDefault(name: String): Any? {
  return if (rootProject.extra.has(name)) {
    rootProject.extra[name]
  } else {
    project.findProperty("Sentinelsdk_$name")
  }
}

fun getExtOrIntegerDefault(name: String): Int {
  return if (rootProject.extra.has(name)) {
    rootProject.extra[name] as Int
  } else {
    (project.findProperty("Sentinelsdk_$name") as String).toInt()
  }
}

fun supportsNamespace(): Boolean {
  val parsed = com.android.Version.ANDROID_GRADLE_PLUGIN_VERSION.split('.')
  val major = parsed[0].toIntOrNull() ?: 0
  val minor = parsed.getOrNull(1)?.toIntOrNull() ?: 0

  // Namespace support was added in 7.3.0
  return (major == 7 && minor >= 3) || major >= 8
}

android {
  if (supportsNamespace()) {
    namespace = "com.sentinelsdk"

    sourceSets {
      getByName("main") {
        manifest.srcFile("src/main/AndroidManifest.xml")
      }
    }
  }

  compileSdk = getExtOrIntegerDefault("compileSdkVersion")

  defaultConfig {
    minSdk = getExtOrIntegerDefault("minSdkVersion")
    targetSdk = getExtOrIntegerDefault("targetSdkVersion")
  }

  buildTypes {
    release {
      isMinifyEnabled = false
    }
  }

  lintOptions {
    disable("GradleCompatible")
  }

  compileOptions {
    sourceCompatibility = JavaVersion.VERSION_1_8
    targetCompatibility = JavaVersion.VERSION_1_8
  }

  androidComponents.onVariants { variant ->
    // Add BuildConfig property to read  SDK version used by the app
    val config = project.configurations.filter { it.name == "${variant.flavorName}Implementation" }
      .map { it.allDependencies.filter { it.group.orEmpty().contains("sentinel-sdk") && it.name == "android-sdk" }.firstOrNull() }
      .firstOrNull()

    variant.buildConfigFields.put("SDK_VERSION", BuildConfigField("String", "\"${config?.version.orEmpty()}\"", null))
  }
}

repositories {
  mavenCentral()
  mavenLocal()
  google()
}

val kotlin_version = getExtOrDefault("kotlinVersion")
val koin_version = "3.5.3"

dependencies {
  // For < 0.71, this will be from the local maven repo
  // For > 0.71, this will be replaced by `com.facebook.react:react-android:$version` by react gradle plugin
  //noinspection GradleDynamicVersion
  implementation("com.facebook.react:react-native:+")
  implementation("com.facebook.react:react-android")

  implementation("org.jetbrains.kotlin:kotlin-stdlib:$kotlin_version")

  implementation(files("../android/src/main/libs/android-sdk-1.0.1.aar"))
  // implementation fileTree(dir: 'libs', include: ['*.jar', '*.aar'])

  implementation("com.russhwolf:multiplatform-settings:1.1.1")
  implementation("com.russhwolf:multiplatform-settings-no-arg:1.1.1")
  implementation("com.russhwolf:multiplatform-settings-serialization:1.0.0")

  implementation("io.ktor:ktor-client-core:3.0.0-beta-1")

  implementation("io.ktor:ktor-client-content-negotiation:3.0.0-beta-1")
  implementation("io.ktor:ktor-serialization-kotlinx-json:3.0.0-beta-1")

  implementation("io.ktor:ktor-client-logging:3.0.0-beta-1")
  implementation("io.ktor:ktor-client-auth:3.0.0-beta-1")
  implementation("io.ktor:ktor-client-okhttp:3.0.0-beta-1")

  implementation("app.cash.sqldelight:android-driver:2.0.1")
  implementation("app.cash.sqldelight:coroutines-extensions:2.0.1")

  implementation("org.jetbrains.kotlinx:kotlinx-serialization-json:1.6.1")

  implementation("org.jetbrains.kotlinx:kotlinx-coroutines-android:1.8.0")

  implementation("io.insert-koin:koin-android:$koin_version")
}

