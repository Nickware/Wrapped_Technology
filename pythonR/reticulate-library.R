library(reticulate)

# importar el modulo numpy de python
np <- import("numpy")

# Crear un array de Python desde R
array <- np$array(c(1, 2, 3, 4, 5))

# Calcular la suma acumulada usando numpy
cumsum_py <- np$cumsum(array)

# Convertir el resultado a un vector de R
cumsum_r <- as.numeric(cumsum_py)

# Imprimir el resultado
print(cumsum_r)
