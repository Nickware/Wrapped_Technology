# Casos de uso para comparar tecnologías wrapper

Este documento reúne conceptos y escenarios básicos para estudiar eficiencia,
overhead y escalabilidad de wrappers (FFI y bindings como rpy2, pybind11 o
JuliaCall). Los dos primeros casos tienen benchmarks implementados en este
repositorio; los demás son propuestas con referencias externas, no resultados
propios.[[artículo sobre interoperabilidad y rendimiento](https://dl.acm.org/doi/fullHtml/10.1145/3201898)]

Los casos tienen cargas de trabajo distintas. Compara resultados solo cuando
coincidan el baseline, el workload y las condiciones de ejecución.

## Cálculo numérico intensivo

- **[Implementado]** Mandelbrot e integración comparan Python puro, pybind11
  de grano fino y grueso, y NumPy. Consulta [el benchmark y sus resultados](../wrapper_applications/calculo_numerico/README.md).
- **[Propuesto]** Bucles numéricos (por ejemplo, Fortran frente a Python) para
  estudiar llamadas cruzadas. Comparar ejecutables nativos muestra diferencias
  entre lenguajes, pero no mide por sí solo el overhead del wrapper: para eso,
  el código Fortran debe invocarse desde Python mediante un binding.
  El ejemplo de comparación disponible está en [pyFortran](../../pyFortran/Readme.md).
- Variar el número de llamadas y el trabajo por llamada (muchas llamadas
  pequeñas frente a pocas llamadas costosas). [Discusión sobre pybind11](https://github.com/pybind/pybind11/issues/2760).

## Manejo masivo de datos y estructuras

- **[Implementado]** El benchmark compara acceso zero-copy y copia explícita
  en pybind11, además de transferir data frames Python↔R con rpy2 frente a
  pandas. Consulta [el benchmark y sus requisitos](../wrapper_applications/manejo_datos/README.md).
- **[Propuesto]** Escalar matrices, data frames y tensores para medir
  serialización, conversión de tipos y copias frente a acceso compartido.
- Casos de referencia: Python↔R con data frames y Python↔C++ con vectores o
  matrices densos. [Estudio de transferencia de datos](https://arxiv.org/html/2507.23205v1) y
  [benchmark Python/C++](https://github.com/yanto77/cpp-python-binding-benchmark).

## Pipelines científicos multi‑lenguaje

- **[Propuesto]** Orquestar desde Python, Julia o R un módulo pesado en
  C/C++/Fortran, por ejemplo un solver para CFD, FEM o PDE.
- Medir tiempo total del pipeline y proporción atribuible al cómputo envuelto
  frente a llamadas, transferencia y coordinación. [Referencia sobre solvers](https://www.sciencedirect.com/science/article/abs/pii/S0045782520307374).
- **[Propuesto]** Integrar física computacional o PINNs mediante componentes
  SciANN, TensorFlow o Keras; registrar tiempo y precisión. [Trabajo relacionado](https://dspace.mit.edu/bitstream/handle/1721.1/133000/2005.08803.pdf?sequence=2&isAllowed=y).

## Interoperabilidad orientada a objetos

- **[Propuesto]** Crear objetos del lado nativo y manipularlos desde el
  lenguaje huésped, por ejemplo objetos C++ desde Python con pybind11 o cppyy.
- Medir costo por objeto, acceso a métodos y atributos, y efecto de las
  políticas de gestión de memoria y referencias. [Discusión de benchmarks pybind11](https://github.com/pybind/pybind11/issues/2760).

## Llamadas de alta frecuencia vs baja frecuencia

- **[Propuesto] Caso A:** llamar millones de veces a una función casi vacía
  para enfatizar el overhead por cruce de frontera.
- **[Propuesto] Caso B:** llamar una función costosa (FFT o solver lineal),
  donde el costo del wrapper puede ser pequeño frente al cómputo.
- Variar frecuencia y carga para estimar cuándo compensa envolver el código
  nativo. [Discusión sobre pybind11](https://github.com/pybind/pybind11/issues/2760) y
  [referencia sobre extensiones Python](https://www.reddit.com/r/programming/comments/pmlbrq/the_performance_overhead_of_python_c_extensions/).

## Escenarios de integración en producción

- **[Propuesto]** Exponer una biblioteca core en Rust o C++ mediante SDKs
  para Java, Python o Go.
- **[Propuesto]** Integrar un motor de reglas o feature flags compartido por
  varios clientes.
- Medir latencia, memoria, robustez ante errores de tipos y fallos nativos
  bajo condiciones representativas. [Referencia de FFI a WebAssembly](https://blog.flipt.io/from-ffi-to-wasm).

## Métricas recomendadas

Para cada caso conviene medir:

- Tiempo total y tiempo por llamada.
- CPU de usuario/sistema y, si está disponible, fallos de caché.
- Memoria pico (RSS) y tamaño de los datos u objetos transferidos.
- Escalabilidad al aumentar datos, llamadas o concurrencia.
- Variabilidad entre repeticiones, además del mejor tiempo.

Documenta baseline, workload, sistema operativo, hardware, versiones y
opciones de compilación. Cuando sea posible, separa llamada vacía,
transferencia, cómputo nativo y tiempo end-to-end; no compares speedups de
estudios distintos si cambian esas condiciones. [Referencia metodológica](https://dl.acm.org/doi/fullHtml/10.1145/3201898).