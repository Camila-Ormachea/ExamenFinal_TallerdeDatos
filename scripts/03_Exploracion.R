# ====================================================================================
# Proyecto: Análisis usando los datos de la ENAHO
# Script: Exploración (EDA)
# Autora: Camila Ormachea
# Fecha: 12-07-2026
# Objetivo: Describir la distribución original de las variables antes de clasificarlas
# =====================================================================================

# ------------------------------------------------------------------------------
# 0. CONFIGURACIÓN Y CARGA DE DATOS
# ------------------------------------------------------------------------------
library(webshot2)
library(tidyverse)
library(arrow)
library(survey)      
library(srvyr)       
library(flextable)   
library(scales)      
library(officer)
library(here)
renv::snapshot()