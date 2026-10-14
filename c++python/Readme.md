# Integración C++ y Python con pybind11

Este ejemplo muestra cómo escribir una función sencilla en C++, compilarla como un módulo para Python usando **pybind11** y luego usarla directamente desde Python.

## Estructura del ejemplo

- Archivo C++: `sum.cpp`
- Script Python para probar: `test_sum.py`
- Comando para compilar el módulo


## Paso 1: Código C++ (`sum.cpp`)

Este código define una función en C++ que suma dos enteros y la expone a Python mediante pybind11.

```cpp
#include <pybind11/pybind11.h>

// Función en C++ que suma dos números
int suma(int a, int b) {
    return a + b;
}

// Definición del módulo pybind11 con nombre "sum"
PYBIND11_MODULE(sum, m) {
    m.def("suma", &suma, "Suma dos números enteros");
}
```


## Paso 2: Instalar los requisitos

Se necesita Python 3, un compilador de C++ y pybind11 instalado en el mismo
entorno de Python que se usará para ejecutar el ejemplo. En Debian/Ubuntu,
instale también los headers de desarrollo de Python:

```bash
sudo apt install build-essential python3-dev
python3 -m pip install pybind11
```

Si usa Conda, puede instalar pybind11 en el entorno activo con
`conda install -c conda-forge pybind11`.

## Paso 3: Compilar el módulo C++

Desde esta carpeta, compile el código. `python3-config` y `python3` deben
pertenecer al mismo entorno:

```bash
c++ -O3 -Wall -shared -std=c++11 -fPIC $(python3 -m pybind11 --includes) sum.cpp -o sum$(python3-config --extension-suffix)
```

- `-O3`: optimización máxima.
- `-Wall`: mostrar advertencias.
- `-shared -fPIC`: crear una librería compartida.
- `$(python3 -m pybind11 --includes)`: incluye las rutas necesarias para pybind11 y Python.
- `sum.cpp`: archivo fuente.
- `-o sum...`: nombre del módulo generado con el sufijo adecuado para Python (`.so`).

Al finalizar, se tendrá un archivo `.so` para importar en Python. El sufijo
codifica la versión y plataforma; recompílalo si cambias de versión de Python.

## Paso 4: Usar el módulo desde Python (`test_sum.py`)

El archivo `test_sum.py` ya contiene la prueba para usar la función `suma`.

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
- Se usó **pybind11** para crear un módulo Python que envuelve esa función.
- Se compiló el módulo con las opciones adecuadas.
- Se llamó a la función directamente desde Python, obteniendo el resultado esperado.

Este flujo es muy útil para acelerar partes críticas de código usando C++ y aprovechar la simplicidad y flexibilidad de Python para el resto del desarrollo.

## Recursos adicionales

- [Documentación oficial pybind11](https://pybind11.readthedocs.io/)
- [Tutorial intro a pybind11 en RealPython](https://realpython.com/python-bindings-overview/)

