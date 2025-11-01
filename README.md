# Tecnología Envoltura (Wrapped Technology)

**Wrapped** se refiere a un enfoque de desarrollo donde se crea un
*wrapper* (envoltorio) alrededor de un componente o subsistema ya
existente. El wrapper actúa como una capa intermedia: expone una interfaz
propia hacia quien lo consume, mientras internamente delega el trabajo
real al componente que envuelve.

## Wrapper como término general, no como sinónimo de adapter o facade

*Wrapper* no es un patrón único sino la familia de soluciones que
comparten esa idea de capa intermedia. Dentro de esa familia, cada patrón
de la Gang of Four resuelve un problema distinto:

- **Adapter** — traduce una interfaz incompatible a la que el cliente
  espera. Se usa cuando el componente ya hace lo que necesitas, pero
  "habla" un protocolo distinto.
- **Facade** — simplifica un subsistema complejo detrás de una interfaz
  más simple. Se usa para ocultar complejidad, no para traducir entre
  interfaces.
- **Decorator** — añade comportamiento (logging, validación, caché) sin
  cambiar la interfaz original.
- **Proxy** — controla el acceso al objeto envuelto (carga diferida,
  permisos, referencias remotas).

Este repositorio se enfoca en un caso particular y más exigente que
cualquiera de los anteriores: **bindings de lenguaje cruzado** (pybind11,
rpy2, FFI, ctypes, SWIG). Ahí el wrapper no solo adapta una interfaz —
traduce entre dos runtimes completos, con modelos de memoria, sistemas de
tipos y convenciones de llamada distintos. Esa traducción tiene un costo
que los patrones clásicos de la GoF no necesitan cuantificar, porque
ocurren dentro de un mismo runtime; aquí es el centro del problema.

## Índice de proyectos

### Ejemplos de integración

- [C++ con Python mediante pybind11](c++python/Readme.md) — compilar e
  importar una extensión nativa.
- [Cython y Fibonacci](cpython/Readme.md) — compilar una función tipada de
  Cython como módulo de Python.
- [Python con Julia mediante PyJulia](PyJulia/Readme.md) — invocar Julia
  desde Python.
- [Python con R mediante rpy2 y reticulate](pythonR/Readme.md) — ejemplos
  en ambos sentidos.
- [Python y Fortran](pyFortran/Readme.md) — comparación de cálculo numérico
  en ambos lenguajes.
- [Julia con R mediante RCall.jl](JuliaR/Readme.md) — llamar R desde Julia.
- [R con Julia mediante JuliaCall](RJulia/Readme.md) — llamar Julia desde R.
- [Julia con Octave](octaveJulia/Readme.md) — ejecutar Octave como proceso
  externo y procesar su salida en Julia.
- [C++ con GSL y Octave](gsl/Readme.md) — simulación Monte Carlo y análisis
  de trayectorias.

### Casos de uso y benchmarks

- [Catálogo de casos de uso](uses_cases/wrapper_general/Readme.md) —
  propuestas y métricas para comparar wrappers.
- [Aplicaciones y benchmarks](uses_cases/wrapper_applications/Readme.md) —
  índice de escenarios concretos.
- [Cálculo numérico intensivo](uses_cases/wrapper_applications/calculo_numerico/README.md)
  — Python, pybind11 y NumPy en Mandelbrot e integración numérica.
- [Manejo masivo de datos](uses_cases/wrapper_applications/manejo_datos/README.md)
  — zero-copy frente a copia en pybind11 y transferencia Python↔R con rpy2.
- [Simuladores físicos para aprendizaje por refuerzo](uses_cases/wrapper_applications/simuladores_fisicos/README.md)
  — CartPole en C++/pybind11 con benchmark nativo, [guía de configuración](uses_cases/wrapper_applications/simuladores_fisicos/docs/README.md)
  y uso opcional de un agente de IA.

Las guías de cada proyecto describen sus dependencias y comandos de
ejecución. En particular, los benchmarks de cálculo numérico y manejo de
datos incluyen pasos de compilación, requisitos externos y rutas de salida.

## Cuándo conviene usar un wrapper

- Para **adaptar una interfaz** existente a como la necesita el código
  cliente, sin tocar el componente original.
- Para **añadir control** (validaciones, logs, seguridad, auditoría,
  caché) alrededor de un componente sin modificar su implementación.
- Para **aislar dependencias**: si el componente interno cambia o se
  reemplaza, el código cliente no se entera mientras el wrapper mantenga
  su interfaz estable — lo mismo que facilita las pruebas (se puede
  mockear el wrapper) y las migraciones (se sustituye lo envuelto sin
  tocar el resto del sistema).
- Para lograr **interoperabilidad** entre tecnologías distintas,
  adaptando varias interfaces heterogéneas a un estándar común.

## Ejemplos de uso

- **Llamadas a librerías externas**: una biblioteca en C consumida desde
  Python vía un wrapper en Cython, SWIG, ctypes o pybind11.
- **Comunicación entre microservicios**: un wrapper traduce mensajes
  entrantes/salientes para que el microservicio mantenga una interfaz
  estable aunque la API real cambie.
- **Frameworks de testing**: usan wrappers para interceptar llamadas,
  verificar expectativas o simular respuestas.

## De la teoría a la pregunta que responde este repositorio

Todo lo anterior explica *por qué* se usa un wrapper. Lo que este
repositorio añade es la otra mitad de la pregunta: **¿a qué costo?** Un
wrapper nunca es gratis — cada cruce de frontera entre lenguajes implica
overhead de llamada, posible copia de datos, y conversión de tipos — y
ese costo puede ser insignificante o puede comerse por completo la
ventaja de usar el componente nativo, dependiendo de cuántas veces se
cruza esa frontera y cuánto trabajo hay de cada lado.

Los benchmarks implementados cuantifican ese costo en dos escenarios:

- **Cálculo numérico intensivo** — compara Python puro, pybind11 (grano
  fino vs grano grueso) y NumPy vectorizado en Mandelbrot e integración
  numérica, aislando el overhead de cruce de frontera del trabajo real.
- **Manejo masivo de datos y estructuras** — compara zero-copy vs copia
  explícita en pybind11, y Python↔R vía rpy2 contra pandas puro,
  mostrando que el costo de mover datos entre runtimes puede superar en
  1-3 órdenes de magnitud al costo del cómputo mismo.

El catálogo general incluye otros escenarios —pipelines multi-lenguaje,
interoperabilidad orientada a objetos, llamadas de alta/baja frecuencia e
integración en producción— como propuestas para extender las mediciones;
no todos cuentan todavía con un benchmark ejecutable en este repositorio.

## Beneficios

- **Portabilidad y reutilización**: permite envolver código legado o de
  terceros y adaptarlo a otros proyectos sin reescribirlo.
- **Mantenimiento**: el componente original permanece inalterado, lo que
  facilita actualizaciones o sustituciones sin afectar al código cliente.
- **Pruebas**: los wrappers son ideales para mockear o interceptar
  funcionalidad en ambientes de test.

---

### Resumen

**Wrapped_Technology** reúne guías de integración entre lenguajes y
benchmarks reproducibles para medir el costo de las llamadas y la
transferencia de datos. El índice de esta página enlaza cada proyecto; la
pregunta de fondo no es solo cómo envolver un componente, sino cuánto
cuesta hacerlo y cuándo compensa.

[^1]: https://github.com/Nickware/Wrapped_Technology
