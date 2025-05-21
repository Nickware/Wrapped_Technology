import rpy2.robjects as ro
from rpy2.robjects.packages import importr
from rpy2.robjects import pandas2ri

# Activar la conversi[on automatica entre pandas y R
pandas2ri.activate()

# Importar paquetes de R
base = importr('base')
utils = importr('utils')
stats = importr('stats')
ggplot2 = importr('ggplot2')


# Cargar el conjunto de datos mtcars desde R
mtcars = utils.data('mtcars')
r_mtcars = ro.r['mtcars']

# Definir y ajustar un modelo de regresión lineal en R  
linear_model = ro.r('lm(mpg ~ wt + hp, data=mtcars)')
summary = ro.r('summary')(linear_model)


# Mostrar el resumen del modelo en Python
print(summary)

# Generar el grafico de dispersión con la línea de regresión usando ggplot2 en R
ro.r('''
library(ggplot2)
ggplot(mtcars, aes(x=wt, y=mpg)) +
  geom_point() +
  geom_smooth(method="lm", se=FALSE, color="blue") +
  labs(title="Scatter plot with regression line",
       x="Weight (1000 lbs)",
       y="Miles per gallon (mpg)")
''')
