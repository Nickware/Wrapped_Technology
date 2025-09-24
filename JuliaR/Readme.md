# Modelo wrapped R desde Julia?

Descripción paso a paso para crear un modelo wrapped para invocar R desde Julia:

***

# Ejemplo Wrapped: Invocar R desde Julia paso a paso

Este ejemplo muestra cómo usar Julia para llamar y ejecutar código R, integrando ambos lenguajes en un flujo común de trabajo científico, usando el paquete `RCall.jl`.

***

## Paso 1: Instalar R y Julia

- Instalar R y asegúrate de que esté accesible desde el sistema (ejecuta `R --version`).
- Instalar Julia (idealmente la última versión estable).

***

## Paso 2: Instalar el paquete `RCall.jl` en Julia

Abrir Julia y ejecutar:

```julia
using Pkg
Pkg.add("RCall")
```


***

## Paso 3: Llamar funciones R desde Julia

Ejemplo simple para ejecutar comandos R:

```julia
using RCall

# Ejecutar código R directamente
R"""
x <- rnorm(100)
summary(x)
"""

# Guardar resultado de R en variable Julia
x = rnorm(10)  # Genera 10 números normales en R
julia_x = rcopy(x)  # Copia los datos a Julia

println("Datos desde R:", julia_x)
```


***

## Paso 4: Ejecutar un script R externo desde Julia

Si tiene un script R, por ejemplo `script.R`:

```r
# script.R
x <- rnorm(100)
mean(x)
```

Desde Julia:

```julia
using RCall

R"""
source("script.R")
"""
```


***

## Paso 5: Interoperabilidad de datos

Puede enviar datos de Julia a R y viceversa fácilmente:

```julia
using RCall

julia_vec = [1,2,3,4]
@rput julia_vec   # Pasa a R

R"""
print(julia_vec)
"""

@rget julia_vec   # Recupera variable R a Julia
println(julia_vec)
```


***

## Beneficios y resumen

- `RCall.jl` funciona como un wrapper nativo para integrar R con Julia.
- Fácil ejecución de código R, manejo de scripts y transferencia de datos bidireccional.
- Ideal para aprovechar el ecosistema estadístico de R desde Julia y viceversa.
- Excelente para pipelines científicos multi-lenguaje.
