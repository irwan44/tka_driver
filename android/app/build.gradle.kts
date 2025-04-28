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
        applicationId  = "id.co.twka.fms.driver"
        minSdk         = flutter.minSdkVersion
        targetSdk      = flutter.targetSdkVersion
        versionCode    = flutter.versionCode
        versionName    = flutter.versionName
    }

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

    compileOptions {
        sourceCompatibility          = JavaVersion.VERSION_11
        targetCompatibility          = JavaVersion.VERSION_11
        isCoreLibraryDesugaringEnabled = true
    }
    kotlinOptions {
        jvmTarget = JavaVersion.VERSION_11.toString()
    }

    applicationVariants.all {
        val variant = this
        variant.outputs
            .map { it as com.android.build.gradle.internal.api.BaseVariantOutputImpl }
            .filter {
                val names = it.name.split("-")
                it.name.lowercase().contains(names[0], true) && it.name.lowercase().contains(names[1], true)
            }
            .forEach { output ->
                val outputFileName = "${variant.flavorName}Dtiver${variant.buildType.name}_${variant.versionName}.apk"
                output.outputFileName = outputFileName
            }
    }
}

dependencies {
    coreLibraryDesugaring("com.android.tools:desugar_jdk_libs:2.1.5")
}

flutter {
    source = "../.."
}
