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
