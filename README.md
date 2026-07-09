# Procesamiento cuantitativo de la caracterización de los hogares peruanos
# Autora: Camila Ormachea Fernández
# Curso: Taller de procesamiento de datos 
# Encuesta: Encuesta Nacional de Hogares, Instituto Nacional de Estadística e Informática (INEI), 2025 (anual)
# Módulos utilizados: Módulo 100 (Características de la vivienda y del hogar) y Módulo 200 (Características de los miembros del hogar)
# Unidad de análisis: persona (se incorpora a cada individuo las características del hogar al que pertenece mediante una unión de bases de datos)

# Descripción del proyecto
Este repositorio incluye el código y el flujo de trabajo completo del "Análisis sobre las características de los hogares peruanos según condiciones de vivienda y composición del hogar en el 2025" elaborado para el curso Taller de procesamiento de datos 2026-1 de la PUCP. 
Se utilizan datos de la Encuesta Nacional de Hogares (ENAHO) de 2025 (versión anual) trabajados integramente en R versión 4.4. La versión de todas las librerías se controla utilizando **renv**.

El análisis explora la relación entre las siguientes dimensiones: 

**Características demográficas**: sexo, edad, parentesco con el jefe del hogar y estado civil.
**Características de la vivienda**: tipo de vivienda, material predominante y condición de ocupación.
**Acceso a servicios básicos**: abastecimiento de agua, servicio higiénico y electricidad. 

# Estructura del directorio

# EXTRAER
Se descargó los móduloS 100 Y 200 de la Encuesta Nacional de Hogares 2025 en su formato anual a través del siguiente URL: https://proyectos.inei.gob.pe/microdatos/
Se guardaron las bases de datos (en formato .csv) en la carpeta correspondiente, así como el diccionario y la ficha técnica. 

# GESTIONAR
Se creó un R.project con el título del trabajo, y se realizó la conexión con Git y GitHub desde Rstudio. Mediante este proceso, se creó este repositorio de Github, el cual es continuamente actualizado a través de commits desde Rstudio. 
En el proyecto, se creó la estructura de carpetas presentada en la sección anterior. Debe tenerse en cuenta que, en este repositorio, las carpetas de "datos" están vacías puesto que se evitó subir las bases de datos (tanto crudas como procesadas) para no sobrecargar el repositorio debido a su peso. Esto se realizó especificando en el archivo ".gigitnore" que Git ignore los commits asociados a dicha carpeta. 
No obstante, el presente README especifica los módulos de la ENAHO utilizados y cada script permite reproducir y generar como resultado las bases de datos procesadas. Finalmente, se utilizó el paquete ´renv´para gestionar las versiones de las librerías utilizadas.

# ACONDICIONAR
Se realizó las fusiones correspondientes de los módulos utilizados mediante joins, dando resultado a la primera base de datos procesada; el proceso detallado puede observarse correctamente documentado en el script 01. 

# EXPLORAR

# CLASIFICAR

# DOCUMENTAR
