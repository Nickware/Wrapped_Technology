# GNU Scientific Library (GSL): todo lo esencial

## ¿Qué es GSL?

La **GNU Scientific Library (GSL)** es una biblioteca escrita en **C**, diseñada para **cálculos numéricos** en matemáticas y ciencia. Está distribuida bajo la licencia **GNU GPL** y es parte del **GNU Project**. [es.wikipedia](https://es.wikipedia.org/wiki/GNU_Scientific_Library)

La **versión más reciente** es **2.8**, lanzada en mayo de 2024. [heise](https://www.heise.de/blog/C-Core-Guidelines-The-Guideline-Support-Library-3780760.html)

***

## Características principales

GSL es una biblioteca **en C**, pero es muy fácil usarla desde **C++** (código compatible C) y también existen **wrappers** para otros lenguajes como:

- **Python**
- **R**
- **Julia**
- **Octave**
- **Perl**
- **Ruby**
- **Rust**
- **Nim**
- **OCaml**
- **Common Lisp**

Esto la hace muy útil en proyectos científicos multi-lenguaje. [heise](https://www.heise.de/blog/C-Core-Guidelines-The-Guideline-Support-Library-3780760.html)

***

## ¿Qué incluye GSL?

La biblioteca proporciona herramientas para una amplia gama de tareas numéricas:

### 1. **Funciones matemáticas básicas**

- Funciones elementales: `sin`, `cos`, `exp`, `log`, etc.
- Números **complejos**.
- **Polinomios**.
- **Funciones especiales**:
  - Bessel (`J_n`, `Y_n`)
  - Función de error (`erf`)
  - Hermite, Legendre, etc.

### 2. **Vectores y matrices**

- Operaciones con vectores y matrices.
- **Permutaciones**, **combinaciones**, **multisets**.
- **Ordenación** (sorting).

### 3. **Álgebra lineal**

- Interfaces a **BLAS**.
- **Descomposición LU**, **Cholesky**, etc.
- **Eigenvectores** y **eigenvalores**.
- Resolución de sistemas lineales.

### 4. **Transformadas y señales**

- **FFT** (Transformada rápida de Fourier).
- **Transformada wavelet discreta**.
- **Transformada discreta de Hankel**.

### 5. **Integración y derivación numérica**

- **Integración numérica** (basada en QUADPACK).
- **Derivación numérica**.
- **Integración de Monte Carlo**.

### 6. **Números aleatorios y estadística**

- **Generación de números aleatorios**:
  - Distribuciones uniformes, normales, exponenciales, Poisson, etc.
- **Secuencias quasi-aleatorias**.
- **Distribuciones de números aleatorios**.
- **Estadísticas**:
  - Media, varianza, desviación, etc.
- **Histogramas**.
- **N-tuplas**.

### 7. **Ecuaciones diferenciales**

- Integración de **ecuaciones diferenciales ordinarias (ODEs)**.
- Métodos como **Runge–Kutta**, con paso adaptativo.

### 8. **Interpolación y aproximación**

- **Interpolación** (splines, polinomios).
- **Aproximaciones de Chebyshev**.
- **Aceleración de series**.

### 9. **Optimización y búsqueda de raíces**

- **Búsqueda de raíces** en una y varias dimensiones.
- **Minimización** en una y varias dimensiones.
- **Minimos cuadrados** (lineales y no lineales).
- **Simulated annealing**.

### 10. **Constantes y aritmética**

- **Constantes físicas** (velocidad de la luz, constante de Planck, etc.).
- **Aritmética de punto flotante IEEE**.

***

## ¿Cómo usar GSL en C++?

Aunque GSL está escrita en C, se usa fácilmente en C++:

```cpp
#include <gsl/gsl_rng.h>
#include <gsl/gsl_randist.h>

main() {
    const gsl_rng_type *T = gsl_rng_mt19937;
    gsl_rng *r = gsl_rng_alloc(T);
    gsl_rng_set(r, 12345); // semilla

    double z = gsl_ran_gaussian(r, 1.0); // normal estándar
}
```

Para compilar:

```bash
g++ -O2 -o programa programa.cpp -lgsl -lgslcblas -lm
```

***

## Wrappers para otros lenguajes

Ya existen wrappers para usar GSL desde:

- **Octave**: paquete `octave-gsl`.
- **Python**: por ejemplo, `numba` + FFI, o wrappers específicos.
- **Julia**: paquetes que envuelven GSL.
- **R**: paquete `RcppGSL`.

Esto permite:

- Prototipar en lenguajes de alto nivel (Octave, R, Python).
- Usar GSL desde esos lenguajes sin escribir C.
- Luego migrar partes críticas a C++ si necesitas rendimiento.

***

## Casos de uso típicos

GSL se usa en:

- **Física**: funciones especiales, ODEs, integración.
- **Matemáticas**: álgebra lineal, búsqueda de raíces, optimización.
- **Finanzas**: generación de números aleatorios, Monte Carlo, simulación.
- **Biología**: modelos de crecimiento, ecuaciones diferenciales.
- **Química**: cinética, integración numérica, ajuste de curvas.
- **Ciencia de datos**: estadística, histogramas, mínimos cuadrados.

***

## Instalación en Ubuntu (repaso)

```bash
sudo apt update
sudo apt install libgsl-dev gsl-bin
```

Verificar:

```bash
gsl-config --version
```

***

## Resumen

- **GSL** es una biblioteca **C** para **cálculo numérico** en ciencia y matemáticas.
- Incluye:
  - Funciones especiales, complejos, polinomios.
  - Vectores, matrices, álgebra lineal.
  - FFT, wavelets, integración, ODEs.
  - Números aleatorios, estadística, histogramas.
  - Optimización, búsqueda de raíces, mínimos cuadrados.
- Se usa fácilmente en **C++**.
- Tiene **wrappers** en muchos lenguajes (Python, R, Julia, Octave, etc.).
- Es libre, gratuita y de alta calidad (GNU Project).

GSL es ideal para ejemplos concretos combinando C++ con GSL para p.e:

- Monte Carlo con números aleatorios.
- Integración numérica.
- ODEs (ej. movimiento de un péndulo).
