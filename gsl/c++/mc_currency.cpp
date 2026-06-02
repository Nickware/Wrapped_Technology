// mc_currency.cpp
// Modelo Monte Carlo con C++ y GSL para depreciación de moneda local vs USD

#include <iostream>
#include <fstream>
#include <cmath>
#include <vector>
#include <iomanip>
#include <cstdlib>
#include <algorithm>
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
