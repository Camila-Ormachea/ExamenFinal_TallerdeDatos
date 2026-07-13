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




