#==============================================================================
#Proyecto: Análisis usando datos de la ENAHO
#Autora: Camila Ormachea
#Objetivo de este script: Cargar los módulos y hacer los joints
#Fecha: 7 de julio del 2026
#==============================================================================

#1. Carga de librerias---------------------------------------------------------

library(rio)
library(tidyverse)
library(janitor)
library(readr)
library(dplyr)
library(tidyr)
library(ggplot2)
library(stringr)
renv::snapshot()

#2. Importar datos-------------------------------------------------------------
mod100 <- import("datos/crudos/Enaho01-2025-100.csv", encoding = "Latin-1")
mod200 <- import ("datos/crudos/Enaho01-2025-200.csv", encoding = "Latin-1")

#3. Unión de bases-------------------------------------------------------------

# Variables que identifican de manera única a cada hogar en la ENAHO.
# Se utilizarán como llaves para unir los módulos a nivel hogar.

keys_hogar <- c(
  "AÑO",
  "MES",
  "CONGLOME",
  "UBIGEO",
  "VIVIENDA",
  "HOGAR",
  "DOMINIO",
  "ESTRATO",
  "SUB_CONGLOME"
)

enaho_2025 <- mod200 |>
  left_join(mod100, by = keys_hogar)

#4. Exportamos base de datos creada--------------------------------------------

install.packages("arrow")
library(arrow)
renv::snapshot()
