# Ejemplo: Manejo masivo de datos y estructuras

Segundo ítem del catálogo. Dos experimentos independientes, cada uno con
su propio par de tecnologías:

1. **Python ↔ C++ (pybind11)** — zero-copy vs copia explícita, sobre
   arrays densos.
2. **Python ↔ R (rpy2)** — transferencia de un `data.frame` completo,
   escalando filas, contra pandas puro como referencia.

## Estructura

```
data_bench/
├── cpp/
│   ├── data_transfer.cpp   # sum_view/scale_view (zero-copy) vs sum_copy/scale_copy
│   └── build.sh
├── r/
│   └── summarize.R         # función R invocada desde rpy2
├── python/
│   └── benchmark_data.py   # orquesta ambos experimentos, imprime tabla, guarda CSV
└── results/
```

## Experimento 1 — zero-copy vs copia (C++)

`sum_view`/`scale_view` acceden al buffer de NumPy directamente vía el
protocolo de buffer de pybind11 (`py::buffer_info`): ni una copia, se lee
o escribe la misma memoria que ya tiene Python. `sum_copy`/`scale_copy`
reciben `std::vector<double>`, que fuerza a pybind11 a copiar todo el
array al entrar (y, en el caso de `scale_copy`, otra copia más al volver).

### Resultados obtenidos

| n elementos | suma zero-copy | suma con copia | overhead | escalar zero-copy | escalar con copia | overhead |
|---|---|---|---|---|---|---|
| 10,000     | 1.26e-5 s | 3.80e-4 s | ~30×  | 2.30e-6 s | 5.31e-4 s | ~231× |
| 100,000    | 1.20e-4 s | 4.48e-3 s | ~37×  | 2.02e-5 s | 5.94e-3 s | ~294× |
| 1,000,000  | 1.23e-3 s | 4.36e-2 s | ~35×  | 2.87e-4 s | 6.82e-2 s | ~238× |
| 10,000,000 | 1.36e-2 s | 5.16e-1 s | ~38×  | 8.00e-3 s | 7.41e-1 s | ~93×  |

Lectura: el overhead de copia se mantiene en el mismo orden de magnitud
(30-40×) al escalar la suma, porque tanto sumar como copiar son O(n) —
la proporción entre ambos no cambia con el tamaño. En `scale`, en cambio,
el overhead de copia es mucho mayor (200-300×) porque ahí hay **dos**
copias (entrada y salida) contra una operación en el lugar que no copia
nada; y ese overhead cae a ~93× en 10M elementos porque ahí el costo de
memoria empieza a dominar sobre el de CPU en ambos casos por igual
(la copia dentro de C++ también se vuelve cara). El patrón confirma lo
que describe el README original: cuando hay que mover matrices o vectores
grandes entre lenguajes, la diferencia entre copia y acceso compartido no
es un detalle — es 1-2 órdenes de magnitud.

## Experimento 2 — Python ↔ R (rpy2) vs pandas puro

`summarize_df` en R calcula la media de cada columna de un `data.frame` —
el cómputo es trivial a propósito, para que el tiempo medido sea
básicamente el costo de la transferencia (conversión pandas → R,
ejecución, conversión R → pandas de vuelta), no el del análisis.

### Resultados obtenidos

| n filas | pandas puro | Python→R (rpy2) | overhead |
|---|---|---|---|
| 1,000     | 1.01e-4 s | 6.59e-3 s | ~65×    |
| 10,000    | 1.93e-4 s | 4.43e-2 s | ~230×   |
| 100,000   | 4.51e-4 s | 4.67e-1 s | ~1,034× |
| 1,000,000 | 5.87e-3 s | 5.17e0 s  | ~881×   |

Lectura: el overhead de rpy2 crece muchísimo más rápido que el de
pybind11 — no es un costo fijo por llamada, sino un costo por elemento
transferido que además incluye conversión de tipos entre el modelo de
objetos de R y el de pandas/NumPy, no solo copia de bytes. A diferencia
del experimento con C++, aquí no hay "modo zero-copy" disponible: rpy2
siempre serializa la estructura completa en ambas direcciones. Esto es
justamente el tipo de hallazgo que el README pide poder cuantificar antes
de decidir si conviene delegar un análisis a R desde un pipeline en
Python, o si el costo de la transferencia se come cualquier ventaja del
cómputo en R.

## Requisitos previos

```bash
sudo apt install r-base-core
sudo apt install python3-numpy
sudo apt install python3-pandas
sudo apt install python3-pybind11
sudo apt install python3-rpy2
```

`r-base-core` es imprescindible aunque no aparezca explícito más arriba:
sin R instalado en el sistema, rpy2 no tiene qué embeber. La versión de R
del sistema y la de rpy2 tienen que ser compatibles entre sí — ver
"Posibles fallas" más abajo.

## Cómo correrlo

```bash
cd cpp
./build.sh
export CPATH=/usr/include/python3.13:$CPATH   # ajustar al minor de tu python3
cd ../python
python3 benchmark_data.py
```

La variable `CPATH` le indica al compilador dónde están los headers de
Python (`Python.h`) cuando `python3-config` o el paquete de desarrollo no
los deja en una ruta estándar — sin ella, `build.sh` puede fallar al no
encontrar `Python.h` durante la compilación. Ajusta `python3.13` a la
versión que tengas instalada (`python3 --version`).

## Posibles fallas

**`ModuleNotFoundError: No module named 'data_transfer'`**
El script no encuentra el `.so` compilado. Casi siempre es porque el
proyecto se movió o reorganizó y las rutas relativas (`Path(__file__).parent...`)
ya no apuntan a donde quedó `build/`. Confirma con `ls` dónde está el
`.so` respecto a `benchmark_data.py` y ajusta la ruta en el
`sys.path.insert(...)` al inicio del script — contando los niveles
`parent` uno por uno en vez de asumirlos.

**`RRuntimeError: cannot open the connection` / `cannot open file '...summarize.R'`**
Mismo problema que el anterior pero con `r.source(...)`: la ruta relativa
a `summarize.R` no coincide con dónde quedó el archivo tras mover o
reorganizar el proyecto. Si el error persiste tras un primer ajuste,
revisa la ruta completa que imprime R en el mensaje de error — indica
exactamente dónde buscó, lo cual delata cuántos niveles `parent` sobran o
faltan.

**`ImportError: cannot import name 'SexpVectorCCompatibleAbstract'` o
`undefined symbol` al importar rpy2**
Desajuste entre la versión de rpy2 y la de R instalada en el sistema. Las
versiones 3.6.x de rpy2 requieren R ≥ 4.4; con R 4.3.x hay que fijar
`rpy2==3.5.17`. Si el error aparece después de cambiar de versión, revisa
también que no queden paquetes `rpy2-rinterface` / `rpy2-robjects`
huérfanos de una instalación anterior — desinstala los tres
(`rpy2 rpy2-rinterface rpy2-robjects`) y reinstala la versión fijada desde
cero en vez de solo hacer `pip install --force-reinstall rpy2`.

**Compilación falla por `Python.h: No such file or directory`**
Falta `CPATH` apuntando a los headers de desarrollo de Python, o falta el
paquete `python3-dev`/`python3.X-dev` correspondiente a tu versión.

## Extensiones naturales

- Repetir el experimento de R con `reticulate` (el wrapper inverso, R
  llamando Python) para comparar el overhead en ambos sentidos.
- Medir RSS durante la transferencia a R, ya que ahí conviven dos
  runtimes completos (Python + R embebido) y el pico de memoria puede ser
  mucho más relevante que en el caso pybind11.
- Escalar el experimento de C++ a `float32` vs `float64` para ver si el
  overhead de copia escala con el tamaño en bytes o es independiente del
  tipo.
