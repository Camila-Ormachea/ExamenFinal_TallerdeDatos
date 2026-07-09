# ==============================================================================
# Proyecto: Análisis usando datos de la ENAHO
# Script: Acondicionamiento 
# Autor: Camila Ormachea 
# Fecha: 8-07-2026
# Objetivo: Acondicionar la base de datos consolidada (Tipado, Selección, 
#           Renombrado, Tratamiento de NAs).
# ==============================================================================

# ------------------------------------------------------------------------------
# 0. CONFIGURACIÓN DEL ENTORNO--------------------------------------------------
# ------------------------------------------------------------------------------
library(tidyverse)
library(arrow)
library(janitor)
library(naniar)
renv::snapshot()

