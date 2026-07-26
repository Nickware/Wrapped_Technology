// wrapper_bench.cpp
//
// Tres funciones pensadas para el caso de uso "Cálculo numérico intensivo":
//
//   mandelbrot_pixel   -> trabajo mínimo por llamada. Se invoca desde Python
//                         una vez por píxel, así que aísla el overhead de
//                         cruzar la frontera Python<->C++ (caso "muchas
//                         llamadas baratas").
//   mandelbrot_region  -> el bucle completo vive en C++; Python hace UNA
//                         sola llamada y recibe un array ya calculado
//                         (caso "una llamada cara", sin overhead repetido).
//   integrate_trapz_native -> integración de una función fija, útil para
//                         variar n (número de subintervalos) y ver dónde
//                         el overhead de la llamada se vuelve irrelevante
//                         frente al trabajo por llamada.
//
// Compilar con build.sh (usa pybind11 + los flags del intérprete activo).

#include <pybind11/pybind11.h>
#include <pybind11/numpy.h>
#include <complex>
#include <cmath>

namespace py = pybind11;

int mandelbrot_pixel(double cx, double cy, int max_iter) {
    std::complex<double> c(cx, cy);
    std::complex<double> z(0.0, 0.0);
    int i = 0;
    for (; i < max_iter; ++i) {
        if (std::norm(z) > 4.0) break;  // norm() evita el sqrt de abs()
        z = z * z + c;
    }
    return i;
}

py::array_t<int> mandelbrot_region(double xmin, double xmax,
                                    double ymin, double ymax,
                                    int width, int height, int max_iter) {
    py::array_t<int> result({height, width});
    auto buf = result.mutable_unchecked<2>();
    const double dx = (xmax - xmin) / width;
    const double dy = (ymax - ymin) / height;

    for (int row = 0; row < height; ++row) {
        const double cy = ymin + row * dy;
        for (int col = 0; col < width; ++col) {
            const double cx = xmin + col * dx;
            buf(row, col) = mandelbrot_pixel(cx, cy, max_iter);
        }
    }
    return result;
}

// f(x) = sin(x) * exp(-x), función fija arbitraria para el benchmark de integración
double integrate_trapz_native(double a, double b, int n) {
    const double h = (b - a) / n;
    double sum = 0.5 * (std::sin(a) * std::exp(-a) + std::sin(b) * std::exp(-b));
    for (int i = 1; i < n; ++i) {
        const double x = a + i * h;
        sum += std::sin(x) * std::exp(-x);
    }
    return sum * h;
}

PYBIND11_MODULE(wrapper_bench, m) {
    m.doc() = "Funciones de referencia para benchmarking de wrappers (cálculo numérico intensivo)";
    m.def("mandelbrot_pixel", &mandelbrot_pixel,
          "Itera un único punto del conjunto de Mandelbrot");
    m.def("mandelbrot_region", &mandelbrot_region,
          "Calcula una región completa del Mandelbrot en C++ y la devuelve como array numpy");
    m.def("integrate_trapz_native", &integrate_trapz_native,
          "Integración por trapecios de sin(x)*exp(-x), todo el bucle en C++");
}
