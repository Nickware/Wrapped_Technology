# Depreciación/apreciación de una moneda local frente al dólar con GSL + C++ + Octave

Propuesta que busca implementar un **modelo de Monte Carlo sencillo con cadenas de Markov** para simular la **depreciación/apreciación de una moneda local frente al dólar**, usando:

- **C++** como lenguaje principal.
- **GSL** para:
  - Generación de números aleatorios con distribuciones.
  - Simulación de trayectorias.
- **Octave** (opcional después) para:
  - Visualizar trayectorias.
  - Analizar distribuciones de precios finales.
  - Calcular valor esperado y percentiles.

------

## Idea del modelo financiero

Modelamos la tasa de cambio $S_t$ (precio de 1 USD en moneda local) como un proceso estocástico:

Usemos un modelo de **paseo aleatorio geométrico** (similar al de Black–Scholes, pero simplificado):

$S_{t+\Delta t} = S_t \cdot \exp\left( (\mu - \tfrac{1}{2}\sigma^2)\Delta t + \sigma \sqrt{\Delta t} \, Z_t \right)$

donde:

- $S_t$: tipo de cambio en el tiempo $t$.
- $\mu$: tasa de depreciación/apreciación esperada (drift).
- $\sigma$: volatilidad.
- $\Delta t$: paso de tiempo (por ejemplo, 1 día en años: $\Delta t = 1/252$).
- $Z_t \sim \mathcal{N}(0,1)$: variable normal estándar (generada con GSL).

Esto es un **proceso de Markov**: el estado futuro depende solo del estado actual.

Con Monte Carlo:

- Simulamos $N$ trayectorias de $S_t$ hasta un horizonte $T$.
- Obtenemos la distribución de $S_T$.
- Calculamos:
  - Valor esperado $\mathbb{E}[S_T]$.
  - Percentiles (VaR, por ejemplo).
  - Probabilidad de que la moneda se deprecie más de x%.

------

## Esquema del programa en C++ con GSL

## 1. Parámetros del modelo

- `S0`: tipo de cambio inicial (ej. 1 USD = 1000 moneda local).
- `mu`: drift (ej. 0.05 anual = 5% de depreciación esperada).
- `sigma`: volatilidad anual (ej. 0.2 = 20%).
- `T`: horizonte en años (ej. 1 año).
- `n_steps`: número de pasos (ej. 252 = días laborables).
- `n_paths`: número de trayectorias Monte Carlo (ej. 10000).

## 2. Algoritmo

Para cada trayectoria $i = 1 \dots N$:

1. Inicializar $S = S_0$.
2. Para cada paso $j = 1 \dots n\_steps$:
   - Generar $Z \sim \mathcal{N}(0,1)$ con GSL.
   - Actualizar $S$ con la fórmula anterior.
3. Guardar $S_T$ (valor final).

Al final:

- Calcular media, varianza, percentiles de los $S_T$.
- Opcional: guardar todas las trayectorias en un archivo para Octave.

------

## Código C++ con GSL (esqueleto completo)

Aquí tienes un código **sencillo, limpio y comentado**, listo para compilar con GSL:

```
cpp// mc_currency.cpp
// Modelo Monte Carlo con C++ y GSL para depreciación de moneda local vs USD

#include <iostream>
#include <fstream>
#include <cmath>
#include <vector>
#include <iomanip>
#include <cstdlib>
#include <gsl/gsl_rng.h>
#include <gsl/gsl_randist.h>
#include <gsl/gsl_statistics_double.h>

int main() {
    // --- Parámetros del modelo ---
    double S0 = 1000.0;      // Tipo de cambio inicial: 1 USD = S0 moneda local
    double mu = 0.05;        // Drift anual (5% de depreciación esperada)
    double sigma = 0.20;     // Volatilidad anual (20%)
    double T = 1.0;          // Horizonte en años
    int n_steps = 252;       // Pasos (días laborables)
    int n_paths = 10000;     // Número de trayectorias Monte Carlo

    double dt = T / n_steps; // Paso de tiempo en años

    // Configuración de generador aleatorio GSL
    const gsl_rng_type *T_gsl = gsl_rng_mt19937;
    gsl_rng *r = gsl_rng_alloc(T_gsl);
    gsl_rng_set(r, 12345);   // Semilla fija para reproducibilidad

    // Archivos de salida
    std::ofstream f_paths("trayectorias.csv");
    std::ofstream f_final("valores_finales.csv");

    // Escribir cabecera
    f_paths << "trayectoria,tempo_anual,S\n";
    f_final << "trayectoria,S_T\n";

    std::vector<double> S_final(n_paths);

    // --- Monte Carlo ---
    for (int i = 0; i < n_paths; ++i) {
        double S = S0;
        f_paths << i << "," << 0.0 << "," << S << "\n";

        for (int j = 1; j <= n_steps; ++j) {
            double Z = gsl_ran_gaussian(r, 1.0); // Normal estándar
            double dS = S * std::exp((mu - 0.5 * sigma * sigma) * dt +
                                     sigma * std::sqrt(dt) * Z);
            S = dS;

            double t = j * dt;
            f_paths << i << "," << t << "," << S << "\n";
        }

        S_final[i] = S;
        f_final << i << "," << S << "\n";
    }

    f_paths.close();
    f_final.close();

    // --- Estadísticas de los valores finales ---
    double mean = gsl_stats_mean(S_final.data(), 1, n_paths);
    double var = gsl_stats_variance(S_final.data(), 1, n_paths);
    double sd = std::sqrt(var);

    std::cout << "=== Modelo Monte Carlo: Depreciación de moneda vs USD ===\n";
    std::cout << "S0 = " << S0 << " moneda local por USD\n";
    std::cout << "mu (drift anual) = " << mu << "\n";
    std::cout << "sigma (volatilidad anual) = " << sigma << "\n";
    std::cout << "Horizonte T = " << T << " años\n";
    std::cout << "n_steps = " << n_steps << "\n";
    std::cout << "n_paths = " << n_paths << "\n\n";

    std::cout << "Resultados Monte Carlo:\n";
    std::cout << "  E[S_T] = " << mean << " moneda local por USD\n";
    std::cout << "  SD[S_T] = " << sd << "\n";
    std::cout << "  Appreciación/depreciación esperada: "
              << (mean - S0) / S0 * 100.0 << "%\n";

    // Ordenar para percentiles (copia simple)
    std::vector<double> S_sorted = S_final;
    std::sort(S_sorted.begin(), S_sorted.end());

    auto get_percentile = [&](double p) {
        int idx = static_cast<int>(p * (n_paths - 1));
        return S_sorted[idx];
    };

    double VaR_95 = get_percentile(0.95); // 95% de probabilidad S_T <= VaR_95
    double VaR_05 = get_percentile(0.05);

    std::cout << "\nPercentiles de S_T:\n";
    std::cout << "  5%  (pérdida extrema baja): " << VaR_05 << "\n";
    std::cout << "  95% (pérdida extrema alta): " << VaR_95 << "\n";

    double depreciation_95 = (VaR_95 - S0) / S0 * 100.0;
    std::cout << "\nCon 95% de confianza, la depreciación máxima será <= "
              << depreciation_95 << "%\n";

    gsl_rng_free(r);
    return 0;
}
```

------

## Compilación y ejecución

En Ubuntu/Debian, compila así:

```
bashg++ -O2 -o mc_currency mc_currency.cpp -lgsl -lgslcblas -lm
./mc_currency
```

Esto genera:

- `trayectorias.csv`: todas las trayectorias (para Octave).
- `valores_finales.csv`: solo valores finales $S_T$.
- Salida en consola con estadísticas.

------

## Análisis en Octave (opcional)

En Octave, puedes:

```
matlab% Leer valores finales
data = dlmread('valores_finales.csv', ',');
ST = data(:, 2);

figure;
histogram(ST, 50);
xlabel('S_T (moneda local por USD)');
ylabel('Frecuencia');
title('Distribución de S_T al final del horizonte');

% Estadísticas
mean_ST = mean(ST);
std_ST = std(ST);
p5 = prctile(ST, 5);
p95 = prctile(ST, 95);

disp(['E[S_T] = ', num2str(mean_ST)]);
disp(['SD[S_T] = ', num2str(std_ST)]);
disp(['5%  = ', num2str(p5)]);
disp(['95% = ', num2str(p95)]);
```

------

## ¿Qué evalúa este modelo con MonteCarlo?

- Evolución esperada de la moneda local vs USD.
- Probabilidad de depreciación fuerte.
- Rango de fluctuación (percentiles).
- Valor en riesgo (VaR) para la moneda.
