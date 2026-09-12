allprojects {
    repositories {
        google()
        mavenCentral()
    }
}

// Build output is redirected outside the OneDrive-synced project folder.
// OneDrive's background sync repeatedly locks/corrupts Gradle's build
// intermediates mid-build (file-in-use errors, "not a regular file"
// snapshot failures), so keep all generated build artifacts on a plain
// local path instead of "../../build".
val newBuildDir: Directory =
    layout.projectDirectory.dir("C:/FixNowBuild")
rootProject.layout.buildDirectory.value(newBuildDir)

subprojects {
    val newSubprojectBuildDir: Directory = newBuildDir.dir(project.name)
    project.layout.buildDirectory.value(newSubprojectBuildDir)
}
subprojects {
    project.evaluationDependsOn(":app")
}

tasks.register<Delete>("clean") {
    delete(rootProject.layout.buildDirectory)
}
