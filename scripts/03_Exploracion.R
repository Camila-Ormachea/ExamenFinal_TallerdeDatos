# ====================================================================================
# Proyecto: Análisis usando los datos de la ENAHO
# Script: Exploración (EDA)
# Autora: Camila Ormachea
# Fecha: 12-07-2026
# Objetivo: Preparar variables etiquetadas y realizar el análisis descriptivo
#           de las características demográficas y de vivienda antes de clasificarlas
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

# Cargamos la base de datos limpia (del script de Acondicinamiento)
enaho_acondicionada <- read_parquet(here("datos", "procesados", "enaho_2025_acondicionada.parquet"))

# ------------------------------------------------------------------------------
# 2. PREPARACIÓN DE ETIQUETAS
# ------------------------------------------------------------------------------

#Crecaión de la nueva base para explorar
enaho_explorar <- enaho_acondicionada %>%
  mutate(
    
    #=======================
    # Variables demográficas
    #=======================
    sexo_etiqueta = factor(
      sexo,
      levels = c(1, 2),
      labels = c("Hombre", "Mujer")
    ),
    
    parentesco_etiqueta = factor(
      parentesco,
      levels = 1:11,
      labels = c(
        "Jefe(a)",
        "Esposo(a)/Conviviente",
        "Hijo(a)/Hijastro",
        "Yerno/Nuera",
        "Nieto(a)",
        "Padres/Suegros",
        "Otro pariente",
        "Trabajador del hogar",
        "Pensionista",
        "Otro no parientes",
        "Hermano(a)"
      )
    ),
    
    estado_civil_etiqueta = factor(
      estado_civil,
      levels = c(1,2,3,4,5,6),
      labels = c(
        "Conviviente",
        "Casado(a)",
        "Vuido(a)",
        "Divorciado(a)",
        "Separado(a)",
        "Soltero(a)"
      )
    ),
    
    #===============================
    # Características de la vivienda
    #===============================
    
    tipo_vivienda_etiqueta = factor(
      tipo_vivienda,
      levels = 1:8,
      labels = c(
        "Casa independiente",
        "Departamento",
        "Vivienda en quinta",
        "Casa de vecindad",
        "Choza o cabaña",
        "Vivienda improvisada",
        "Local no destinado para habitación humana",
        "Otro"
      )
    ),
    
    material_pared_etiqueta = factor(
      material_pared,
      levels = 1:9,
      labels = c(
        "Ladrillo/Bloque de cemento",
        "Piedra o sillar",
        "Adobe",
        "Tapia",
        "Quincha",
        "Piedra con barro",
        "Madera",
        "Triplay/Calamina/Estera",
        "Otro material"
      )
    ),
    
    ocupacion_vivienda_etiqueta = factor(
      ocupacion_vivienda,
      levels = 1:7,
      labels = c(
        "Alquilada",
        "Propia pagada",
        "Propia por invasión",
        "Propia a plazos",
        "Cedida por trabajo",
        "Cedida por otro hogar/institución",
        "Otra forma"
      )
    ),
    
    abastecimiento_agua_etiqueta = factor(
      abastecimiento_agua,
      levels = c(1,2,3,4,5,6,7,8),
      labels = c(
        "Red pública dentro de la vivienda",
        "Red pública fuera de la vivienda",
        "Pilón/pileta público",
        "Camión cisterna",
        "Pozo",
        "Manantial",
        "Otra fuente",
        "Río/Acequia/Lago"
      )
    ),
    
    servicio_higienico_etiqueta = factor(
      servicio_higienico,
      levels = c(1,2,3,4,5,6,7,9),
      labels = c(
        "Red pública de desague dentro de la vivienda",
        "Red pública de desague fuera de la vivienda",
        "Letrina",
        "Pozo séptico",
        "Pozo ciego",
        "Río/Acequia",
        "Otro",
        "Campo abierto"
      )
    ),
    
    electricidad_etiqueta = factor(
      electricidad,
      levels = c(0,1),
      labels = c("No electricidad","Sí electricidad")
    ),
    
    #=========================
    # Necesidades Básicas Insatisfechas (NBI)
    #=========================
    
    vivienda_inadecuada_etiqueta = factor(
      vivienda_inadecuada,
      levels = c(0,1),
      labels = c("Vivienda adecuada","Vivienda inadecuada")
    ),
    
    hacinamiento_etiqueta = factor(
      hacinamiento,
      levels = c(0,1),
      labels = c("Vivienda sin hacinamiento","Vivienda con hacinamiento")
    ),
    
    hogar_sin_sshh_etiqueta = factor(
      hogarsin_servicio_higienico,
      levels = c(0,1),
      labels = c("Vivienda con servicios higiénicos","Vivienda sin servicios higiénicos")
    ),
    
    ninos_no_escolarizados_etiqueta = factor(
      ninos_no_escolarizados,
      levels = c(0,1),
      labels = c("Niños que asisten a la escuela","Niños que no asisten a la escuela")
    ),
    
    alta_dependencia_etiqueta = factor(
      alta_dependencia_economica,
      levels = c(0,1),
      labels = c("Sin alta dependencia económica","Con alta dependencia económica")
    )
  )

#Guardar la base de datos con las etiquetas creadas 
write_parquet(enaho_explorar, "datos/procesados/enaho_exploracion.parquet")
