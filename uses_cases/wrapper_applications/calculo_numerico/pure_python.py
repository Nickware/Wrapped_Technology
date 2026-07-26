"""
Equivalentes en Python puro de las funciones expuestas por wrapper_bench.
Mismo algoritmo, misma cantidad de trabajo por punto — la única variable
que cambia frente al módulo C++ es el lenguaje de ejecución.
"""

import math


def mandelbrot_pixel_py(cx: float, cy: float, max_iter: int) -> int:
    zr, zi = 0.0, 0.0
    i = 0
    while i < max_iter:
        if zr * zr + zi * zi > 4.0:
            break
        zr, zi = zr * zr - zi * zi + cx, 2 * zr * zi + cy
        i += 1
    return i


def mandelbrot_region_py(xmin, xmax, ymin, ymax, width, height, max_iter):
    dx = (xmax - xmin) / width
    dy = (ymax - ymin) / height
    result = [[0] * width for _ in range(height)]
    for row in range(height):
        cy = ymin + row * dy
        for col in range(width):
            cx = xmin + col * dx
            result[row][col] = mandelbrot_pixel_py(cx, cy, max_iter)
    return result


def integrate_trapz_py(a: float, b: float, n: int) -> float:
    h = (b - a) / n
    s = 0.5 * (math.sin(a) * math.exp(-a) + math.sin(b) * math.exp(-b))
    for i in range(1, n):
        x = a + i * h
        s += math.sin(x) * math.exp(-x)
    return s * h
