plugins {
    id("com.android.application")
    id("kotlin-android")
    id("dev.flutter.flutter-gradle-plugin")
    id("com.google.gms.google-services")
}

android {
    namespace = "id.co.twka.fms.driver"
    compileSdk = flutter.compileSdkVersion

    defaultConfig {
        // defaultId (akan dioverride di tiap flavor)
        applicationId = "id.co.twka.fms.driver"
        minSdk = flutter.minSdkVersion
        targetSdk = flutter.targetSdkVersion
        versionCode = flutter.versionCode
        versionName = flutter.versionName
    }

    // → atur flavor dimension dan productFlavors
    flavorDimensions += "app"
    productFlavors {
        create("dev") {
            dimension = "app"
            applicationId = "id.co.twka.fms.driver.dev"
            resValue("string", "app_name", "Dev Driver")
        }
        create("rusco") {
            dimension = "app"
            applicationId = "id.co.twka.fms.driver.rusco"
            resValue("string", "app_name", "Rusco Driver")
        }
        create("tka") {
            dimension = "app"
            applicationId = "id.co.twka.fms.driver"
            resValue("string", "app_name", "OttoGo Driver")
        }
    }

    buildTypes {
        getByName("debug") {
            signingConfig = signingConfigs.getByName("debug")
        }
        getByName("release") {
            signingConfig = signingConfigs.getByName("debug")
            // untuk production release, ganti signingConfigs sesuai kebutuhan
        }
    }

    compileOptions {
        sourceCompatibility = JavaVersion.VERSION_11
        targetCompatibility = JavaVersion.VERSION_11
    }
    kotlinOptions {
        jvmTarget = JavaVersion.VERSION_11.toString()
    }
}

flutter {
    source = "../.."
}
