# Ejemplo: Cálculo numérico intensivo

Implementación concreta del primer ítem del catálogo de casos de uso para
comparar tecnologías wrapper. Compara **Python puro**, **pybind11** (en dos
modalidades) y **NumPy vectorizado**.

## Estructura

```
wrapper_bench/
├── cpp/
│   ├── wrapper_bench.cpp   # módulo pybind11: mandelbrot_pixel, mandelbrot_region, integrate_trapz_native
│   └── build.sh            # compila la extensión
├── python/
│   ├── pure_python.py      # equivalentes en Python puro, mismo algoritmo
│   └── benchmark.py        # orquestador: corre todo, imprime tabla, guarda CSV
└── results/                # generado al correr benchmark.py
```

## Qué mide cada bloque

**Mandelbrot — muchas llamadas baratas vs una llamada cara.**
`mandelbrot_pixel` se llama una vez por píxel desde un bucle en Python: aísla
el overhead de cruzar la frontera Python↔C++ en cada iteración.
`mandelbrot_region` hace todo el bucle del lado de C++ y Python solo pide el
resultado una vez: el overhead de cruce ocurre una sola vez, sin importar el
tamaño de la región.

**Integración — overhead fijo vs trabajo por llamada.**
Se integra la misma función variando `n` (subintervalos). Con `n` pequeño el
tiempo está dominado por el costo fijo de la llamada; con `n` grande, por el
trabajo real. Sirve para ubicar el umbral donde "vale la pena" envolver
código nativo, tal como pide el README original.

## Resultados obtenidos en este entorno

Mandelbrot (max_iter=100), tiempos en segundos, mejor de 3 corridas:

| tamaño  | Python puro | pybind11 grano fino | pybind11 grano grueso | NumPy vectorizado | speedup grueso vs Python |
|---------|-------------|----------------------|-------------------------|--------------------|----------------------------|
| 20×20   | 8.23e-4     | 9.25e-5              | 2.44e-5                 | 6.94e-4            | ~34×                       |
| 50×50   | 4.25e-3     | 4.69e-4              | 1.39e-4                 | 1.57e-3            | ~31×                       |
| 100×100 | 1.72e-2     | 1.67e-3              | 5.52e-4                 | 4.52e-3            | ~31×                       |
| 200×200 | 6.69e-2     | 6.91e-3              | 2.25e-3                 | 1.93e-2            | ~30×                       |

Lectura: el grano grueso gana con margen consistente (~30×) sobre Python
puro y sigue siendo ~3× más rápido que el grano fino, incluso aunque este
último ya usa C++ para el cómputo pesado — la diferencia es puramente el
overhead acumulado de miles de cruces de frontera. NumPy vectorizado queda
en un punto intermedio: más rápido que Python puro pero por debajo de
cualquiera de las dos variantes en C++, porque su vectorización tiene que
recorrer la máscara completa en cada iteración del `while`.

Integración, tiempo por llamada en segundos:

| n subintervalos | Python puro | pybind11 | speedup |
|------------------|-------------|----------|---------|
| 10               | 1.22e-6     | 2.08e-7  | ~5.9×   |
| 100              | 9.91e-6     | 1.20e-6  | ~8.3×   |
| 1,000            | 9.58e-5     | 1.11e-5  | ~8.7×   |
| 10,000           | 9.88e-4     | 1.08e-4  | ~9.2×   |
| 100,000          | 1.05e-2     | 1.17e-3  | ~8.9×   |

Lectura: el speedup se estabiliza alrededor de 8-9× ya desde `n=100`. No hay
aquí un "umbral" donde el overhead de la llamada domine — con `a=0, b=10`
incluso `n=10` es demasiado trabajo para que el overhead fijo del binding se
note; para verlo de verdad habría que medir con `n=1` o comparar contra una
llamada vacía (`def f(): pass` vs `m.def("f", []{})`), que es el
micro-benchmark puro que describe la sección de "llamadas de alta frecuencia
vs baja frecuencia" del README original.

## Cómo correrlo

```bash
cd cpp && ./build.sh
cd ../python && python3 benchmark.py
```

## Extensiones naturales

- Agregar `cppyy` o `cython` como wrappers adicionales para ampliar la
  comparación más allá de pybind11.
- Medir `RSS` con `resource.getrusage` o `psutil` alrededor de cada bloque,
  para cubrir la métrica de memoria pico que pide el README general.
- Repetir el benchmark de integración con `n=1` y una función vacía para
  aislar el overhead puro de la llamada, sin trabajo de por medio.
