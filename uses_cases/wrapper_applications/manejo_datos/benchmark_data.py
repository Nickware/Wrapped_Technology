"""
Benchmark de "Manejo masivo de datos y estructuras".

Dos experimentos, siguiendo el README original:

1. Python <-> C++ (pybind11): zero-copy (buffer protocol) vs copia
   explícita (conversión automática numpy -> std::vector).

2. Python <-> R (rpy2): transferencia de un data.frame completo, escalando
   filas hasta el orden de millones, comparado contra el equivalente en
   pandas puro (sin cruzar a R) como referencia de "costo cero de wrapper".
"""

import sys
import time
import csv
from pathlib import Path

sys.path.insert(0, str(Path(__file__).parent / "build"))

import numpy as np
import pandas as pd
import data_transfer as dt

from rpy2.robjects import pandas2ri, r, default_converter
from rpy2.robjects.conversion import localconverter

_conv = default_converter + pandas2ri.converter

r.source(str(Path(__file__).parent / "summarize.R"))

def timeit(fn, *args, repeats=3, **kwargs):
    best = float("inf")
    result = None
    for _ in range(repeats):
        t0 = time.perf_counter()
        result = fn(*args, **kwargs)
        best = min(best, time.perf_counter() - t0)
    return best, result


# ---------------------------------------------------------------------
# Experimento 1: zero-copy vs copia (Python <-> C++)
# ---------------------------------------------------------------------

def bench_cpp_transfer(sizes):
    rows = []
    for n in sizes:
        arr = np.random.rand(n)

        t_sum_view, _ = timeit(dt.sum_view, arr, repeats=5)
        t_sum_copy, _ = timeit(dt.sum_copy, arr, repeats=5)

        arr_view = arr.copy()
        arr_copy = arr.copy()
        t_scale_view, _ = timeit(dt.scale_view, arr_view, 2.0, repeats=5)
        t_scale_copy, _ = timeit(dt.scale_copy, arr_copy, 2.0, repeats=5)

        rows.append({
            "n_elementos": n,
            "sum_zero_copy_s": t_sum_view,
            "sum_con_copia_s": t_sum_copy,
            "overhead_copia_sum": t_sum_copy / t_sum_view,
            "scale_zero_copy_s": t_scale_view,
            "scale_con_copia_s": t_scale_copy,
            "overhead_copia_scale": t_scale_copy / t_scale_view,
        })
    return rows


# ---------------------------------------------------------------------
# Experimento 2: Python <-> R (rpy2) vs pandas puro
# ---------------------------------------------------------------------

def bench_r_transfer(row_counts):
    rows = []
    for n in row_counts:
        df = pd.DataFrame({
            "a": np.random.rand(n),
            "b": np.random.rand(n),
            "c": np.random.rand(n),
        })

        def via_r():
            with localconverter(_conv):
                r_df = pandas2ri.py2rpy(df)
                result = r["summarize_df"](r_df)
                return result

        def via_pandas():
            return df.mean()

        t_r, _ = timeit(via_r, repeats=3)
        t_pandas, _ = timeit(via_pandas, repeats=3)

        rows.append({
            "n_filas": n,
            "pandas_puro_s": t_pandas,
            "python_r_rpy2_s": t_r,
            "overhead_cruce_a_r": t_r / t_pandas,
        })
    return rows


def print_table(rows, title):
    print(f"\n=== {title} ===")
    if not rows:
        return
    headers = list(rows[0].keys())
    widths = [max(len(h), max(len(f"{r[h]:.6g}" if isinstance(r[h], float) else str(r[h])) for r in rows)) for h in headers]
    print("  ".join(h.ljust(w) for h, w in zip(headers, widths)))
    for row in rows:
        cells = [f"{v:.6g}" if isinstance(v, float) else str(v) for v in row.values()]
        print("  ".join(c.ljust(w) for c, w in zip(cells, widths)))


def save_csv(rows, path):
    if not rows:
        return
    with open(path, "w", newline="") as f:
        writer = csv.DictWriter(f, fieldnames=list(rows[0].keys()))
        writer.writeheader()
        writer.writerows(rows)


if __name__ == "__main__":
    cpp_rows = bench_cpp_transfer(sizes=[10_000, 100_000, 1_000_000, 10_000_000])
    print_table(cpp_rows, "Python <-> C++: zero-copy vs copia explícita")

    r_rows = bench_r_transfer(row_counts=[1_000, 10_000, 100_000, 1_000_000])
    print_table(r_rows, "Python <-> R (rpy2): transferencia de data.frame vs pandas puro")

    out_dir = Path(__file__).parent.parent / "results"
    out_dir.mkdir(exist_ok=True)
    save_csv(cpp_rows, out_dir / "cpp_transfer_results.csv")
    save_csv(r_rows, out_dir / "r_transfer_results.csv")
    print(f"\nResultados guardados en {out_dir}/")
