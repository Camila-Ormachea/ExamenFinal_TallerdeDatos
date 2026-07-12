# ==============================================================================
# Proyecto: Análisis usando datos de la ENAHO
# Script: Acondicionamiento 
# Autor: Camila Ormachea 
# Fecha: 8-07-2026
# Objetivo: Acondicionar la base de datos consolidada mediante la selección, 
#           renombrado, tipado y diagnóstico de valores perdidos.
# ==============================================================================

# ------------------------------------------------------------------------------
# 0. CONFIGURACIÓN DEL ENTORNO--------------------------------------------------
# ------------------------------------------------------------------------------
library(tidyverse)
library(arrow)
library(janitor)
library(naniar)
renv::snapshot()

# ------------------------------------------------------------------------------
# 1. CARGA, SELECCIÓN, RENOMBRADO Y DIAGNÓSTICO---------------------------------
# ------------------------------------------------------------------------------
# Leemos la base que consolidamos en el script anterior en formato parquet.

enaho_raw <- read_parquet("datos/procesados/enaho_2025_modulos.parquet")

#Selección de las variables de interés para trabajar con una base menos pesada
#Al mismo tiempo que seleccionamos, renombramos usando las herramientas de dplyr

enaho_seleccion <- enaho_raw %>%
  select(
    # Llaves de integración y variables identificadoras 
    año = AÑO,
    mes = MES,
    conglome = CONGLOME, 
    subconglome = SUB_CONGLOME,
    vivienda = VIVIENDA, 
    hogar    = HOGAR, 
    codperso  = CODPERSO, 
    ubigeo   = UBIGEO, 
    dominio  = DOMINIO, 
    estrato  = ESTRATO, 
    factorpob07 = FACPOB07,
    factor07 = FACTOR07,

    #Características demográficas (módulo 200)
    parentesco = P203,
    sexo = P207,
    edad = P208A,
    estado_civil = P209,
    
    #Características de la vivienda (módulo 100)
    tipo_vivienda = P101,
    material_pared = P102,
    ocupacion_vivienda = P105A,
    
    #Servicios básicos (módulo 100)
    abastecimiento_agua = P110,
    servicio_higienico = P111A,
    electricidad = P1121,
    
    #Necesidades básicas insatisfechas (módulo 100)
    vivienda_inadecuada = NBI1,
    hacinamiento = NBI2,
    hogarsin_servicio_higienico = NBI3,
    ninos_no_escolarizados = NBI4,
    alta_dependencia_economica = NBI5
    
  )

# ------------------------------------------------------------------------------
# 2. TIPADO---------------------------------------------------------------------
# ------------------------------------------------------------------------------

#Los factores de expansión fueron importados como texto debido al uso de coma
# como separador decimal en los archivos originales. Se convierten a formato
# numérico para su correcto uso.

enaho_seleccion <- enaho_seleccion %>%
  mutate(
    factorpob07 = as.numeric(str_replace_all(factorpob07, ",", ".")),
    factor07 = as.numeric(str_replace_all(factor07, ",", "."))
  )

glimpse(enaho_seleccion)

#Filtración de registros sin información individual
#Se identificó que 4473 registros correspondían a observaciones sin información 
# individual (P203 = 0), las cuales no representan personas entrevistadas. 
# Dado que la unidad de análisis del estudio son las personas, dichos registros son excluidos 
# de la base analítica antes de realizar el análisis descriptivo.

enaho_seleccion <- enaho_seleccion %>%
  filter(parentesco != 0)

colSums(is.na(enaho_seleccion))


# ------------------------------------------------------------------------------
# 3. INSPECCIÓN GENERAL DE LA BASE
# ------------------------------------------------------------------------------

#Se verifica el tamaño de la base, los nombres de las variables y el tipo de
# dato asignado por R.
dim(enaho_seleccion)        # ¿Cuántas filas y columnas tenemos tras los joins previos?
names(enaho_seleccion)      # Verificamos si los nombres son legibles
glimpse(enaho_seleccion)    # Revisión crítica de cómo R interpretó los tipos de datos
