# Este código utiliza la biblioteca reticulate para ejecutar código Python desde R.
# El código ajusta un modelo de regresión lineal utilizando la biblioteca statsmodels de Python y genera un gráfico de dispersión con la línea de regresión utilizando matplotlib.
# Asegúrate de tener Python instalado y las bibliotecas necesarias antes de ejecutar este código.
# Para instalar las bibliotecas de Python, puedes usar pip:
# pip install pandas statsmodels matplotlib
# El dataset utilizado es mtcars, que está disponible en R. El código convierte este dataset a un dataframe de pandas para su análisis en Python.
# El resultado del modelo de regresión se muestra en la consola de R, y el gráfico se muestra en una ventana emergente. Además, el gráfico se guarda como una imagen PNG y el resumen del modelo se guarda en un archivo de texto.
# Nota: Asegúrate de tener configurado el entorno de Python correctamente para que reticulate pueda encontrarlo. Puedes usar py_config() en R para verificar la configuración de Python.
# Cualquier error relacionado con la instalación de bibliotecas o la configuración de Python puede ser resuelto asegurándote de que Python esté correctamente instalado y que las bibliotecas necesarias estén disponibles en el entorno de Python que reticulate está utilizando.
# Si deseas ejecutar este código, simplemente cópialo y pégalo en tu consola de R o en un script de R. Asegúrate de tener las bibliotecas de Python instaladas y configuradas correctamente para evitar errores.
# Este código es un ejemplo de cómo integrar Python en R utilizando reticulate, lo que permite aprovechar las capacidades de ambas lenguajes para análisis de datos y visualización.
# Recuerda que puedes modificar el código para ajustar diferentes modelos de regresión, utilizar otros datasets o personalizar los gráficos según tus necesidades.
# ¡Disfruta explorando la integración de Python y R con reticulate!
# Cualquier pregunta o problema que tengas al ejecutar este código, no dudes en preguntar. Estoy aquí para ayudarte a resolver cualquier duda que puedas tener sobre la integración de Python y R.
# ¡Buena suerte con tu análisis de datos utilizando reticulate!
# Si deseas aprender más sobre reticulate y cómo integrar Python en R, puedes consultar la documentación oficial de reticulate en https://rstudio.github.io/reticulate/.
# Este código es un ejemplo básico de cómo utilizar reticulate para ejecutar código Python desde R, pero las posibilidades son infinitas. Puedes explorar diferentes bibliotecas de Python, ajustar modelos más complejos, realizar análisis de datos avanzados y crear visualizaciones personalizadas utilizando la potencia de Python dentro de tu entorno de R.
# Recuerda que la integración de Python y R con reticulate te permite aprovechar lo mejor de ambos lenguajes, lo que puede ser especialmente útil para tareas de análisis de datos, modelado estadístico y visualización. ¡Explora y experimenta con reticulate para descubrir todo lo que puedes hacer con esta poderosa combinación de lenguajes!
# Este código es un ejemplo de cómo utilizar reticulate para ejecutar código Python desde R, lo que permite aprovechar las capacidades de ambas lenguajes para análisis de datos y visualización. Asegúrate de tener Python instalado y las bibliotecas necesarias antes de ejecutar este código. ¡Disfruta explorando la integración de Python y R con reticulate! 
library(reticulate)
# Instalar las bibliotecas necesarias de Python
py_require("pandas")
py_require("statsmodels")
py_require("matplotlib")

# importar modulos de python
pd <- import("pandas")
sm <- import("statsmodels.api")
plt <- import("matplotlib.pyplot")


# cargar el dataset mtcars desde R y convertirlo a un dataframe de pandas
data("mtcars")
mtcars_df <- pd$DataFrame(mtcars)

# Ajustar un modelo de regresión lineal en Python (mpg ~ wt)
X <- mtcars_df[["wt"]]
X <- sm$add_constant(X)  # Agregar una constante (intercepto)
y <- mtcars_df[["mpg"]]
model <- sm$OLS(y, X)$fit()
summary <- model$summary()

# Mostrar el resumen del modelo en R
print(summary)

# Generar un gráfico de dispersión y la línea de regresión con matplotlib
plt$scatter(mtcars_df[["wt"]], mtcars_df[["mpg"]], color = "blue", label = "Datos")
plt$plot(mtcars_df[["wt"]], model$fittedvalues, color = "red", label = "Línea de regresión")
plt$title("Regresión entre el peso y la eficiencia de combustible")
plt$xlabel("Peso del coche (wt)")
plt$ylabel("Millas por galón (mpg)")
plt$legend()
plt$show()
# Guardar el gráfico como imagen
plt$savefig("regression_plot.png", dpi = 300)
# Guardar el resumen del modelo en un archivo de texto
summary_file <- "model_summary.txt"