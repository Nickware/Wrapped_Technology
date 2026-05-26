// data_transfer.cpp
//
// Caso de uso "Manejo masivo de datos y estructuras", lado Python<->C++.
//
// Dos pares de funciones que hacen EXACTAMENTE lo mismo (sumar, o escalar
// in-place) pero difieren en cómo mueven los datos:
//
//   sum_view / scale_view   -> reciben py::array_t<double> y acceden al
//                               buffer subyacente directamente (protocolo
//                               de buffer de NumPy). Cero copias: se lee/
//                               escribe la misma memoria que ya tiene Python.
//
//   sum_copy / scale_copy   -> reciben std::vector<double>. pybind11
//                               convierte automáticamente el array de NumPy
//                               a std::vector, lo que implica copiar todos
//                               los elementos; y en scale_copy, otra copia
//                               más al construir el vector de salida.
//
// La diferencia de tiempo entre ambos pares, al variar el tamaño del
// array, aísla el costo puro de la copia de datos (no del cómputo).

#include <pybind11/pybind11.h>
#include <pybind11/numpy.h>
#include <pybind11/stl.h>
#include <vector>

namespace py = pybind11;

double sum_view(py::array_t<double> arr) {
    py::buffer_info buf = arr.request();  // sin copiar: solo metadata + puntero
    double* ptr = static_cast<double*>(buf.ptr);
    double total = 0.0;
    for (ssize_t i = 0; i < buf.size; ++i) {
        total += ptr[i];
    }
    return total;
}

double sum_copy(std::vector<double> v) {  // pybind11 copia numpy -> std::vector aquí
    double total = 0.0;
    for (double x : v) total += x;
    return total;
}

void scale_view(py::array_t<double> arr, double factor) {
    py::buffer_info buf = arr.request();
    double* ptr = static_cast<double*>(buf.ptr);
    for (ssize_t i = 0; i < buf.size; ++i) {
        ptr[i] *= factor;  // modifica la memoria de Python in-place
    }
}

std::vector<double> scale_copy(std::vector<double> v, double factor) {
    for (double& x : v) x *= factor;
    return v;  // pybind11 copia de nuevo al construir el array de retorno
}

PYBIND11_MODULE(data_transfer, m) {
    m.doc() = "Zero-copy (buffer protocol) vs copia explícita, Python<->C++";
    m.def("sum_view", &sum_view, "Suma sin copiar (buffer protocol)");
    m.def("sum_copy", &sum_copy, "Suma copiando a std::vector");
    m.def("scale_view", &scale_view, "Escala in-place sin copiar");
    m.def("scale_copy", &scale_copy, "Escala copiando entrada y salida");
}
