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

Los benchmarks del repositorio existen para cuantificar exactamente eso,
caso de uso por caso de uso:

- **Cálculo numérico intensivo** — compara Python puro, pybind11 (grano
  fino vs grano grueso) y NumPy vectorizado en Mandelbrot e integración
  numérica, aislando el overhead de cruce de frontera del trabajo real.
- **Manejo masivo de datos y estructuras** — compara zero-copy vs copia
  explícita en pybind11, y Python↔R vía rpy2 contra pandas puro,
  mostrando que el costo de mover datos entre runtimes puede superar en
  1-3 órdenes de magnitud al costo del cómputo mismo.

Los ítems restantes del catálogo (pipelines multi-lenguaje,
interoperabilidad orientada a objetos, llamadas de alta/baja frecuencia,
integración en producción) siguen la misma lógica: mismo patrón de
diseño, distinto punto del espacio de costos.

## Beneficios

- **Portabilidad y reutilización**: permite envolver código legado o de
  terceros y adaptarlo a otros proyectos sin reescribirlo.
- **Mantenimiento**: el componente original permanece inalterado, lo que
  facilita actualizaciones o sustituciones sin afectar al código cliente.
- **Pruebas**: los wrappers son ideales para mockear o interceptar
  funcionalidad en ambientes de test.

---

### Resumen

**Wrapped_Technology** documenta el patrón wrapper —en su variante más
exigente, la de bindings entre lenguajes— y lo acompaña con benchmarks
que miden su costo real en escenarios concretos: cálculo intensivo,
transferencia de datos, y los demás casos de uso del catálogo. La
pregunta de fondo no es solo cómo envolver un componente, sino cuánto
cuesta hacerlo y en qué punto deja de valer la pena.

[^1]: https://github.com/Nickware/Wrapped_Technology
