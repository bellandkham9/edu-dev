// Top-level build file where you can add configuration options common to all sub-projects/modules.

buildscript {
    repositories {
        google()
        mavenCentral()
    }

    dependencies {
        classpath("com.android.tools.build:gradle:7.4.2")
        classpath("com.google.gms:google-services:4.4.2")
    }
}


// Définir un dossier build global optionnel
val newBuildDir = rootProject.layout.buildDirectory.dir("../../build").get()
rootProject.layout.buildDirectory.set(newBuildDir)

subprojects {
    // Définir un dossier build spécifique pour chaque sous-projet
    val newSubprojectBuildDir = newBuildDir.dir(project.name)
    project.layout.buildDirectory.set(newSubprojectBuildDir)

    // Assurer l'évaluation du projet app avant les autres
    project.evaluationDependsOn(":app")
}

// Définir une tâche clean
tasks.register<Delete>("clean") {
    delete(rootProject.layout.buildDirectory)
}

// Configurer repositories pour tous les projets
allprojects {
    repositories {
        google()
        mavenCentral()
    }
}
