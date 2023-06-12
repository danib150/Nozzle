plugins {
    `java-library`
    id("com.github.johnrengelman.shadow") version "7.1.1"
}

allprojects {
    group = "org.github.paperspigot"
    version = "1.8.8-R0.1-SNAPSHOT"

    apply {
        plugin("java-library")
        plugin("com.github.johnrengelman.shadow")
    }

    java {
        sourceCompatibility = JavaVersion.VERSION_1_8
        targetCompatibility = JavaVersion.VERSION_1_8

    }

    tasks {
        withType<JavaCompile>().configureEach {
            options.encoding = "UTF-8"
        }
    }

    repositories {
        mavenCentral()
        maven(url = "https://oss.sonatype.org/content/groups/public")
        maven(url = "https://hub.spigotmc.org/nexus/content/groups/public")
    }
}

ext["gitHash"] = project.getCurrentGitHash()

fun Project.getCurrentGitHash(): String {
    val result = exec {
        commandLine("git", "rev-parse", "--short", "HEAD")
    }

    return result.toString().trim()
}