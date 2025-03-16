// Top-level build file where you can add configuration options common to all sub-projects/modules.
buildscript {
    repositories {
        google()
        mavenCentral()
    }
    dependencies {
        classpath("com.android.tools.build:gradle:8.2.0") // Use the latest stable version
        classpath("org.jetbrains.kotlin:kotlin-gradle-plugin:2.1.0") // Updated Kotlin
        classpath("com.google.gms:google-services:4.4.0") // Firebase Google services plugin
    }
}

allprojects {
    repositories {
        google()
        mavenCentral()
    }
}

// ✅ Ensure subprojects evaluate dependencies correctly
subprojects {
    afterEvaluate {
        if (project.name != "app") {
            evaluationDependsOn(":app")
        }
    }
}

// ✅ Correct way to set custom build directories
val newBuildDir = rootProject.layout.buildDirectory.dir("../../build").get()
rootProject.layout.buildDirectory.set(newBuildDir)

subprojects {
    val newSubprojectBuildDir = newBuildDir.dir(project.name)
    project.layout.buildDirectory.set(newSubprojectBuildDir)
}

// ✅ Clean Task Fix
tasks.register<Delete>("clean") {
    delete(rootProject.layout.buildDirectory)
}
