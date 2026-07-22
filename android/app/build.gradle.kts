import java.util.Properties
plugins {
    id("com.android.application")
    id("dev.flutter.flutter-gradle-plugin")
}


// Release signing from android/key.properties (not committed).
val keystoreProperties = Properties()
val keystorePropertiesFile = rootProject.file("key.properties")
val hasReleaseSigning = keystorePropertiesFile.exists()
if (hasReleaseSigning) {
    keystorePropertiesFile.inputStream().use { keystoreProperties.load(it) }
}
android {
    namespace = "com.overstein.superhealth"
    compileSdk = flutter.compileSdkVersion
    ndkVersion = flutter.ndkVersion

    compileOptions {
        sourceCompatibility = JavaVersion.VERSION_17
        targetCompatibility = JavaVersion.VERSION_17
        isCoreLibraryDesugaringEnabled = true
    }

    defaultConfig {
        applicationId = "com.overstein.superhealth"
        minSdk = flutter.minSdkVersion
        targetSdk = flutter.targetSdkVersion
        versionCode = flutter.versionCode
        versionName = flutter.versionName
    }

    
    signingConfigs {
        if (hasReleaseSigning) {
            create("release") {
                val storeFilePath = keystoreProperties.getProperty("storeFile")
                    ?: error("key.properties: storeFile is missing")
                keyAlias = keystoreProperties.getProperty("keyAlias")
                    ?: error("key.properties: keyAlias is missing")
                keyPassword = keystoreProperties.getProperty("keyPassword")
                    ?: error("key.properties: keyPassword is missing")
                storePassword = keystoreProperties.getProperty("storePassword")
                    ?: error("key.properties: storePassword is missing")
                storeFile = file(storeFilePath)
            }
        }
    }
buildTypes {
        release {
                        signingConfig = if (hasReleaseSigning) {
                signingConfigs.getByName("release")
            } else {
                signingConfigs.getByName("debug")
            }
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

dependencies {
    coreLibraryDesugaring("com.android.tools:desugar_jdk_libs:2.1.4")
}