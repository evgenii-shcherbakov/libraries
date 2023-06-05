val GROUP: String by project
val VERSION_NAME: String by project

plugins {
    `java-library`
    kotlin("jvm") version "1.8.21"
    id("com.vanniktech.maven.publish") version "0.25.2"
}

val groupId: String = GROUP.replace('-', '_')

group = groupId
version = VERSION_NAME

repositories {
    mavenCentral()
}

dependencies {
    testImplementation(kotlin("test"))
}

tasks.test {
    useJUnitPlatform()
}

tasks.javadoc {
    if (JavaVersion.current().isJava9Compatible) {
        (options as StandardJavadocDocletOptions).addBooleanOption("html5", true)
    }
}

kotlin {
    jvmToolchain(11)
}
