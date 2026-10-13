# Casos de uso específicos para comparar tecnologías wrapper

Este catálogo reúne casos multidisciplinares en física, matemáticas,
economía, ciencia de datos, medio ambiente y energía. Las entradas son
propuestas o referencias, salvo las que se marcan como implementadas. Las
fuentes externas aportan contexto; no representan mediciones de este
repositorio.

Los casos no miden necesariamente el mismo fenómeno. Compara resultados solo
cuando coincidan el workload, el baseline y las condiciones de ejecución.

## Física y simulaciones

- **[Propuesto] Surface wrapping para mallas CFD/FEM.** Envolver una biblioteca
	C++ desde Python con pybind11 para generar mallas a partir de geometrías
	complejas. Medir tiempo, calidad de la malla y efecto en el solver posterior.
	[Referencia sobre surface wrapping](https://old.opencascade.com/content/surface-wrapping-simulation).
- **[Propuesto] Simuladores físicos para aprendizaje por refuerzo.** Invocar
	un simulador C++ desde Python; medir latencia por paso, throughput de
	episodios y costo de transferir estados. [Ejemplo de integración con
	simuladores](https://www-labs.iro.umontreal.ca/~gberseth/interfacing-with-simulators-for-rl.html).
- **[Propuesto] Digital twins con sensores IoT.** Integrar lecturas de
	humedad o temperatura con un modelo físico; evaluar latencia por
	actualización, throughput y concurrencia. [Referencia sobre digital twins](https://pmc.ncbi.nlm.nih.gov/articles/PMC9611674/).

## Matemáticas computacionales

- **[Implementado] Cálculo numérico intensivo.** Mandelbrot e integración
	comparan Python puro, pybind11 de grano fino y grueso, y NumPy. Consulta
	[el benchmark y los resultados](calculo_numerico/README.md).
- **[Propuesto] BLAS/LAPACK acelerados por GPU.** Comparar interfaces Python o
	Julia hacia cuBLAS en operaciones y tamaños de matriz equivalentes; registrar
	hardware, precisión y uso de memoria. [Referencia sobre cuBLAS](https://www.compchemday.org/wp-content/uploads/2025/07/CCD2025-Nenad_Mijic.pdf).
- **[Propuesto] Solvers PDE y PINNs.** Integrar SciANN/Keras/TensorFlow y
	separar tiempo de entrenamiento, precisión y costo de integración.
	[Referencia sobre SciANN](https://www.sciencedirect.com/science/article/abs/pii/S0045782520307374).

## Economía y finanzas cuantitativas

- **[Propuesto] Portafolios y optimización.** Envolver solvers lineales para
	modelos de equilibrio y comparar tiempo por tamaño del problema, manteniendo
	constante el método numérico. [Material de QuantEcon](https://python-advanced.quantecon.org/_pdf/quantecon-python-advanced.pdf).
- **Uso financiero del término wrapper.** Los fondos UCITS pueden envolver
	estrategias o índices, pero sus métricas son financieras y operativas, no
	overhead de software. Se conserva como contexto multidisciplinar, no como
	benchmark de bindings. [Referencia](https://www.quantilia.com/funds-wrapper-quantitative-strategies/).

## Ciencia de datos y ML

- **[Implementado] Manejo masivo de datos y estructuras.** Compara zero-copy
	frente a copia en pybind11 y transferencia Python↔R con rpy2 frente a pandas.
	Consulta [el benchmark y sus requisitos](manejo_datos/README.md).
- **[Propuesto] Inferencia de modelos.** Evaluar throughput y latencia de
	servicio, documentando por separado runtime, hardware y wrapper.
	[Referencia de MLPerf Inference](https://developer.nvidia.com/blog/nvidia-blackwell-delivers-massive-performance-leaps-in-mlperf-inference-v5-0/).
- **Otro uso del término wrapper en ML.** La selección de características
	wrapper (por ejemplo, RFE) evalúa subconjuntos de variables con un modelo;
	no es un binding entre lenguajes. [Referencia introductoria](https://peerdh.com/blogs/programming-insights/algorithm-performance-comparison-for-filter-vs-wrapper-methods-in-feature-selection).

## Temas emergentes: medio ambiente y energías

- **[Propuesto] Predicción de incendios y deforestación.** Integrar datos
	geoespaciales y sensores; medir latencia de detección, falsos positivos y
	throughput por región. [Referencia](https://www.calcalistech.com/ctechnews/article/skeucrpykg).
- **[Propuesto] Optimización de renovables y redes eléctricas.** Combinar
	pronósticos de viento o solar con planificación; medir latencia, consumo y
	desperdicio de energía. [Referencia sobre climate tech](https://visible.vc/blog/climate-tech-startups/).
- **[Propuesto] Modelos climáticos híbridos y workflows científicos.**
	Integrar modelos de IA, simulación física y planificación de trabajos;
	evaluar precisión, tiempo y energía. [Referencia sobre workflows eficientes](https://pmc.ncbi.nlm.nih.gov/articles/PMC4446568/).

## Métricas transversales sugeridas

- Overhead de llamadas y transferencia, separado del cómputo nativo cuando
	sea posible.
- Escalabilidad según tamaño de datos y número de llamadas.
- Memoria pico, consumo energético y uso de recursos cuando sean pertinentes.
- Robustez: errores de tipos, gestión de memoria y compatibilidad. [Referencia
	sobre FFI y WebAssembly](https://blog.flipt.io/from-ffi-to-wasm).

Para que los resultados sean interpretables, documenta baseline, workload,
hardware, sistema operativo, versiones, opciones de compilación, repeticiones
y variabilidad. Mide por separado llamada vacía, transferencia, cómputo y
tiempo end-to-end cuando el caso lo permita; no compares speedups de estudios
distintos si esas condiciones cambian.
