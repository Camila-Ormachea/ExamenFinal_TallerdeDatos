#==============================================================================
#Proyecto: Análisis usando datos de la ENAHO
#Autora: Camila Ormachea
#Objetivo de este script: Crear el sistema de carpetas y enlazar con GitHub
#Fecha: 7 de julio del 2026
#==============================================================================

#Creamos carpetas-----------------------------

dir.create("datos")
dir.create("datos/crudos")
dir.create("datos/procesados")
dir.create("outputs")
dir.create("docs")
dir.create("scripts")

#Enlace con Git y GutHub-----------------------

install.packages("gert")
install.packages("usethis")
usethis::use_git_config(
  user.name = "Camila-Ormachea",
  user.email = "a20220717@pucp.edu.pe"
)

install.packages(c("stringi", "rlang", "glue", "gert", "usethis"), dependencies = TRUE)
usethis::create_github_token()
gitcreds::gitcreds_set()
usethis::use_git()
usethis::use_github()

Sys.which("git")

