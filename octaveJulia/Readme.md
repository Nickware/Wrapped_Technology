# Ejemplo Integración paso a paso entre Julia y Octave

Este ejemplo muestra cómo Julia puede “envolver” código Octave ejecutándolo como un proceso externo, capturando su salida, y procesándola dentro de Julia para aprovechar ambas tecnologías en cálculos científicos.

***

## Paso 1: Escribir el script Octave

Crear un archivo llamado `integra_trapecio.m` con el siguiente código Octave:

```octave
function resultado = integra_trapecio()
    f = @(x) sqrt(1 + cos(x)^2);
    a = 0; b = 50; n = 1000;
    x = linspace(a, b, n+1);
    h = (b-a)/n;
    s = f(a) + f(b) + 2*sum(arrayfun(f, x(2:end-1)));
    resultado = h/2 * s;
    printf('%.6f\n', resultado); % Imprime solo el resultado
end
```

**Nota:** Guardar este archivo en un directorio accesible para Octave.

***

## Paso 2: Ejecutar el script Octave desde Julia

En Julia, usa la función `run` o `read` para invocar Octave como proceso externo y capturar su salida. Por ejemplo:

```julia
cmd = `octave --quiet --eval "integra_trapecio()"`
output = read(cmd, String)
```


***

## Paso 3: Procesar la salida en Julia

Dado que la salida de Octave puede contener texto adicional, se divide y filtra la cadena para extraer solo el número:

```julia
lineas = split(output, '\n')
resultado = parse(Float64, strip(lineas[^1]))  # Primera línea limpia con solo el resultado
println("Resultado devuelto por Octave: ", resultado)
```


***

## Paso 4: Ejecutar todo el flujo y obtener el resultado integrado

Al ejecutar tu código Julia, se lanzará el código Octave, se calculará la integral, se devolverá el valor a Julia y se imprimirá la respuesta en la consola Julia.

***

## Consejos adicionales

- Asegúrarse que Octave esté instalado y accesible en la variable PATH.
- El script Octave debe imprimir solo el valor numérico para fácil parseo.
- Usa rutas absolutas o administrativo cuidado con directorios temporales para evitar errores de archivo no encontrado.

***

## Resumen

Este método envuelve código Octave en Julia invocando procesos externos y usando archivos o la salida estándar para intercambiar datos. Es un ejemplo práctico de tecnología wrapped para combinar arquitecturas y lenguajes numéricos, excelente para reutilización de código y flexibilidad.

