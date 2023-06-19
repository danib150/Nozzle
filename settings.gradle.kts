rootProject.name = "Nozzle"

this.setupSubproject("nozzle-server", "Nozzle-Server")
this.setupSubproject("nozzle-api", "Nozzle-API")

fun setupSubproject(name: String, dir: String) {
    include(":$name")
    project(":$name").projectDir = file(dir)
}