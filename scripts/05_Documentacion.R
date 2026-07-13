# ==============================================================================
# Proyecto: Análisis usando datos de la ENAHO
# Script: Documentar
# Autora: Camila Ormachea
# Fecha: 12-07-2026
# Objetivo: Añadir metadatos a la base analítica y generar el codebook final.
# ==============================================================================

# ------------------------------------------------------------------------------
# 0. CONFIGURACIÓN Y PAQUETES
# ------------------------------------------------------------------------------
install.packages(c("labelled", "codebook"))

library(tidyverse)
library(arrow)
library(here)
library(labelled)# Para inyectar etiquetas y metadatos en las variables
library(codebook)  # Para automatizar el libro de códigos interactivo

# Cargamos nuestra base de datos con las etiquetas ya creadas (script de Exploración)
enaho_final <- read_parquet(here("datos", "procesados", "enaho_exploracion.parquet"))

# ==============================================================================
# 1. SELECCIÓN DE VARIABLES PARA EL CODEBOOK
# ==============================================================================

# Creamos una base de datos con las variablesusadas en el reporte descriptivo 
# demografía, vivienda y NBI)

enaho_codebook <- enaho_final %>%
  select(
    edad, sexo_etiqueta, parentesco_etiqueta, estado_civil_etiqueta,
    tipo_vivienda_etiqueta, material_pared_etiqueta, ocupacion_vivienda_etiqueta,
    abastecimiento_agua_etiqueta, servicio_higienico_etiqueta, electricidad_etiqueta,
    vivienda_inadecuada_etiqueta, hacinamiento_etiqueta, hogar_sin_sshh_etiqueta,
    ninos_no_escolarizados_etiqueta, alta_dependencia_etiqueta
  ) %>%
  mutate(across(where(is.character), as.factor)) # Para que "Codebook" detecte nuestras etiquetas

# Exportamos como la base de datos final de nuestro proyecto
write_parquet(enaho_codebook, here("datos", "procesados", "enaho_2025_codebook.parquet"))

# ==============================================================================
# 2. INYECTAMOS LOS METADATOS---------------------------------------------------
# ==============================================================================
# Un codebook requiere la etiqueta descriptiva y la fuente original de cada variable.
# Usamos var_label() para darles un nombre humano y coherente.

# A. Variables demográficas
var_label(enaho_codebook$edad) <- "Edad del encuestado (Fuente: P208A)"
var_label(enaho_codebook$sexo_etiqueta) <- "Sexo del encuestado (Fuente: P207)"
var_label(enaho_codebook$parentesco_etiqueta) <- "Parentesco con el jefe de hogar (Fuente: P203)"
var_label(enaho_codebook$estado_civil_etiqueta) <- "Estado civil del encuestado (Fuente: P209)"

# B. Variables de vivienda
var_label(enaho_codebook$tipo_vivienda_etiqueta) <- "Tipo de vivienda (Fuente: P101)"
var_label(enaho_codebook$material_pared_etiqueta) <- "Material predominante de las paredes (Fuente: P102)"
var_label(enaho_codebook$ocupacion_vivienda_etiqueta) <- "Forma de ocupación de la vivienda (Fuente: P105A)"
var_label(enaho_codebook$abastecimiento_agua_etiqueta) <- "Forma de abastecimiento de agua (Fuente: P110)"
var_label(enaho_codebook$servicio_higienico_etiqueta) <- "Conexión del servicio higiénico (Fuente: P111A)"
var_label(enaho_codebook$electricidad_etiqueta) <- "Disponibilidad de alumbrado eléctrico (Fuente: P1121)"

# C. Variables de Necesidades Básicas Insatisfechas (NBI)
var_label(enaho_codebook$vivienda_inadecuada_etiqueta) <- "Vivienda con características físicas inadecuadas (Fuente: NBI1)"
var_label(enaho_codebook$hacinamiento_etiqueta) <- "Condición de hacinamiento del hogar (Fuente: NBI2)"
var_label(enaho_codebook$hogar_sin_sshh_etiqueta) <- "Vivienda sin servicios higiénicos (Fuente: NBI3)"
var_label(enaho_codebook$ninos_no_escolarizados_etiqueta) <- "Hogares con niños que no asisten a la escuela (Fuente: NBI4)"
var_label(enaho_codebook$alta_dependencia_etiqueta) <- "Hogares con alta dependencia económica (Fuente: NBI5)"




