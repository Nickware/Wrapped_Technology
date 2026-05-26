# summarize.R
#
# Función deliberadamente simple: recibe un data.frame y devuelve la media
# de cada columna numérica. Lo que interesa del lado del benchmark no es
# el cómputo (trivial) sino el costo de mover el data.frame completo de
# Python a R y el resultado de vuelta.

summarize_df <- function(df) {
  sapply(df, mean)
}
