# ==============================================================================
# Proyecto: Análisis usando datos de la ENAHO 2025
# Script: Clasificar
# Autor: Camila Ormachea
# Fecha: 12-07-2026
# Objetivo: Crear variables analíticas (índices y tipologías) a partir de las
#           Necesidades Básicas Insatisfechas (NBI) y otras variables de interés.
# ==============================================================================

# ------------------------------------------------------------------------------
# 0. CONFIGURACIÓN Y CARGA DE DATOS---------------------------------------------
# ------------------------------------------------------------------------------
library(tidyverse)
library(arrow)
library(survey)
library(srvyr)
library(here)
library(gtsummary)
library(flextable)
renv::snapshot()

