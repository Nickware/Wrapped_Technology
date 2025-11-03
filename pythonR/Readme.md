# Ejemplo Básico de Integración Python y R

Este script es un **ejemplo clásico de tecnología “wrapped”** entre Python y R, utilizando la librería `rpy2` para invocar funciones, modelos y gráficos nativos de R directamente desde Python. Esto permite aprovechar la potencia estadística y los paquetes de visualización de R en proyectos Python, mientras conservas toda la flexibilidad del ecosistema Python y Pandas.

***

## Descripción paso a paso

### 1. **Importación de módulos y activación de conversión automática**

```python
import rpy2.robjects as ro
from rpy2.robjects.packages import importr
from rpy2.robjects import pandas2ri

pandas2ri.activate()
```
- Se habilita la conversión automática entre pandas DataFrames y R data frames para que los datos sean interoperables entre ambos lenguajes.[5]

***

### 2. **Carga de paquetes R desde Python**

```python
base = importr('base')
utils = importr('utils')
stats = importr('stats')
ggplot2 = importr('ggplot2')
```
- Se importan paquetes básicos y avanzados de R (incluyendo `ggplot2` para visualización) directamente en el entorno Python.[2][4]

***

### 3. **Acceso y manipulación de datos de R en Python**

```python
mtcars = utils.data('mtcars')
r_mtcars = ro.r['mtcars']
```
- Se carga el dataset clásico `mtcars` de R y se recupera para trabajar con él desde Python (puedes convertirlo fácilmente a pandas si lo deseas).[2][5]

***

### 4. **Modelado estadístico envuelto (regresión lineal en R desde Python)**

```python
linear_model = ro.r('lm(mpg ~ wt + hp, data=mtcars)')
summary = ro.r('summary')(linear_model)
print(summary)
```
- Se define un modelo de regresión lineal en R usando la sintaxis nativa y se muestra el resumen del modelo (coeficientes, error estándar, R², etc.) desde Python. Toda la lógica estadística corre realmente en R.[4][2]

***

### 5. **Visualización envuelta con ggplot2**

```python
ro.r('''
library(ggplot2)
ggplot(mtcars, aes(x=wt, y=mpg)) +
  geom_point() +
  geom_smooth(method="lm", se=FALSE, color="blue") +
  labs(title="Scatter plot with regression line",
       x="Weight (1000 lbs)",
       y="Miles per gallon (mpg)")
''')
```
- Se genera un gráfico de dispersión con línea de regresión usando `ggplot2` de R, invocando y gestionando directamente desde Python.[7][2]

***

## Ventajas de este enfoque wrapped

- **Máxima interoperabilidad:** Puedes mezclar análisis y visualizaciones de R y Python en el mismo flujo de trabajo.
- **Acceso poderoso a bibliotecas R:** Usas modelos, gráficos y técnicas que están muy optimizadas en R sin salir de Python.
- **Facilidad para transferir datos y resultados:** La interoperabilidad entre pandas y R data.frames es automática gracias a rpy2.

***

## Recursos recomendados

- [Documentación oficial de rpy2](https://rpy2.readthedocs.io) — Ejemplos, referencia y detalles de conversión de datos.[5]
- [Tutorial de R/Python con rpy2 en Kaggle](https://www.kaggle.com/code/alexandrelemercier/r-python-complete-tutorial-showcase-with-rpy2).[1]
- [Ejemplo de integración y visualización con R desde Python](https://rviews.rstudio.com/2022/05/25/calling-r-from-python-with-rpy2/).[2]

***

Este script es un modelo robusto y profesional para la tecnología “wrapped” entre Python y R, utilizando rpy2, muy usado en ciencia de datos y análisis avanzado.

[1](https://www.kaggle.com/code/alexandrelemercier/r-python-complete-tutorial-showcase-with-rpy2)
[2](https://rviews.rstudio.com/2022/05/25/calling-r-from-python-with-rpy2/)
[3](https://www.youtube.com/watch?v=O1D82XmPz5A)
[4](https://rpy2.github.io/doc/v2.9.x/html/introduction.html)
[5](https://rpy2.readthedocs.io)
[6](https://www.datacamp.com/tutorial/using-both-python-r)
[7](https://blog.djnavarro.net/posts/2022-09-16_arrow-and-rpy2/)
[8](https://www.analyticslane.com/2019/01/11/utilizar-r-desde-python-con-rpy2/)
