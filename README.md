# README: Procesamiento cuantitativo de la caracterización de los hogares peruanos
# Autora: Camila Ormachea Fernández
# Curso: Taller de procesamiento de datos 
# Encuesta: Encuesta Nacional de Hogares, Instituto Nacional de Estadística e Informática (INEI), 2025 (anual)
# Módulos utilizados: Módulo 100 (Características de la vivienda y del hogar) y Módulo 200 (Características de los miembros del hogar)
# Unidad de análisis: persona (se incorpora a cada individuo las características del hogar al que pertenece mediante una unión de bases de datos)

# Descripción del proyecto
Este repositorio incluye el código y el flujo de trabajo completo del "Análisis sobre las características de los hogares peruanos según condiciones de vivienda y composición del hogar en el 2025" elaborado para el curso Taller de procesamiento de datos 2026-1 de la PUCP. 
Se utilizan datos de la Encuesta Nacional de Hogares (ENAHO) de 2025 (versión anual) trabajados integramente en R versión 4.4. La versión de todas las librerías se controla utilizando ´renv´.

El análisis explora la relación entre las siguientes dimensiones: 

**Características demográficas**: sexo, edad, parentesco con el jefe del hogar y estado civil.
**Características de la vivienda y acceso a servicios básicos**: tipo de vivienda, material predominante de las paredes, 
forma de ocupación de la vivienda, abastecimiento de agua, disponibilidad de servicios higiénicos y electricidad.
**Necesidades Básicas Insatisfechas (NBI)**: vivienda inadecuada, hacinamiento, falta de servicios higiénicos, niños no escolarizados y alta dependencia económica. 

# Estructura del directorio
El directorio se organiza a través de la siguiente estructura de carpetas: 

├── ExamenFinal_TallerdeDatos        # Script principal: Configuración del entorno, creación de carpetas y enlace a GitHub
├── datos/                      # No se incluyen los datos en este repositorio debido a su peso
│   ├── crudos/                                  # Módulos originales de la ENAHO en formato .csv
│   └── procesados/                              # Bases procesadas en formato .parquet
│       ├── enaho_2025_modulos.parquet                 # Base consolidada inicial (unión de módulos)
│       ├── enaho_2025_acondicionada.parquet           # Base acondicionada (script de Acondicionamiento)
│       ├── enaho_exploracion.parquet                  # Base con etiquetas (script de Exploración)
│       ├── enaho_2025_analitica.parquet               # Base con variables analíticas (script de Clasificar)
│       └── enaho_2025_codebook.parquet                # Base final documentada (script de Documentación)
├── scripts/
│   ├── 01_Carga_union_modulos.R    # Carga y cruce (joins) de los módulos extraídos de la ENAHO
│   ├── 02_Acondicionamiento.R      # Selección, renombrado, tipado y diagnóstico de valores perdidos
│   ├── 03_Exploracion.R            # Etiquetado, diseño muestral (survey/srvyr), EDA univariado y bivariado
│   ├── 04_Clasificar.R             # Creación de variables analíticas: tipologías, índices y recodificaciones
│   └── 05_Documentacion.R          # Metadatos, decisiones metodológicas y generación del CodeBook
├── outputs/
│   ├── outputs_exploracion_inicial/        # Tablas descriptivas exportadas como imagen (script de Exploración)
│   ├── outputs_exploracion_univariada/     # Gráficos univariados (script de Exploración)
│   ├── outputs_exploracion_bivariada/      # Gráficos y tablas bivariadas (script de Exploración)
│   ├── graficode_datos_perdidos.png        # Gráfico de diagnóstico de valores perdidos (script de Acondicionamiento)
│   ├── reporte_datos_perdidos.csv          # Diagnóstico tabular de valores perdidos (script de Acondicionamiento)
│   ├── CLASIFICAR_Reporte_VariablesCreadas.html   # Reporte de variables analíticas creadas (script de Clasificar)
│   └── CodeBook_Enaho_2025.html            # Libro de códigos final creado con el paquete `codebook` (script de Documentación)
├── docs/                          # Documentos técnicos de la ENAHO 2025
│   ├── Diccionario_ENAHO_2025     # Diccionario de datos de la ENAHO 2025
│   ├── Ficha_Tecnica_ENAHO_2025   # Ficha técnica de la ENAHO 2025
├── renv/                       # Carpeta aislada del entorno local de paquetes
├── renv.lock                   # Registro exacto de las versiones de las librerías
└──  .gitignore                  # Configuración de exclusión para evitar la subida de datos masivos al repositorio

A continuación, se detallan las principales decisiones y acciones tomadas en cada paso del flujo de trabajo. Si se tienen dudas más específicas, por favor referirse a los scripts en concreto.

# EXTRAER
Se descargó los móduloS 100 Y 200 de la Encuesta Nacional de Hogares 2025 en su formato anual a través del siguiente URL: https://proyectos.inei.gob.pe/microdatos/
Se guardaron las bases de datos (en formato .csv) en la carpeta correspondiente, así como el diccionario y la ficha técnica. 

# GESTIONAR
Se creó un R.project con el título del trabajo, y se realizó la conexión con Git y GitHub desde Rstudio. Mediante este proceso, se creó este repositorio de Github, el cual es continuamente actualizado a través de commits desde Rstudio. 
En el proyecto, se creó la estructura de carpetas presentada en la sección anterior. Debe tenerse en cuenta que, en este repositorio, las carpetas de "datos" están vacías puesto que se evitó subir las bases de datos (tanto crudas como procesadas) para no sobrecargar el repositorio debido a su peso. Esto se realizó especificando en el archivo ".gigitnore" que Git ignore los commits asociados a dicha carpeta. 
No obstante, el presente README especifica los módulos de la ENAHO utilizados y cada script permite reproducir y generar como resultado las bases de datos procesadas. Finalmente, se utilizó el paquete ´renv´ para gestionar las versiones de las librerías utilizadas.

# ACONDICIONAR
Se realizó las fusiones correspondientes de los módulos utilizados mediante joins, dando resultado a la primera base de datos procesada; el proceso detallado puede observarse correctamente documentado en el script 01. En el script 02, se seleccionó y renombró las variables de interés (identificadoras, demográficas, de vivienda, de servivios básicos y de NBI), se realizó una revisión rápida de la estructura de los datos y se realizó un diagnóstico de valores perdidos, el cual dio como resultado dos reportes (uno gráfico y otro tabular) que pueden encontrar en la carpeta "outputs", identificando que las variables estado_civil, tipo_vivienda y material_pared presentan valores perdidos; en el caso de estado_civil, estos corresponden a menores de 12 años, para quienes la pregunta no aplica según el diseño del cuestionario (ausencia estructural). Como resultado, se exportó la base acondicionada.

# EXPLORAR
En el script 03, se cargó la base procesada más reciente y, de manera previa a la creación de gráficos y tablas, se creó etiquetas para las opciones de respuesta de las variables de interés, guiandose del diccionario de datos de la ENAHO 2025. Posteriormente, se definieron dos diseños muestrales con el paquete survey/srvyr: uno a nivel de persona (ponderado con factorpob07) y otro a nivel de hogar (ponderado con factor07, sobre una base deduplicada de un registro por hogar, dado que las variables de vivienda y NBI se repiten por cada integrante del hogar). Con estos diseños se calcularon estadísticos descriptivos (totales, medias, medianas y porcentajes) para cada variable de interés, exportados como tablas con formato (flextable) a la carpeta "outputs_exploracion_inicial". Después, se realizó un análisis exploratorio univariado (histogramas y gráficos de barras ponderados por los factores de expansión correspondientes) y bivariado (sexo según estado civil, edad según condición de hacinamiento, y material de la pared según vivienda inadecuada), exportados a las carpetas "outputs_exploracion_univariada" y "outputs_exploracion_bivariada", respectivamente. Como resultado del script de 03_Exploración, se exportó una base de datos procesada que incluye las etiquetas creadas.

# CLASIFICAR
En el script 04, se crean las siguientes variables analíticas: num_nbi (índice), clasificacion_pobreza_nbi (tipología), grupo_edad_teoria (recodificacion), grupo_edad_datos (recodificación), acceso_basico (tipologia intermedia), condicion habitacional (tipologia combinada). Con la base analítica resultante, se actualizó el diseño muestral a nivel de persona (ponderado con factorpob07) y se generó un reporte de las variables recodificadas y construidas utilizando gtsummary::tbl_svysummary(), exportado en HTML a la carpeta "outputs" (CLASIFICAR_Reporte_VariablesCreadas.html). Como resultado del script de Clasificar, se exportó una nueva base de datos procesada (enaho_2025_analitica.parquet) que incluye las variables analíticas creadas.

# DOCUMENTAR
En el script 05 se realizó la depuración final de la base de datos, quedándonos solo con las variables etiquetadas utilizadas en el análisis (demografía, vivienda y NBI). Se incluyeron etiquetas descriptivas y la fuente original de cada variable (su código de pregunta en la ENAHO) mediante var_label() del paquete ´labelled´. Asimismo, se documentaron las decisiones metodológicas más relevantes —como la exclusión de registros sin información individual, la naturaleza estructural de los valores perdidos en estado civil, y el origen de los indicadores de NBI (construidos y provistos directamente por el INEI)— como atributos de descripción a nivel de columna. Se agregaron también metadatos a nivel de estudio (nombre, descripción y autoría de la base) mediante metadata() del paquete ´codebook´. Con esta información, se generó el libro de códigos final utilizando el paquete codebook, exportado como CodeBook_Enaho_2025.html en la carpeta "outputs". En estos archivos, se describe detalladamente el significado de las variables, las opciones de respuesta, su distribución, sus NAs y estrategias de imputación, y se detalla la fuente original en la ENAHO. Como parte de la documentación, en la carpeta "docs" se puede encontrar el diccionario de datos de la ENAHO 2025, así como su ficha técnica. Las decisiones tomadas también están documentadas en commits en los propios scripts. 
