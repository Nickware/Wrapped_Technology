## Ejemplo Básico de Cython: Fibonacci

Este repositorio contiene un ejemplo sencillo de cómo utilizar **Cython** para acelerar una función matemática en Python. El ejemplo calcula el número de Fibonacci de manera recursiva, mostrando cómo crear el archivo `.pyx`, compilarlo y utilizarlo desde Python.

### Estructura del proyecto

```
cython_fibonacci/
├── example.pyx
├── setup.py
└── test_fibonacci.py
```


### Archivo

### `example.pyx`

```cython
def fibonacci(int n):
    if n <= 1:
        return n
    return fibonacci(n-1) + fibonacci(n-2)
```


#### `setup.py`

```python
from setuptools import setup
from Cython.Build import cythonize

setup(
    ext_modules = cythonize("example.pyx")
)
```


#### `test_fibonacci.py`

```python
import example

result = example.fibonacci(35)
print('Resultado:', result)
```


### Instrucciones de uso

#### 1. Instalar Cython y setuptools

```bash
pip install cython setuptools
```


#### 2. Compilar el módulo Cython

Ejecutar en la terminal desde la carpeta del proyecto:

```bash
python setup.py build_ext --inplace
```

Esto generará un archivo compartido (`example.cpython-XYm.so` o similar).

#### 3. Ejecutar el ejemplo

```bash
python test_fibonacci.py
```

Se debería ver la salida con el resultado del cálculo de Fibonacci para el número 35.

### ¿Qué hace este ejemplo?

- **Acelera** el cálculo de Fibonacci usando Cython (traduce el código a C y lo compila).
- Permite **tipar** argumentos para obtener mayor velocidad.
- Demuestra cómo **integrar** módulos Cython en un flujo de trabajo Python estándar.


### Recursos recomendados

- [Tutorial oficial de Cython](https://cython.readthedocs.io/en/latest/src/tutorial/cython_tutorial.html)
- [Optimización de código Python con Cython en GeeksforGeeks](https://www.geeksforgeeks.org/python/optimizing-python-code-with-cython/)


### Notas

- Se puede modificar la función en `example.pyx` para experimentar con otras operaciones matemáticas o algoritmos.
- Para obtener mayor velocidad, tipear todas las variables internas y usar bucles en Cython.


### Licencia

Este ejemplo es de uso libre para fines educativos y de experimentación.
