#include <pybind11/pybind11.h>

// Función simple en C++
int suma(int a, int b) {
    return a + b;
}

// Módulo de pybind11
PYBIND11_MODULE(sum, m) {
    m.def("suma", &suma, "Suma dos números enteros");
}
