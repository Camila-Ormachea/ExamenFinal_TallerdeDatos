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

# Cargamos la base con etiquetas (del script de Exploración), ya que necesitamos
# las variables _etiqueta para construir el índice de NBI de forma segura.
enaho_explorar <- read_parquet(here("datos", "procesados", "enaho_exploracion.parquet"))

# ==============================================================================
# 1. PREPARACIÓN DE VARIABLES ANALÍTICAS----------------------------------------
# ==============================================================================

enaho_analitica <- enaho_explorar %>%
  mutate(
    
    # --------------------------------------------------------------------------
    # A. Índice de Necesidades Básicas Insatisfechas (NBI) --------- ÍNDICE
    # --------------------------------------------------------------------------
    # Cada NBI está codificada 0 = no tiene la carencia, 1 = sí tiene la carencia según 
    # el diccionario de la ENAHO. Se construye a partir de las variables _etiqueta
    # para mayor seguridad ante cambios de codificación.
    
    num_nbi = (vivienda_inadecuada_etiqueta == "Vivienda inadecuada") +
      (hacinamiento_etiqueta == "Vivienda con hacinamiento") +
      (hogar_sin_sshh_etiqueta == "Vivienda sin servicios higiénicos") +
      (ninos_no_escolarizados_etiqueta == "Niños que no asisten a la escuela") +
      (alta_dependencia_etiqueta == "Con alta dependencia económica"),
    
    # --------------------------------------------------------------------------
    # B. Clasificación de pobreza por NBI --------- TIPOLOGÍA
    # --------------------------------------------------------------------------
    # Criterio estándar INEI: un hogar es "pobre" por NBI si tiene 1 o más
    # carencias insatisfechas.
    
    clasificacion_pobreza_nbi = case_when(
      num_nbi == 0 ~ "No pobre (0 NBI)",
      num_nbi == 1 ~ "Pobre (1 NBI)",
      num_nbi >= 2 ~ "Pobre extremo (2+ NBI)",
      TRUE ~ NA_character_
    ),
    
    # --------------------------------------------------------------------------
    # C. Demográficas y sociales --------- RECODIFICACIONES
    # --------------------------------------------------------------------------
    # sexo_etiqueta ya viene lista desde enaho_explorar, no hace falta recrearla.
    
    # Recodificación guiada por la TEORÍA (cortes fijos, ciclo de vida)
    grupo_edad_teoria = case_when(
      edad < 18 ~ "Menor de edad (0-17)",
      edad < 30 ~ "Joven (18-29)",
      edad < 60 ~ "Adulto (30-59)",
      TRUE ~ "Adulto mayor (60+)"
    ),
    
    # Recodificación guiada por los DATOS (terciles de edad)
    grupo_edad_datos = ntile(edad, 3),
    
    # --------------------------------------------------------------------------
    # D. Tipología combinada: Vivienda x Acceso a servicios --------- TIPOLOGÍA
    # --------------------------------------------------------------------------
    # Cruza si el hogar tiene vivienda adecuada con si tiene acceso a agua y
    # electricidad, como aproximación de "condición habitacional integral".
    # Se construye a partir de las variables _etiqueta ya validadas.
    
    acceso_basico = case_when(
      abastecimiento_agua_etiqueta == "Red pública dentro de la vivienda" & electricidad_etiqueta == "Sí electricidad" ~ "Con agua y electricidad",
      abastecimiento_agua_etiqueta == "Red pública dentro de la vivienda" & electricidad_etiqueta == "No electricidad" ~ "Solo con agua",
      abastecimiento_agua_etiqueta != "Red pública dentro de la vivienda" & electricidad_etiqueta == "Sí electricidad" ~ "Solo con electricidad",
      TRUE ~ "Sin agua ni electricidad"
    ),
    
    condicion_habitacional = case_when(
      vivienda_inadecuada_etiqueta == "Vivienda adecuada" & acceso_basico == "Con agua y electricidad" ~ "1. Vivienda óptima",
      vivienda_inadecuada_etiqueta == "Vivienda adecuada" & acceso_basico != "Con agua y electricidad" ~ "2. Vivienda adecuada, servicios limitados",
      vivienda_inadecuada_etiqueta == "Vivienda inadecuada" & acceso_basico == "Con agua y electricidad" ~ "3. Vivienda inadecuada, con servicios",
      vivienda_inadecuada_etiqueta == "Vivienda inadecuada" & acceso_basico != "Con agua y electricidad" ~ "4. Vivienda precaria integral",
      TRUE ~ NA_character_
    )
  )

# Actualizamos el diseño muestral con la nueva base analítica (nivel personas)
enaho_diseno_analitico <- enaho_analitica %>%
  filter(!is.na(factorpob07)) %>%
  as_survey_design(ids = conglome, strata = estrato, weights = factorpob07, nest = TRUE)

# ==============================================================================
# 2. EXPORTAR BASE DE DATOS ANALÍTICA
# ==============================================================================

write_parquet(
  enaho_analitica,
  here("datos", "procesados", "enaho_2025_analitica.parquet")
)

# ==============================================================================
# 3. REPORTE DE VARIABLES RECODIFICADAS-----------------------------------------
# ==============================================================================

reporte_clasificar <- enaho_diseno_analitico %>%
  tbl_svysummary(
    include = c(
      num_nbi, clasificacion_pobreza_nbi,
      grupo_edad_teoria, grupo_edad_datos,
      acceso_basico, condicion_habitacional
    ),
    label = list(
      num_nbi ~ "Número de NBI (0 a 5)",
      clasificacion_pobreza_nbi ~ "Clasificación de pobreza por NBI",
      grupo_edad_teoria ~ "Grupo etario (criterio teórico)",
      grupo_edad_datos ~ "Tercil de edad (criterio de datos)",
      acceso_basico ~ "Acceso a servicios básicos",
      condicion_habitacional ~ "Condición habitacional combinada"
    ),
    statistic = list(
      all_categorical() ~ "{n_unweighted} ({p}%)",
      all_continuous() ~ "{mean} ({sd})"
    ),
    digits = all_continuous() ~ 2,
    missing_text = "(Casos perdidos / NA)"
  ) %>%
  modify_header(label = "**Variable Construida / Recodificada**") %>%
  modify_caption("**Reporte de Variables Analíticas - Fase CLASIFICAR (ENAHO 2025)**") %>%
  bold_labels()

reporte_clasificar

# Exportar el reporte a HTML (usando flextable para mantener el formato)
reporte_clasificar %>%
  as_flex_table() %>%
  flextable::save_as_html(path = here("outputs", "CLASIFICAR_Reporte_VariablesCreadas.html"))
