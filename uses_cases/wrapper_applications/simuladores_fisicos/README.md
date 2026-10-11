# Simuladores físicos para aprendizaje por refuerzo

**Estado: primera implementación disponible.** Incluye un CartPole 2D en C++,
un módulo pybind11 y un benchmark nativo para comparar la misma dinámica. Aún
no hay resultados publicados ni una comparación automatizada de CSV.

## Objetivo

En aprendizaje por refuerzo, un agente elige una acción a partir de una
observación, el entorno avanza y devuelve la siguiente observación, una
recompensa y señales que indican si el episodio terminó. La física puede
permanecer en C++; Python coordina el agente y el ciclo de entrenamiento.

La primera etapa es un CartPole 2D sin renderizado. Es un entorno pequeño y
determinista que permite estudiar llamadas frecuentes sin añadir dependencias
pesadas ni confundir el costo del wrapper con gráficos o una política de
aprendizaje compleja. El agente de prueba es una política determinista simple,
no un algoritmo de entrenamiento.

El wrapper puede implementarse con pybind11, tecnología que ya aparece en
[el ejemplo C++/Python de este repositorio](../../../c++python/Readme.md).
Una capa Python puede adaptar la API nativa a la interfaz que espera el
entrenador, por ejemplo Gymnasium, sin trasladar a Python el cálculo de la
física.

## Flujo de una interacción

1. Python crea el entorno y llama a `reset(seed)`; C++ inicializa el mundo y
   devuelve la observación inicial.
2. El agente calcula una acción en Python.
3. Python llama a `step(action)`. El wrapper valida y convierte la acción,
   invoca el avance del simulador en C++ y obtiene el nuevo resultado.
4. C++ actualiza su estado interno y devuelve la observación, la recompensa y
   las señales de terminación. Python las entrega al agente y comienza el
   siguiente paso.

Una interfaz compatible con Gymnasium suele representar la interacción así:

```python
observation, info = env.reset(seed=seed)
observation, reward, terminated, truncated, info = env.step(action)
```

El estado físico interno no tiene por qué cruzar la frontera completo. Lo
habitual es que permanezca en C++ y que el simulador transfiera solo la
observación necesaria para el agente, junto con la acción de entrada y los
resultados escalares. El tamaño, formato y frecuencia de esos datos influyen
en el costo medido.

## Qué medir

- **Latencia por paso:** tiempo de una llamada `step(action)` y su distribución
  (por ejemplo, mediana y percentil 95). Mantener fuera de la región medida la
  inferencia de la política; medir `reset` aparte.
- **Throughput:** pasos por segundo y episodios por segundo. Fijar la duración
  de los episodios o reportar también los pasos por episodio, pues episodios de
  distinta longitud no son directamente comparables.
- **Transferencia de datos:** estimar el payload numérico por paso y registrar
  conversiones, asignaciones y copias. Comparar datos pequeños y grandes, y
  documentar si se reutilizan buffers o hay zero-copy.

## Implementación y compilación

`cartpole_core.cpp` implementa las ecuaciones clásicas de CartPole de
Gymnasium: masas 1.0/0.1 kg, semilongitud del péndulo 0.5 m, gravedad 9.8
m/s², fuerza 10 N, paso de 0.02 s, integración Euler y límites de posición y
ángulo de CartPole-v1. La recompensa es 1 por paso y el episodio se trunca a
los 500 pasos. El estado y la observación tienen el orden
`[x, x_dot, theta, theta_dot]`.

`reset(seed)` genera los cuatro componentes dentro de `[-0.05, 0.05]`. La
semilla es reproducible en este simulador, pero utiliza SplitMix64 y por ello
no reproduce la secuencia aleatoria de NumPy/Gymnasium. La API no acepta pasos
después de terminar un episodio; hay que llamar a `reset`.

Se requiere un compilador C++ y pybind11 instalado en el mismo Python usado
para compilar y ejecutar:

```bash
python3 -m pip install pybind11
sh build.sh
PYTHONPATH=build python3 -m unittest test_cartpole.py
```

El script crea `build/cartpole<extension-suffix>` y
`build/native_benchmark`. El núcleo físico es compartido por el módulo y el
ejecutable nativo.

## Script recolector

[`benchmark.py`](benchmark.py) recoge latencia por paso, throughput, tiempo de
reinicio y estimaciones del payload lógico en la ruta Python→pybind11. El
ejecutable `native_benchmark` mide el baseline C++ con la misma política,
semillas y parámetros. Ambos escriben CSV con columnas compatibles; los
campos de payload y `echo` quedan vacíos para el baseline, porque no cruza la
frontera Python/C++.

El módulo C++ debe exponer una clase (por defecto, `CartPole`) con esta API:

- `reset(seed=...)` devuelve `(observation, info)`.
- `step(action)` devuelve `(observation, reward, terminated, truncated, info)`.
- Opcionalmente, `echo_observation(observation)` permite medir una llamada de
  ida y vuelta de los datos sin avanzar la simulación.

Desde esta carpeta, ejecutar ambas variantes con los mismos argumentos:

```bash
PYTHONPATH=build python3 benchmark.py --module cartpole --class-name CartPole \\
  --episodes 100 --max-steps 500 --warmup-episodes 5 --repeats 5 --seed 1234 \\
  --output build/wrapped_benchmark.csv
build/native_benchmark --episodes 100 --max-steps 500 \\
  --warmup-episodes 5 --repeats 5 --seed 1234 \\
  --output build/native_benchmark.csv
```

Cada fila del CSV corresponde a una repetición e incluye latencia p50/p95 por
paso, latencia p50 de `reset`, pasos y episodios por segundo. La política
determinista queda fuera del cronómetro individual de `step`; el throughput se
mide en una pasada aparte e incluye la política y los reinicios. `--max-steps`
limita el bucle del benchmark; el entorno también aplica el límite de 500
pasos de CartPole-v1.

`action_payload_bytes_per_step_estimate` y
`result_payload_bytes_per_step_estimate` cuentan el tamaño lógico de la acción
enviada y de la observación/recompensa/señales recibidas. No son conteos de
bytes realmente copiados: excluyen metadatos del binding y el diccionario
`info`. La latencia opcional `echo_observation` incluye la llamada y cualquier
conversión o creación de objetos; no mide una copia de memoria aislada.

## Diseño de la comparación

Usar la misma escena, parámetros físicos, paso de tiempo, secuencia de
acciones, precisión numérica y semillas en cada variante. Los dos recolectores
usan la misma política determinista y el mismo núcleo físico, por lo que las
acciones se generan de forma idéntica. La comparación actual mide un entorno
por llamada:

1. **Ejecución nativa:** avanzar el simulador desde C++ con la secuencia de
   acciones fijada.
2. **Ejecución envuelta:** ejecutar los mismos pasos mediante la API Python y
   el wrapper C++.
3. **Transferencia aislada (opcional):** medir el intercambio de estructuras de
   acción y observación con una operación nativa mínima, sin confundirla con el
   cálculo de la física.

La diferencia entre la ejecución envuelta y la nativa aproxima el costo
adicional de la interfaz para ese workload; no debe interpretarse como un
costo universal ni atribuirse toda la diferencia a copias. Inicialización,
reinicios, inferencia de la política, renderizado y sincronización deben
medirse por separado o incluirse explícitamente en el tiempo total.

Para estudiar entornos vectorizados, medir como una variante independiente una
llamada por entorno frente a una llamada por lote (`step_batch`). El lote puede
reducir cruces de frontera, pero solo es una comparación válida si conserva la
misma semántica y trabajo físico.

## Perspectivas de la propuesta

1. **Aislar el costo de la frontera.** Implementar el mismo CartPole en C++ y
  ofrecer `reset`/`step` a Python con pybind11. Comparar el avance nativo y el
  envuelto usando la misma secuencia de acciones. Mantener la inferencia de la
  política fuera de la medición por paso.
2. **Entender qué se transfiere.** Empezar con la observación pequeña de
  CartPole y luego variar su tamaño y formato. Registrar conversiones y
  asignaciones; evaluar buffers reutilizables solo si son seguros.
3. **Estudiar granularidad.** Añadir `step_batch` para comparar una llamada
  por entorno con una llamada por lote. Reportar por separado latencia por
  entorno y throughput agregado.
4. **Aumentar realismo.** Tras validar el protocolo controlado, aplicar la
  misma interfaz a un simulador con física más compleja, como MuJoCo. En esa
  etapa habrá que registrar solver, escena, frecuencia de renderizado,
  concurrencia y hardware.

Estas etapas permiten distinguir tres preguntas: cuánto cuesta llamar al
simulador desde Python, cuánto cuestan los datos que cruzan la frontera y cómo
se comporta la integración en un flujo de RL más realista. No se anticipan
speedups: cada etapa requiere mediciones reproducibles.

## Consideraciones de implementación

- Mantener el estado interno y el solver físico en C++; exponer únicamente las
  acciones y observaciones necesarias.
- Fijar tipos, dimensiones, orden de memoria y unidades para cada arreglo.
- Considerar buffers reutilizables para reducir asignaciones; usar zero-copy
  solo si el contrato de propiedad, vida útil y concurrencia es seguro.
- Si se libera el GIL durante el cálculo nativo, hacerlo únicamente mientras
  el código no acceda a la API de Python; las conversiones de entrada y salida
  requieren el GIL.
- Comprobar que las variantes producen observaciones y recompensas equivalentes
  dentro de la tolerancia numérica elegida.

## Reproducibilidad

Registrar hardware, sistema operativo, compilador y opciones, versiones de
Python, pybind11 y del simulador, número de entornos, política de batching,
semillas, duración de calentamiento y repeticiones. Reportar variabilidad junto
con las métricas centrales. No comparar resultados obtenidos con escenas,
solvers, precisión o condiciones de ejecución distintas.
