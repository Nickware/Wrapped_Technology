"""
Benchmark de "Cálculo numérico intensivo" para comparar tecnologías wrapper.

Dos ejes del README quedan cubiertos aquí:

1. Muchas llamadas baratas vs pocas llamadas caras
   -> mandelbrot_pixel (una llamada C++ por píxel, invocada desde un bucle
      Python) vs mandelbrot_region (una sola llamada que hace todo el
      trabajo del lado nativo).

2. Umbral donde "vale la pena" envolver código nativo
   -> integrate_trapz, variando n. Para n pequeño el overhead de una sola
      llamada domina; para n grande domina el trabajo real.

Se incluye además la versión NumPy vectorizada del Mandelbrot como tercer
punto de referencia (approach "sin wrapper explícito", delegando en
operaciones de array).
"""

import sys
import time
import csv
from pathlib import Path

sys.path.insert(0, str(Path(__file__).parent))
sys.path.insert(0, str(Path(__file__).parent.parent / "cpp" / "build"))

import numpy as np
import wrapper_bench as wb
from pure_python import mandelbrot_pixel_py, mandelbrot_region_py, integrate_trapz_py


def timeit(fn, *args, repeats=3, **kwargs):
    """Devuelve el mejor tiempo de `repeats` ejecuciones (reduce ruido del sistema)."""
    best = float("inf")
    result = None
    for _ in range(repeats):
        t0 = time.perf_counter()
        result = fn(*args, **kwargs)
        best = min(best, time.perf_counter() - t0)
    return best, result


def mandelbrot_region_numpy(xmin, xmax, ymin, ymax, width, height, max_iter):
    x = np.linspace(xmin, xmax, width)
    y = np.linspace(ymin, ymax, height)
    cx, cy = np.meshgrid(x, y)
    c = cx + 1j * cy
    z = np.zeros_like(c)
    counts = np.zeros(c.shape, dtype=int)
    mask = np.ones(c.shape, dtype=bool)
    for i in range(max_iter):
        z[mask] = z[mask] * z[mask] + c[mask]
        escaped = np.abs(z) > 2.0
        newly = escaped & mask
        counts[newly] = i
        mask &= ~escaped
    counts[mask] = max_iter
    return counts


def bench_mandelbrot(sizes, max_iter=100):
    """
    Para cada resolución (width == height), compara:
      - Python puro (bucle anidado, llamada por píxel)
      - pybind11 grano fino (una llamada C++ por píxel, bucle en Python)
      - pybind11 grano grueso (una sola llamada, bucle en C++)
      - NumPy vectorizado
    """
    rows = []
    for n in sizes:
        t_py, _ = timeit(mandelbrot_region_py, -2, 1, -1.5, 1.5, n, n, max_iter, repeats=1)

        def fine(n=n):
            dx = 3.0 / n
            dy = 3.0 / n
            out = [[0] * n for _ in range(n)]
            for row in range(n):
                cy = -1.5 + row * dy
                for col in range(n):
                    cx = -2 + col * dx
                    out[row][col] = wb.mandelbrot_pixel(cx, cy, max_iter)
            return out

        t_fine, _ = timeit(fine, repeats=1)
        t_coarse, _ = timeit(wb.mandelbrot_region, -2, 1, -1.5, 1.5, n, n, max_iter, repeats=3)
        t_numpy, _ = timeit(mandelbrot_region_numpy, -2, 1, -1.5, 1.5, n, n, max_iter, repeats=3)

        rows.append({
            "size": f"{n}x{n}",
            "n_calls": n * n,
            "python_puro_s": t_py,
            "pybind11_grano_fino_s": t_fine,
            "pybind11_grano_grueso_s": t_coarse,
            "numpy_vectorizado_s": t_numpy,
            "speedup_grueso_vs_python": t_py / t_coarse,
            "speedup_grueso_vs_fino": t_fine / t_coarse,
        })
    return rows


def bench_integration(ns, repeats_per_n=200):
    """
    Simula el escenario 'llamada de alta frecuencia vs baja frecuencia':
    para cada n, se hace una sola llamada (a=0, b=10) pero se repite
    `repeats_per_n` veces para tener una señal de tiempo medible, y se
    reporta el tiempo POR LLAMADA. Así se ve dónde el overhead fijo de
    cruzar a C++ deja de ser relevante frente al trabajo (proporcional a n).
    """
    rows = []
    for n in ns:
        t_py, _ = timeit(
            lambda: [integrate_trapz_py(0, 10, n) for _ in range(repeats_per_n)],
            repeats=3,
        )
        t_native, _ = timeit(
            lambda: [wb.integrate_trapz_native(0, 10, n) for _ in range(repeats_per_n)],
            repeats=3,
        )
        rows.append({
            "n_subintervalos": n,
            "python_puro_s_por_llamada": t_py / repeats_per_n,
            "pybind11_s_por_llamada": t_native / repeats_per_n,
            "speedup": (t_py / repeats_per_n) / (t_native / repeats_per_n),
        })
    return rows


def print_table(rows, title):
    print(f"\n=== {title} ===")
    if not rows:
        return
    headers = list(rows[0].keys())
    widths = [max(len(h), max(len(f"{r[h]:.6g}" if isinstance(r[h], float) else str(r[h])) for r in rows)) for h in headers]
    print("  ".join(h.ljust(w) for h, w in zip(headers, widths)))
    for r in rows:
        cells = [f"{v:.6g}" if isinstance(v, float) else str(v) for v in r.values()]
        print("  ".join(c.ljust(w) for c, w in zip(cells, widths)))


def save_csv(rows, path):
    if not rows:
        return
    with open(path, "w", newline="") as f:
        writer = csv.DictWriter(f, fieldnames=list(rows[0].keys()))
        writer.writeheader()
        writer.writerows(rows)


if __name__ == "__main__":
    mandelbrot_rows = bench_mandelbrot(sizes=[20, 50, 100, 200], max_iter=100)
    print_table(mandelbrot_rows, "Mandelbrot: muchas llamadas baratas vs una llamada cara")

    integration_rows = bench_integration(ns=[10, 100, 1_000, 10_000, 100_000])
    print_table(integration_rows, "Integración: overhead fijo vs trabajo por llamada")

    out_dir = Path(__file__).parent.parent / "results"
    out_dir.mkdir(exist_ok=True)
    save_csv(mandelbrot_rows, out_dir / "mandelbrot_results.csv")
    save_csv(integration_rows, out_dir / "integration_results.csv")
    print(f"\nResultados guardados en {out_dir}/")
