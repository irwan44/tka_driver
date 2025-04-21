// File: build.gradle.kts (Root project)

buildscript {
    repositories {
        google()
        mavenCentral()
    }
    dependencies {
        // Versi Gradle plugin Android dan plugin Google Services sesuai kebutuhan Anda
        classpath("com.android.tools.build:gradle:7.4.2")
        classpath("com.google.gms:google-services:4.3.15")
    }
}

allprojects {
    repositories {
        google()
        mavenCentral()
    }
}

// Konfigurasi build directory baru untuk seluruh subproyek
val newBuildDir: Directory = rootProject.layout.buildDirectory.dir("../../build").get()
rootProject.layout.buildDirectory.value(newBuildDir)

subprojects {
    val newSubprojectBuildDir: Directory = newBuildDir.dir(project.name)
    project.layout.buildDirectory.value(newSubprojectBuildDir)
}

subprojects {
    project.evaluationDependsOn(":app")
}

// Daftarkan task clean untuk menghapus build directory yang telah dikonfigurasi
tasks.register<Delete>("clean") {
    delete(rootProject.layout.buildDirectory)
}
