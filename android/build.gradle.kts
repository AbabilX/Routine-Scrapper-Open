allprojects {
    repositories {
        google()
        mavenCentral()
    }
}

val newBuildDir: Directory =
    rootProject.layout.buildDirectory
        .dir("../../build")
        .get()
rootProject.layout.buildDirectory.value(newBuildDir)

subprojects {
    val newSubprojectBuildDir: Directory = newBuildDir.dir(project.name)
    project.layout.buildDirectory.value(newSubprojectBuildDir)
}
subprojects {
    project.evaluationDependsOn(":app")
}

subprojects {
    val configureAndroid = {
        val androidExt = extensions.findByName("android")
        if (androidExt is com.android.build.api.dsl.CommonExtension) {
            if ((androidExt.compileSdk ?: 0) < 36) {
                androidExt.compileSdk = 36
            }
        } else if (androidExt is com.android.build.gradle.BaseExtension) {
            val currentSdk = androidExt.compileSdkVersion?.removePrefix("android-")?.toIntOrNull() ?: 0
            if (currentSdk < 36) {
                androidExt.compileSdkVersion(36)
            }
        }
    }
    if (state.executed) {
        configureAndroid()
    } else {
        afterEvaluate { configureAndroid() }
    }
}

tasks.register<Delete>("clean") {
    delete(rootProject.layout.buildDirectory)
}
