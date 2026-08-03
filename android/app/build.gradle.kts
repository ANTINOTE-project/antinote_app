plugins {
    id("com.android.application")
    id("dev.flutter.flutter-gradle-plugin")

    id("com.google.protobuf") version "0.10.0"
}

dependencies {
    implementation("androidx.datastore:datastore:1.2.1")
    implementation("androidx.biometric:biometric:1.1.0")
    implementation("com.google.protobuf:protobuf-kotlin-lite:4.35.1")
    implementation("androidx.work:work-runtime-ktx:2.11.2")
}

protobuf {
    protoc {
        artifact = "com.google.protobuf:protoc:4.35.1"
    }
    generateProtoTasks {
        all().forEach { task ->
            task.builtins {
                create("java") {
                    option("lite")
                }
                create("kotlin") {
                    option("lite")
                }
            }
        }
    }
}


android {
    namespace = "fr.antinote.antinote_app"
    compileSdk = flutter.compileSdkVersion
    ndkVersion = flutter.ndkVersion

    compileOptions {
        sourceCompatibility = JavaVersion.VERSION_17
        targetCompatibility = JavaVersion.VERSION_17
    }

    buildFeatures {
        resValues = true
    }

    defaultConfig {
        applicationId = "fr.antinote.antinote_app"
        minSdk = 24
        targetSdk = flutter.targetSdkVersion
        versionCode = flutter.versionCode
        versionName = flutter.versionName
    }

    buildTypes {
        release {
            signingConfig = signingConfigs.getByName("debug")
        }
    }

    flavorDimensions.add("default")

    productFlavors {
        create("dev") {
            dimension = "default"
            applicationIdSuffix = ".dev"
            versionNameSuffix = "-dev"
            resValue("string", "app_name", "ANTINOTE Dev")
        }
        create("prod") {
            dimension = "default"
            resValue("string", "app_name", "ANTINOTE")
        }
    }
}

kotlin {
    compilerOptions {
        jvmTarget = org.jetbrains.kotlin.gradle.dsl.JvmTarget.JVM_17
    }
}

flutter {
    source = "../.."
}
