# Ejemplo Básico de Integración C++ y Python con pybind11

Este ejemplo muestra cómo escribir una función sencilla en C++, compilarla como un módulo para Python usando **pybind11**, y luego usarla directamente desde Python.

## Estructura del ejemplo

- Archivo C++: `example.cpp`
- Script Python para probar: `test_example.py`
- Comando para compilar el módulo


## Paso 1: Código C++ (`sum.cpp`)

Este código define una función en C++ que suma dos enteros, y la expone a Python mediante pybind11.

```cpp
#include <pybind11/pybind11.h>

// Función en C++ que suma dos números
int suma(int a, int b) {
    return a + b;
}

// Definición del módulo pybind11 con nombre "example"
PYBIND11_MODULE(sum, m) {
    m.def("suma", &suma, "Suma dos números enteros");
}
```


## Paso 2: Instalar pybind11

Asegúrarse de tener instalado pybind11 en su ambiente Python, ya sea mediante conda:

```bash
conda install conda-forge::pybind11
```

o desde la terminal en bash:

```bash
sudo apt install -y pybind11-dev
```

## Paso 3: Compilar el módulo C++

Usar la siguiente instrucción en la terminal para compilar el código:

```bash
c++ -O3 -Wall -shared -std=c++11 -fPIC $(python3 -m pybind11 --includes) sum.cpp -o sum$(python3-config --extension-suffix)
```

- `-O3`: optimización máxima.
- `-Wall`: mostrar advertencias.
- `-shared -fPIC`: crear una librería compartida.
- `$(python3 -m pybind11 --includes)`: incluye las rutas necesarias para pybind11 y Python.
- `sum.cpp`: archivo fuente.
- `-o sum...`: nombre del módulo generado con el sufijo adecuado para Python (`.so`).

Al finalizar, se tendrá un archivo `.so` para importar en Python (por ejemplo `sum.cpython-39-x86_64-linux-gnu.so`).

## Paso 4: Usar el módulo desde Python (`test_sum.py`)

Crear un archivo Python con el siguiente contenido para usar la función `suma` que se definió en C++:

```python
import sum

resultado = sum.suma(5, 7)
print("El resultado de la suma es:", resultado)
# Salida esperada: El resultado de la suma es: 12
```


## Paso 5: Ejecutar el script Python

En la terminal, estando en el mismo directorio que el módulo compilado y el script:

```bash
python3 test_sum.py
```

Observará la salida:

```
El resultado de la suma es: 12
```


## Resumen

- Se definió una función en C++ para sumar dos números.
- Se uso **pybind11** para crear un módulo Python que envuelve esa función.
- Se compilo el módulo con las opciones adecuadas.
- Se llamó la función directamente desde Python, obteniendo el resultado esperado.

Este flujo es muy útil para acelerar partes críticas de código usando C++ y aprovechar la simplicidad y flexibilidad de Python para el resto del desarrollo.

## Recursos adicionales

- [Documentación oficial pybind11](https://pybind11.readthedocs.io/)
- [Tutorial intro a pybind11 en RealPython](https://realpython.com/python-bindings-overview/)

