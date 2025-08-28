// android/build.gradle.kts (Project-level build.gradle.kts)

// -- > // Define buildscript block to configure Gradle itself, including plugin dependencies
buildscript {
    // -- > // Define a variable for the Kotlin version, ensure it's up-to-date
    // -- > // You might need to adjust this based on your Flutter/Kotlin setup (e.g., "1.9.0" or higher)
    val kotlin_version by extra("2.2.10") // Or whatever version your project uses

    // -- > // Define repositories where Gradle can find buildscript dependencies
    repositories {
        google()      // -- > // Google's Maven repository, essential for Android and Firebase
        mavenCentral() // -- > // Maven Central repository
    }
    // -- > // Define dependencies for the buildscript itself
    dependencies {
        // -- > // Android Gradle Plugin (AGP) - essential for building Android apps
        // -- > // Ensure this version is compatible with your Flutter and Android Studio setup (e.g., "8.2.0")
        classpath("com.android.tools.build:gradle:8.2.0")
        // -- > // Kotlin Gradle Plugin - required for Kotlin projects
        classpath("org.jetbrains.kotlin:kotlin-gradle-plugin:$kotlin_version")
        // -- > // Firebase Google Services plugin - THIS IS THE CRUCIAL LINE FOR YOUR ERROR
        // -- > // This tells Gradle where to find the 'com.google.gms.google-services' plugin
        // -- > // Always check Firebase documentation for the latest stable version (e.g., 4.4.1)
        classpath("com.google.gms:google-services:4.4.1")
    }
}

// -- > // Configuration applied to all projects (including app and any modules)
allprojects {
    // -- > // Define repositories for all project dependencies
    repositories {
        google()       // -- > // Google's Maven repository
        mavenCentral() // -- > // Maven Central repository
    }
}

// -- > // Custom build directory configuration
// -- > // Sets the root build directory to 'build' within the project's parent directory
val newBuildDir: Directory = rootProject.layout.buildDirectory.dir("../../build").get()
rootProject.layout.buildDirectory.value(newBuildDir)

// -- > // Custom build directory configuration for subprojects
subprojects {
    // -- > // Sets each subproject's build directory within the new root build directory
    val newSubprojectBuildDir: Directory = newBuildDir.dir(project.name)
    project.layout.buildDirectory.value(newSubprojectBuildDir)
}

// -- > // Ensures that all subprojects are evaluated after the ':app' project
// -- > // This can be useful for dependency ordering in multi-module projects
subprojects {
    project.evaluationDependsOn(":app")
}

// -- > // Defines a 'clean' task to delete the custom build directory
tasks.register<Delete>("clean") {
    delete(rootProject.layout.buildDirectory)
}