## Ejemplo Básico de Cython: Fibonacci

Este repositorio contiene un ejemplo sencillo de cómo utilizar **Cython** para acelerar una función matemática en Python. El ejemplo calcula el número de Fibonacci de manera recursiva, mostrando cómo crear el archivo `.pyx`, compilarlo y utilizarlo desde Python.

### Estructura del proyecto

```
cpython/
├── fibonacci.pyx
├── setup.py
└── script_fibonacci.py
```


### Archivo

### `fibonacci.pyx`

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
    ext_modules = cythonize("fibonacci.pyx")
)
```


#### `script_fibonacci.py`

```python
import fibonacci

result = fibonacci.fibonacci(10)
print(f"The 10th Fibonacci number is: {result}")
result = fibonacci.fibonacci(20)
print(f"The 20th Fibonacci number is: {result}")
```


### Instrucciones de uso

#### 1. Instalar Cython y setuptools

```bash
python3 -m pip install cython setuptools
```


#### 2. Compilar el módulo Cython

Ejecutar desde la carpeta `cpython` del repositorio:

```bash
python setup.py build_ext --inplace
```

Esto generará la extensión `fibonacci` con un sufijo correspondiente a tu
versión de Python.

#### 3. Ejecutar el ejemplo

```bash
python3 script_fibonacci.py
```

El script imprime los resultados para `n=10` y `n=20`.

### ¿Qué hace este ejemplo?

- **Acelera** el cálculo de Fibonacci usando Cython (traduce el código a C y lo compila).
- Permite **tipar** argumentos para obtener mayor velocidad.
- Demuestra cómo **integrar** módulos Cython en un flujo de trabajo Python estándar.


### Recursos recomendados

- [Tutorial oficial de Cython](https://cython.readthedocs.io/en/latest/src/tutorial/cython_tutorial.html)
- [Optimización de código Python con Cython en GeeksforGeeks](https://www.geeksforgeeks.org/python/optimizing-python-code-with-cython/)


### Notas

- Se puede modificar la función en `fibonacci.pyx` para experimentar con otras operaciones matemáticas o algoritmos.
- Para obtener mayor velocidad, tipear todas las variables internas y usar bucles en Cython.
