

# Tres casos análogos usando el mismo esquema de Monte Carlo con cadenas de Markov

A continuación se describen **tres casos análogos** en **física, química y biología**, usando el mismo esquema de **Monte Carlo con cadenas de Markov**, donde el fenómeno sea conceptualmente similar a la **depreciación/apreciación de una moneda frente al dólar**, es decir:

- Un **estado** (variable) que evoluciona en el tiempo.
- Con **tendencia** (drift) y **fluctuaciones aleatorias** (volatilidad).
- Modelado como **proceso de Markov** (el futuro depende solo del presente).

Aquí se tiene tres casos similares, con la misma estructura matemática pero con fenomenologías distintas:

------

## 1. **Física: Movimiento browniano de una partícula en suspensión**

## Fenomenología análoga

- **Moneda local** → posición de la partícula $x(t)$ en 1D.
- **Dólar** → posición de referencia (punto de equilibrio).
- **Depreciación/apreciación** → desplazamiento de la partícula respecto al equilibrio.

## Estado y evolución

- Estado: $x_t$ = posición de la partícula en el tiempo $t$.

- Modelo: movimiento browniano con deriva (drift):

  $x_{t+\Delta t} = x_t + \mu \Delta t + \sigma \sqrt{\Delta t} \, Z_t$

  donde:

  - $\mu$: velocidad media de desplazamiento (por ejemplo, por un campo eléctrico o gravitatorio).
  - $\sigma$: intensidad de las fluctuaciones térmicas.
  - $Z_t \sim \mathcal{N}(0,1)$.

## Pregunta típica

- ¿Cuál es la distribución de posiciones después de $T$ segundos?
- ¿Cuál es la probabilidad de que la partícula se desplace más de $x^*$ desde el origen?
- ¿Cuál es el desplazamiento esperado $\mathbb{E}[x_T]$?

## Aplicaciones

- Partículas en fluidos.
- Difusión en medios porosos.
- Movimiento de polímeros, coloides.

------

## 2. **Química: Concentración de un reactivo en una reacción reversible**

## Fenomenología análoga

- **Moneda local** → concentración $C(t)$ de un reactivo.
- **Dólar** → concentración de equilibrio $C_{eq}$.
- **Depreciación/apreciación** → desviación de la concentración respecto al equilibrio.

## Estado y evolución

- Estado: $C_t$ = concentración del reactivo en el tiempo $t$.

- Modelo estocástico:

  $C_{t+\Delta t} = C_t \cdot \exp\left( (\mu - \tfrac{1}{2}\sigma^2)\Delta t + \sigma \sqrt{\Delta t} \, Z_t \right)$

  donde:

  - $\mu$: tasa neta de consumo/producción (drift).
    - Si $\mu < 0$: el reactivo se consume (análoga a depreciación).
    - Si $\mu > 0$: el reactivo se produce (análoga a apreciación).
  - $\sigma$: fluctuaciones debidas a ruido térmico, inhomogeneidades, etc.

## Pregunta típica

- ¿Cuál es la distribución de concentraciones después de $T$ segundos?
- ¿Cuál es la probabilidad de que la concentración caiga por debajo de un umbral crítico?
- ¿Cuál es el tiempo esperado hasta que la concentración llegue a un valor específico?

## Aplicaciones

- Reacciones reversibles en química física.
- Cinética enzimática.
- Reacciones en microreactores con fluctuaciones.

------

## 3. **Biología: Tamaño de una población en un entorno con ruido ambiental**

## Fenomenología análoga

- **Moneda local** → tamaño de la población $N(t)$.
- **Dólar** → capacidad de carga o tamaño de referencia $N_{ref}$.
- **Depreciación/apreciación** → crecimiento o decrecimiento poblacional.

## Estado y evolución

- Estado: $N_t$ = tamaño de la población en el tiempo $t$.

- Modelo estocástico (proceso de crecimiento geométrico con ruido):

  $N_{t+\Delta t} = N_t \cdot \exp\left( (r - \tfrac{1}{2}\sigma^2)\Delta t + \sigma \sqrt{\Delta t} \, Z_t \right)$

  donde:

  - $r$: tasa de crecimiento intrínseca (drift).
    - $r > 0$: crecimiento poblacional (apreciación).
    - $r < 0$: decrecimiento, riesgo de extinción (depreciación).
  - $\sigma$: fluctuaciones ambientales (cambios de temperatura, recursos, etc.).

## Pregunta típica

- ¿Cuál es la distribución de tamaños poblacionales después de $T$ años?
- ¿Cuál es la probabilidad de que la población caiga por debajo de un umbral de extinción $N_{crit}$?
- ¿Cuál es el tiempo esperado hasta la extinción o hasta alcanzar la capacidad de carga?

## Aplicaciones

- Dinámica de poblaciones en ecología.
- Conservación de especies.
- Modelos epidemiológicos simples (número de infectados con fluctuaciones).

------

## Analogía conceptual entre los cuatro casos

| Área     | Variable de estado       | Referencia (“dólar”)         | Tendencia (drift)              | Fluctuaciones (volatilidad)              |
| -------- | ------------------------ | ---------------------------- | ------------------------------ | ---------------------------------------- |
| Finanzas | Tipo de cambio $S_t$     | 1 USD                        | Depreciación/apreciación $\mu$ | Volatilidad de mercado $\sigma$          |
| Física   | Posición $x_t$           | Punto de equilibrio          | Deriva $\mu$                   | Agitación térmica $\sigma$               |
| Química  | Concentración $C_t$      | Concentración de equilibrio  | Consumo/producción $\mu$       | Ruido térmico, inhomogeneidades $\sigma$ |
| Biología | Tamaño poblacional $N_t$ | Capacidad de carga $N_{ref}$ | Crecimiento/decrecimiento $r$  | Ruido ambiental $\sigma$                 |

En los cuatro casos:

- El **estado** evoluciona como un **proceso de Markov**.
- Hay una **tendencia sistemática** (drift).
- Hay **fluctuaciones aleatorias** modeladas con $Z_t \sim \mathcal{N}(0,1)$.
- Se puede usar el **mismo esqueleto de código Monte Carlo** con parametrización distinta.

------

## Conclusión

Sí, se aplica el mismo método de **Monte Carlo con cadenas de Markov** en:

1. **Física**: posición de una partícula browniana.
2. **Química**: concentración de un reactivo en una reacción reversible.
3. **Biología**: tamaño de una población en un entorno con ruido.

Todos son análogos al modelo financiero de depreciación/apreciación de una moneda, con la misma estructura matemática y metodología de simulación.