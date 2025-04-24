plugins {
    id("com.android.application")
    id("kotlin-android")
    id("dev.flutter.flutter-gradle-plugin")
    id("com.google.gms.google-services")
}

android {
    namespace = "id.co.twka.fms.driver"
    compileSdk = flutter.compileSdkVersion     // biarkan di-set oleh Flutter

    defaultConfig {
        applicationId  = "id.co.twka.fms.driver"
        minSdk         = flutter.minSdkVersion
        targetSdk      = flutter.targetSdkVersion
        versionCode    = flutter.versionCode
        versionName    = flutter.versionName
    }

    // ─── Flavors ───────────────────────────────────────────────────────────────
    flavorDimensions += "app"
    productFlavors {
        create("dev") {
            dimension      = "app"
            applicationId  = "id.co.twka.fms.driver.dev"
            resValue("string", "app_name", "Dev Driver")
        }
        create("rusco") {
            dimension      = "app"
            applicationId  = "id.co.twka.fms.driver.rusco"
            resValue("string", "app_name", "Rusco Driver")
        }
        create("tka") {
            dimension      = "app"
            applicationId  = "id.co.twka.fms.driver"
            resValue("string", "app_name", "OttoGo Driver")
        }
    }

    buildTypes {
        getByName("debug")   { signingConfig = signingConfigs.getByName("debug") }
        getByName("release") { signingConfig = signingConfigs.getByName("debug") }
    }

    // ─── Java & Desugaring ─────────────────────────────────────────────────────
    compileOptions {
        sourceCompatibility          = JavaVersion.VERSION_11        // atau 17
        targetCompatibility          = JavaVersion.VERSION_11
        isCoreLibraryDesugaringEnabled = true        // ⬅️ pakai *is* + tanda '='
    }
    kotlinOptions {
        jvmTarget = JavaVersion.VERSION_11.toString()
    }
}

dependencies {
    // ⬅️ panggil fungsi, bukan assignment ala Groovy
    coreLibraryDesugaring("com.android.tools:desugar_jdk_libs:2.1.5")
}

flutter {
    source = "../.."   // tetap
}
