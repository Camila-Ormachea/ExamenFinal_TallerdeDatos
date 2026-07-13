# ====================================================================================
# Proyecto: Análisis usando los datos de la ENAHO
# Script: Exploración (EDA)
# Autora: Camila Ormachea
# Fecha: 12-07-2026
# Objetivo: Preparar variables etiquetadas y realizar el análisis descriptivo
#           de las características demográficas y de vivienda antes de clasificarlas
# =====================================================================================

# ------------------------------------------------------------------------------
# 0. CONFIGURACIÓN Y CARGA DE DATOS---------------------------------------------
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
# 2. PREPARACIÓN DE ETIQUETAS---------------------------------------------------
# ------------------------------------------------------------------------------

#Creación de la nueva base para explorar
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
    
    #========================================
    # Necesidades Básicas Insatisfechas (NBI)
    #=======================================
    
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

# ------------------------------------------------------------------------------
# 3. DISEÑO MUESTRAL (PERSONAS)-------------------------------------------------
# ------------------------------------------------------------------------------

# Se define el diseño muestral utilizando el factor de expansión de personas.
# Este diseño se empleará para estimar estadísticos descriptivos representativos
# de la población.

diseno_personas <- enaho_explorar %>%
  as_survey_design(
    ids = conglome,
    strata = estrato,
    weights = factorpob07,
    nest = TRUE
  )

# ------------------------------------------------------------------------------
# 4. CREACIÓN DE LA BASE DE HOGARES---------------------------------------------
# ------------------------------------------------------------------------------

# Las variables de característicsa de vivienda y NBI corresponden al hogar.
# Como cada hogar aparece repetido por cada integrante, se conserva un único
# registro por hogar para evitar duplicaciones.

hogares <- enaho_explorar %>%
  distinct(
    año,
    mes,
    conglome,
    subconglome,
    vivienda,
    hogar,
    .keep_all = TRUE
  )

# ------------------------------------------------------------------------------
# 5. DISEÑO MUESTRAL (HOGARES)--------------------------------------------------
# ------------------------------------------------------------------------------

# Se define el diseño muestral utilizando el factor de expansión de hogares.
# Este diseño se empleará para estimar estadísticos descriptivos representativos
# de la población a nivel de hogar (vivienda, servicios básicos, NBI).

diseno_hogares <- hogares %>%
  as_survey_design(
    ids = conglome,
    strata = estrato,
    weights = factor07,
    nest = TRUE
  )


# ------------------------------------------------------------------------------
# 6. ESTADÍSTICOS DESCRIPTIVOS--------------------------------------------------
# ------------------------------------------------------------------------------

#-------------------------------------------------------------------------------
# 6.1 VARIABLES DEMOGRÁFICAS----------------------------------------------------
#-------------------------------------------------------------------------------

# ---------------------------------------
# Distribución de la población según sexo
# ---------------------------------------

tabla_sexo <- diseno_personas %>%
  group_by(sexo_etiqueta) %>%
  summarise(
    poblacion = survey_total(),
    porcentaje = survey_mean(vartype = NULL)
  )

tabla_sexo

# ------------------------------------
# Estadísticos descriptivos de la edad
# ------------------------------------

edad_promedio <- diseno_personas %>%
  summarise(
    edad_promedio = survey_mean(edad),
    edad_mediana = survey_median(edad)
  )

edad_promedio

# -------------------------------
# Distribución según estado civil
# -------------------------------

#Se excluyen los menores de 12 años porque la pregunta no les corresponde.
tabla_estado_civil <- diseno_personas %>%
  filter(!is.na(estado_civil_etiqueta)) %>%
  group_by(estado_civil_etiqueta) %>%
  summarise(
    poblacion = survey_total(),
    porcentaje = survey_mean(vartype = NULL)
  )

tabla_estado_civil

# ---------------------------------------------------
# Distribución según parentesco con el jefe del hogar
# ---------------------------------------------------

tabla_parentesco <- diseno_personas %>%
  group_by(parentesco_etiqueta) %>%
  summarise(
    poblacion = survey_total(),
    porcentaje = survey_mean(vartype = NULL)
  )

tabla_parentesco

#-------------------------------------------------------------------------------
# 6.2 VARIABLES DE VIVIENDA-----------------------------------------------------
#-------------------------------------------------------------------------------

# --------------------------------------------------
# Distribución de los hogares según tipo de vivienda
# --------------------------------------------------

tabla_tipo_vivienda <- diseno_hogares %>%
  filter(!is.na(tipo_vivienda_etiqueta)) %>%
  group_by(tipo_vivienda_etiqueta) %>%
  summarise(
    hogares = survey_total(),
    porcentaje = survey_mean(vartype = NULL)
  )

tabla_tipo_vivienda

# ----------------------------------------------------------------------
# Distribución de los hogares según material predominante de las paredes
# ----------------------------------------------------------------------

tabla_material_pared <- diseno_hogares %>%
  filter(!is.na(material_pared_etiqueta)) %>%
  group_by(material_pared_etiqueta) %>%
  summarise(
    hogares = survey_total(),
    porcentaje = survey_mean(vartype = NULL)
  )

tabla_material_pared

# ----------------------------------------------------------------
# Distribución de los hogares según disponibilidad de electricidad
# ----------------------------------------------------------------

tabla_electricidad <- diseno_hogares %>%
  filter(!is.na(electricidad_etiqueta)) %>%
  group_by(electricidad_etiqueta) %>%
  summarise(
    hogares = survey_total(),
    porcentaje = survey_mean(vartype = NULL)
  )

tabla_electricidad

# -----------------------------------------------------------------
# Distribución de los hogares según forma de abastecimiento de agua
# -----------------------------------------------------------------

tabla_abastecimiento_agua <- diseno_hogares %>%
  filter(!is.na(abastecimiento_agua_etiqueta)) %>%
  group_by(abastecimiento_agua_etiqueta) %>%
  summarise(
    hogares = survey_total(),
    porcentaje = survey_mean(vartype = NULL)
  )

tabla_abastecimiento_agua

# ----------------------------------------------------------------
# Distribución de los hogares según conexión de servicio higiénico
# ----------------------------------------------------------------

tabla_servicio_higienico <- diseno_hogares %>%
  filter(!is.na(servicio_higienico_etiqueta)) %>%
  group_by(servicio_higienico_etiqueta) %>%
  summarise(
    hogares = survey_total(),
    porcentaje = survey_mean(vartype = NULL)
  )

tabla_servicio_higienico

# ----------------------------------------------------------------
# Distribución de los hogares según forma de ocupación de vivienda
# ----------------------------------------------------------------

tabla_ocupacion_vivienda <- diseno_hogares %>%
  filter(!is.na(ocupacion_vivienda_etiqueta)) %>%
  group_by(ocupacion_vivienda_etiqueta) %>%
  summarise(
    hogares = survey_total(),
    porcentaje = survey_mean(vartype = NULL)
  )

tabla_ocupacion_vivienda

# --------------------------------------------------------
# Distribución de hogares según vivienda inadecuada (NBI1)
# --------------------------------------------------------

tabla_vivienda_inadecuada <- diseno_hogares %>%
  filter(!is.na(vivienda_inadecuada_etiqueta)) %>%
  group_by(vivienda_inadecuada_etiqueta) %>%
  summarise(
    hogares = survey_total(),
    porcentaje = survey_mean(vartype = NULL)
  )

tabla_vivienda_inadecuada

# --------------------------------------------------------------
# Distribución de hogares según condición de hacinamiento (NBI2)
# --------------------------------------------------------------

tabla_hacinamiento <- diseno_hogares %>%
  filter(!is.na(hacinamiento_etiqueta)) %>%
  group_by(hacinamiento_etiqueta) %>%
  summarise(
    hogares = survey_total(),
    porcentaje = survey_mean(vartype = NULL)
  )

tabla_hacinamiento

# ---------------------------------------------------------------------------
# Distribución de hogares según disponibilidad de servicios higiénicos (NBI3)
# ---------------------------------------------------------------------------

tabla_hogar_servicios_higienicos <- diseno_hogares %>%
  filter(!is.na(hogar_sin_sshh_etiqueta)) %>%
  group_by(hogar_sin_sshh_etiqueta) %>%
  summarise(
    hogares = survey_total(),
    porcentaje = survey_mean(vartype = NULL)
  )

tabla_hogar_servicios_higienicos

# -------------------------------------------------------------------
# Distribución de hogares con niños que no asisten a la escuela (NBI4)
# -------------------------------------------------------------------

tabla_ninos_no_escolarizados <- diseno_hogares %>%
  filter(!is.na(ninos_no_escolarizados_etiqueta)) %>%
  group_by(ninos_no_escolarizados_etiqueta) %>%
  summarise(
    hogares = survey_total(),
    porcentaje = survey_mean(vartype = NULL)
  )

tabla_ninos_no_escolarizados

# ---------------------------------------------------------------
# Distribución de hogares según alta dependencia económica (NBI5)
# ---------------------------------------------------------------

tabla_dependencia_eco <- diseno_hogares %>%
  filter(!is.na(alta_dependencia_etiqueta)) %>%
  group_by(alta_dependencia_etiqueta) %>%
  summarise(
    hogares = survey_total(),
    porcentaje = survey_mean(vartype = NULL)
  )

tabla_dependencia_eco

#---------------------------------------------
# Exportación de los estadísticos descriptivos
#---------------------------------------------

## Aplica el formateo de porcentaje y población a todas las tablas de un jalón
formatear_tabla <- function(tabla) {
  tabla %>%
    mutate(across(any_of(c("poblacion", "hogares")), scales::comma)) %>%
    mutate(porcentaje = scales::percent(porcentaje, accuracy = 0.1))
}

tabla_sexo <- formatear_tabla(tabla_sexo)
tabla_estado_civil <- formatear_tabla(tabla_estado_civil)
tabla_parentesco <- formatear_tabla(tabla_parentesco)
tabla_tipo_vivienda <- formatear_tabla(tabla_tipo_vivienda)
tabla_material_pared <- formatear_tabla(tabla_material_pared)
tabla_electricidad <- formatear_tabla(tabla_electricidad)
tabla_abastecimiento_agua <- formatear_tabla(tabla_abastecimiento_agua)
tabla_servicio_higienico <- formatear_tabla(tabla_servicio_higienico)
tabla_ocupacion_vivienda <- formatear_tabla(tabla_ocupacion_vivienda)
tabla_vivienda_inadecuada <- formatear_tabla(tabla_vivienda_inadecuada)
tabla_hacinamiento <- formatear_tabla(tabla_hacinamiento)
tabla_hogar_servicios_higienicos <- formatear_tabla(tabla_hogar_servicios_higienicos)
tabla_ninos_no_escolarizados <- formatear_tabla(tabla_ninos_no_escolarizados)
tabla_dependencia_eco <- formatear_tabla(tabla_dependencia_eco)

#Delimitar la ruta de salida de los gráficos realizados
ruta_salida_tablas <- here("outputs", "outputs_exploracion_inicial")

if (!dir.exists(ruta_salida_tablas)) {
  dir.create(ruta_salida_tablas, recursive = TRUE)
}

# Función simple para dar formato consistente a las tablas
formato_tabla <- function(tabla, titulo) {
  flextable(tabla) %>%
    set_caption(titulo) %>%
    theme_vanilla() %>%
    autofit() %>%
    bg(part = "header", bg = "#4A7C59") %>%
    color(part = "header", color = "white") %>%
    bold(part = "header")
}

# Demográficas
ft_sexo <- formato_tabla(tabla_sexo, "Tabla 1. Distribución de la población según sexo")
ft_edad <- formato_tabla(edad_promedio, "Tabla 2. Estadísticos descriptivos de la edad")
ft_estado_civil <- formato_tabla(tabla_estado_civil, "Tabla 3. Distribución de la población según estado civil")
ft_parentesco <- formato_tabla(tabla_parentesco, "Tabla 4. Distribución de la población según parentesco")

# Vivienda
ft_tipo_vivienda <- formato_tabla(tabla_tipo_vivienda, "Tabla 5. Distribución de hogares según tipo de vivienda")
ft_material_pared <- formato_tabla(tabla_material_pared, "Tabla 6. Distribución de hogares según material de las paredes")
ft_electricidad <- formato_tabla(tabla_electricidad, "Tabla 7. Distribución de hogares según electricidad")
ft_agua <- formato_tabla(tabla_abastecimiento_agua, "Tabla 8. Distribución de hogares según abastecimiento de agua")
ft_sshh <- formato_tabla(tabla_servicio_higienico, "Tabla 9. Distribución de hogares según servicio higiénico")
ft_ocupacion <- formato_tabla(tabla_ocupacion_vivienda, "Tabla 10. Distribución de hogares según ocupación de vivienda")

# NBI
ft_vivienda_inadecuada <- formato_tabla(tabla_vivienda_inadecuada, "Tabla 11. Hogares según vivienda inadecuada (NBI 1)")
ft_hacinamiento <- formato_tabla(tabla_hacinamiento, "Tabla 12. Hogares según hacinamiento (NBI 2)")
ft_hogar_sshh <- formato_tabla(tabla_hogar_servicios_higienicos, "Tabla 13. Hogares según servicio higiénico (NBI 3)")
ft_ninos_escolar <- formato_tabla(tabla_ninos_no_escolarizados, "Tabla 14. Hogares con niños no escolarizados (NBI 4)")
ft_dependencia <- formato_tabla(tabla_dependencia_eco, "Tabla 15. Hogares según alta dependencia económica (NBI 5)")

# Exportación masiva de las tablas
save_as_image(ft_sexo,               path = file.path(ruta_salida_tablas, "Tabla1_Sexo.png"))
save_as_image(ft_edad,               path = file.path(ruta_salida_tablas, "Tabla2_Edad.png"))
save_as_image(ft_estado_civil,       path = file.path(ruta_salida_tablas, "Tabla3_EstadoCivil.png"))
save_as_image(ft_parentesco,         path = file.path(ruta_salida_tablas, "Tabla4_Parentesco.png"))
save_as_image(ft_tipo_vivienda,      path = file.path(ruta_salida_tablas, "Tabla5_TipoVivienda.png"))
save_as_image(ft_material_pared,     path = file.path(ruta_salida_tablas, "Tabla6_MaterialPared.png"))
save_as_image(ft_electricidad,       path = file.path(ruta_salida_tablas, "Tabla7_Electricidad.png"))
save_as_image(ft_agua,               path = file.path(ruta_salida_tablas, "Tabla8_Agua.png"))
save_as_image(ft_sshh,               path = file.path(ruta_salida_tablas, "Tabla9_ServicioHigienico.png"))
save_as_image(ft_ocupacion,          path = file.path(ruta_salida_tablas, "Tabla10_OcupacionVivienda.png"))
save_as_image(ft_vivienda_inadecuada,path = file.path(ruta_salida_tablas, "Tabla11_NBI1_ViviendaInadecuada.png"))
save_as_image(ft_hacinamiento,       path = file.path(ruta_salida_tablas, "Tabla12_NBI2_Hacinamiento.png"))
save_as_image(ft_hogar_sshh,         path = file.path(ruta_salida_tablas, "Tabla13_NBI3_ServicioHigienico.png"))
save_as_image(ft_ninos_escolar,      path = file.path(ruta_salida_tablas, "Tabla14_NBI4_NinosEscolarizados.png"))
save_as_image(ft_dependencia,        path = file.path(ruta_salida_tablas, "Tabla15_NBI5_DependenciaEconomica.png"))


# ------------------------------------------------------------------------------
# 7. EXPLORACIÓN UNIVARIADA: GRÁFICOS-------------------------------------------
# ------------------------------------------------------------------------------

# ---------------------------------------------------------------------
# 7.1 VARIABLES DEMOGRÁFICAS (nivel persona, ponderado con factorpob07)
# ---------------------------------------------------------------------

# Histograma: Edad
plot_edad <- ggplot(enaho_explorar %>% filter(!is.na(edad)),
                    aes(x = edad, weight = factorpob07)) +
  geom_histogram(fill = "#4A7C59", color = "white", binwidth = 5) +
  scale_y_continuous(labels = scales::comma) +
  labs(title = "Gráfico 1. Distribución de la edad de la población",
       x = "Edad (años)", y = "Frecuencia poblacional",
       caption = "Fuente: ENAHO 2025. Cálculos ajustados a nivel poblacional.") +
  theme_minimal()
print(plot_edad)

# Gráfico de barras: Sexo
plot_sexo <- ggplot(enaho_explorar %>% filter(!is.na(sexo_etiqueta)),
                    aes(x = sexo_etiqueta, weight = factorpob07)) +
  geom_bar(fill = "#2E5B88") +
  scale_y_continuous(labels = scales::comma) +
  labs(title = "Gráfico 2. Distribución de la población según sexo",
       x = "Sexo", y = "Frecuencia poblacional",
       caption = "Fuente: ENAHO 2025. Cálculos ajustados a nivel poblacional.") +
  theme_minimal()
print(plot_sexo)

# Gráfico de barras: Estado civil
plot_estado_civil <- ggplot(enaho_explorar %>% filter(!is.na(estado_civil_etiqueta)),
                            aes(x = estado_civil_etiqueta, weight = factorpob07)) +
  geom_bar(fill = "#E69F00") +
  scale_y_continuous(labels = scales::comma) +
  labs(title = "Gráfico 3. Distribución de la población según estado civil",
       x = "Estado civil", y = "Frecuencia poblacional",
       caption = "Fuente: ENAHO 2025. Cálculos ajustados a nivel poblacional.") +
  theme_minimal() +
  theme(axis.text.x = element_text(angle = 45, hjust = 1))
print(plot_estado_civil)

# Gráfico de barras: Parentesco
plot_parentesco <- ggplot(enaho_explorar %>% filter(!is.na(parentesco_etiqueta)),
                          aes(x = parentesco_etiqueta, weight = factorpob07)) +
  geom_bar(fill = "#8B5A8C") +
  scale_y_continuous(labels = scales::comma) +
  labs(title = "Gráfico 4. Distribución de la población según parentesco con el jefe de hogar",
       x = "Parentesco", y = "Frecuencia poblacional",
       caption = "Fuente: ENAHO 2025. Cálculos ajustados a nivel poblacional.") +
  theme_minimal() +
  theme(axis.text.x = element_text(angle = 45, hjust = 1))
print(plot_parentesco)

# ---------------------------------------------------------------
# 7.2 VARIABLES DE VIVIENDA (nivel hogar, ponderado con factor07)
# ---------------------------------------------------------------

vars_vivienda <- c(
  "tipo_vivienda_etiqueta",
  "material_pared_etiqueta",
  "ocupacion_vivienda_etiqueta",
  "abastecimiento_agua_etiqueta",
  "servicio_higienico_etiqueta",
  "electricidad_etiqueta"
)

titulos_vivienda <- c(
  tipo_vivienda_etiqueta       = "Gráfico 5. Distribución de hogares según tipo de vivienda",
  material_pared_etiqueta      = "Gráfico 6. Distribución de hogares según material de las paredes",
  ocupacion_vivienda_etiqueta  = "Gráfico 7. Distribución de hogares según ocupación de la vivienda",
  abastecimiento_agua_etiqueta = "Gráfico 8. Distribución de hogares según abastecimiento de agua",
  servicio_higienico_etiqueta  = "Gráfico 9. Distribución de hogares según servicio higiénico",
  electricidad_etiqueta        = "Gráfico 10. Distribución de hogares según acceso a electricidad"
)

graficos_vivienda <- map(vars_vivienda, function(var) {
  ggplot(hogares %>% filter(!is.na(.data[[var]])),
         aes(x = .data[[var]], weight = factor07)) +
    geom_bar(fill = "#4A7C59") +
    scale_y_continuous(labels = scales::comma) +
    labs(title = titulos_vivienda[[var]],
         x = NULL, y = "Frecuencia de hogares",
         caption = "Fuente: ENAHO 2025. Cálculos ajustados a nivel de hogar.") +
    theme_minimal() +
    theme(axis.text.x = element_text(angle = 45, hjust = 1))
})
names(graficos_vivienda) <- vars_vivienda

print(graficos_vivienda[["tipo_vivienda_etiqueta"]])
print(graficos_vivienda[["material_pared_etiqueta"]])
print(graficos_vivienda[["ocupacion_vivienda_etiqueta"]])
print(graficos_vivienda[["abastecimiento_agua_etiqueta"]])
print(graficos_vivienda[["servicio_higienico_etiqueta"]])
print(graficos_vivienda[["electricidad_etiqueta"]])

# -----------------------------------------------------------------------------
# 7.3 NECESIDADES BÁSICAS INSATISFECHAS (NBI) - Gráfico combinado (nivel hogar)
# -----------------------------------------------------------------------------

resumen_nbi <- diseno_hogares %>%
  summarise(
    vivienda_inadecuada = survey_mean(vivienda_inadecuada_etiqueta == "Vivienda inadecuada", na.rm = TRUE) * 100,
    hacinamiento = survey_mean(hacinamiento_etiqueta == "Vivienda con hacinamiento", na.rm = TRUE) * 100,
    sin_servicio_higienico = survey_mean(hogar_sin_sshh_etiqueta == "Vivienda sin servicios higiénicos", na.rm = TRUE) * 100,
    ninos_no_escolarizados = survey_mean(ninos_no_escolarizados_etiqueta == "Niños que no asisten a la escuela", na.rm = TRUE) * 100,
    alta_dependencia_economica = survey_mean(alta_dependencia_etiqueta == "Con alta dependencia económica", na.rm = TRUE) * 100
  ) %>%
  select(-ends_with("_se")) %>%
  pivot_longer(everything(), names_to = "nbi", values_to = "porcentaje") %>%
  mutate(nbi = recode(nbi,
                      "vivienda_inadecuada" = "Vivienda inadecuada (NBI 1)",
                      "hacinamiento" = "Hacinamiento (NBI 2)",
                      "sin_servicio_higienico" = "Sin servicio higiénico (NBI 3)",
                      "ninos_no_escolarizados" = "Niños no escolarizados (NBI 4)",
                      "alta_dependencia_economica" = "Alta dependencia económica (NBI 5)"
  ))

plot_nbi <- ggplot(resumen_nbi, aes(x = reorder(nbi, porcentaje), y = porcentaje)) +
  geom_col(fill = "#D73027") +
  geom_text(aes(label = paste0(round(porcentaje, 1), "%")), hjust = -0.1, size = 3.5) +
  coord_flip(clip = "off") +
  scale_y_continuous(labels = scales::comma, expand = expansion(mult = c(0, 0.15))) +
  labs(title = "Gráfico 11. Porcentaje de hogares con Necesidades Básicas Insatisfechas (NBI)",
       x = NULL, y = "Porcentaje de hogares (%)",
       caption = "Fuente: ENAHO 2025. Cálculos ajustados a nivel de hogar.") +
  theme_minimal()
print(plot_nbi)


# -----------------------
# EXPORTACIÓN DE GRÁFICOS
# -----------------------

ruta_salida <- here("outputs", "outputs_exploracion_univariada")

if (!dir.exists(ruta_salida)) {
  dir.create(ruta_salida, recursive = TRUE)
}

ggsave(file.path(ruta_salida, "Grafico1_Edad.png"), plot = plot_edad, width = 8, height = 5, bg = "white")
ggsave(file.path(ruta_salida, "Grafico2_Sexo.png"), plot = plot_sexo, width = 8, height = 5, bg = "white")
ggsave(file.path(ruta_salida, "Grafico3_EstadoCivil.png"), plot = plot_estado_civil, width = 8, height = 5, bg = "white")
ggsave(file.path(ruta_salida, "Grafico4_Parentesco.png"), plot = plot_parentesco, width = 8, height = 5, bg = "white")

iwalk(graficos_vivienda, function(plot, nombre) {
  ggsave(file.path(ruta_salida, paste0("Grafico_", nombre, ".png")),
         plot = plot, width = 8, height = 5, bg = "white")
})

ggsave(file.path(ruta_salida, "Grafico11_NBI.png"), plot = plot_nbi, width = 8, height = 5, bg = "white")
