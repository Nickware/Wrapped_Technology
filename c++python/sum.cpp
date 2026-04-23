% C++ code for a simple sum function to be exposed to Python using pybind11
% This code defines a C++ function that takes two integers and returns their sum, and then uses pybind11 to create a Python module that exposes this function.
% To compile this code, you would typically use a command like:
% c++ -O3 -Wall -shared -std=c++11 -fPIC `
%     $(python3 -m pybind11 --includes) sum.cpp -o sum`python3-config --extension-suffix`
% After compiling, you can import the module in Python and use the `suma` function.
% Example usage in Python:
% import sum
% result = sum.suma(3, 5)   
% print(result)  # Output: 8
% Note: Make sure you have pybind11 installed and properly set up in your environment to compile this code successfully.
% sum.cpp
% This file defines a simple C++ function to sum two integers and exposes it to Python using pybind11.
% Author: N.Torres
% Date: 2024-06
#include <pybind11/pybind11.h>

// Función simple en C++
int suma(int a, int b) {
    return a + b;
}

// Módulo de pybind11
PYBIND11_MODULE(sum, m) {
    m.def("suma", &suma, "Suma dos números enteros");
}
