import java.io.FileInputStream
import java.util.Properties

plugins {
    id("com.android.application")
    id("dev.flutter.flutter-gradle-plugin")

    id("com.google.protobuf") version "0.10.0"
}

val keystoreProperties = Properties()
val keystorePropertiesFile = rootProject.file("key.properties")
if (keystorePropertiesFile.exists()) {
    keystoreProperties.load(FileInputStream(keystorePropertiesFile))
}


dependencies {
    implementation("androidx.datastore:datastore:1.2.1")
    implementation("androidx.biometric:biometric:1.1.0")
    implementation("com.google.protobuf:protobuf-kotlin-lite:4.36.0")
    implementation("androidx.work:work-runtime-ktx:2.11.2")
    implementation("androidx.appcompat:appcompat:1.8.0")

    coreLibraryDesugaring("com.android.tools:desugar_jdk_libs:2.1.5")
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


@Suppress("DEPRECATION")
android {
    namespace = "fr.antinote.antinote_app"
    compileSdk = flutter.compileSdkVersion
    ndkVersion = flutter.ndkVersion

    compileOptions {
        isCoreLibraryDesugaringEnabled = true

        sourceCompatibility = JavaVersion.VERSION_17
        targetCompatibility = JavaVersion.VERSION_17
    }

    buildFeatures {
        resValues = true
    }

    defaultConfig {
        applicationId = "fr.antinote.antinote_app"
        minSdk = flutter.minSdkVersion
        targetSdk = flutter.targetSdkVersion
        versionCode = flutter.versionCode
        versionName = flutter.versionName
    }

    signingConfigs {
        create("release") {
            keyAlias = keystoreProperties["keyAlias"] as String
            keyPassword = keystoreProperties["keyPassword"] as String
            storeFile = keystoreProperties["storeFile"]?.let { file(it) }
            storePassword = keystoreProperties["storePassword"] as String
        }
    }

    buildTypes {
        release {
            @Suppress("UnstableApiUsage")
            optimization {
                enable = true
            }

            signingConfig = signingConfigs.getByName("release")
        }
    }

    flavorDimensions.add("default")
    flavorDimensions.add("store")

    productFlavors {
        create("dev") {
            dimension = "default"
            applicationIdSuffix = ".dev"
            versionNameSuffix = "-dev"
            resValue("string", "app_name", "ANTINOTE DEV")
            resValue("string", "account_type", "fr.antinote.antinote_app.dev.account")
        }

        create("prod") {
            dimension = "default"
            resValue("string", "app_name", "ANTINOTE")
        }

        create("playstore") {
            dimension = "store"
            versionNameSuffix = "-play"
        }

        create("independent") {
            dimension = "store"
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
