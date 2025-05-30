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