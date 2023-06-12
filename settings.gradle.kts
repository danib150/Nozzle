rootProject.name = "paperspigot-parent"

this.setupSubproject("paperspigot-server", "PaperSpigot-Server")
this.setupSubproject("paperspigot-api", "PaperSpigot-API")

fun setupSubproject(name: String, dir: String) {
    include(":$name")
    project(":$name").projectDir = file(dir)
}