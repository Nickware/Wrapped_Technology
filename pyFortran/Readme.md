# Ejemplos clásicos para medir y comparar la velocidad de cómputo 

Estos dos scripts, uno en Python y otro en Fortran, son ejemplos clásicos para medir y comparar la velocidad de cómputo en ambos lenguajes mediante una tarea numérica simple: el cálculo repetido de la raíz cuadrada de la suma de los cuadrados de tres números dentro de bucles anidados.

***

## Descripción del script en Python

```python
import time
import math

start = time.time()
x,y,z = 1.0, 2.0, 3.0
for j in range(3000):
    for i in range(1000000):
        r = math.sqrt(x**2 + y**2 + z**2)
end = time.time()
print("Python time =", end - start, "seconds")
```

- Mide el tiempo total que tarda en ejecutar dos bucles anidados.
- En cada iteración, calcula la raíz cuadrada de la suma de los cuadrados: $$ \sqrt{x^2 + y^2 + z^2} $$.
- Usa `time.time()` para medir el tiempo en segundos.
- Es código puro Python usando la biblioteca estándar `math`.

***

## Descripción del programa en Fortran

```fortran
program test_speed
  real :: start, finish, r, x, y, z
  integer :: i, j
  call cpu_time(start)
  x = 1.0
  y = 2.0
  z = 3.0
  do j = 1, 3000
    do i = 1, 1000000
      r = sqrt(x*x + y*y + z*z)
    end do
  end do
  call cpu_time(finish)
  print *, 'Elapsed time = ', finish - start, ' seconds'
end program test_speed
```

- Es un programa Fortran que realiza la misma operación matemática dentro de bucles anidados.
- Usa la función intrínseca `cpu_time` para medir tiempo de CPU de la ejecución.
- Se compila con un compilador como `gfortran` y se ejecuta en terminal.
- La operación es idéntica: calcular $$ \sqrt{x^2 + y^2 + z^2} $$ repetidamente.
- La salida muestra el tiempo transcurrido en segundos.

***

## Intención y utilidad

- Ambos scripts miden el rendimiento bruto del cálculo repetitivo de una función matemática sencilla.
- Permiten comparar **performance** entre un lenguaje interpretado (Python) y un lenguaje compilado de alto rendimiento numérico (Fortran).
- Se usan para ilustrar cuánto más rápido es Fortran en código numérico puro, especialmente en bucles muy grandes.

***

## Recomendaciones para la comparación

- Ejecutar ambos en la misma máquina bajo condiciones similares.
- El tiempo en Python puede ser radicalmente mayor que en Fortran (diferenicas de decenas o centenas de veces).
- Se puede extender la comparación usando optimizadores para Python (NumPy, Cython, Numba).
- Usar compiladores Fortran optimizados para obtener el mejor rendimiento.

***

## Conclusión

Estos ejemplos simples evidencian la diferencia considerable de velocidad entre Python y Fortran en tareas numéricas intensivas, destacando la ventaja del código compilado y optimizado de Fortran para cálculo científico puro. Son bases ideales para probar técnicas de tecnología wrapped cuando se busca combinar ambos lenguajes eficientemente.

[1](https://stackoverflow.com/questions/62883749/speeding-up-nested-loop-comparison)
[2](https://www.blog.duomly.com/loops-in-python-comparison-and-performance/)
[3](https://benjdd.com/languages2/)
[4](https://www.answeroverflow.com/m/1314001110591340644)
[5](https://users.rust-lang.org/t/why-are-cartesian-iterators-slower-than-nested-fors/42847)
[6](https://www.reddit.com/r/programminghorror/comments/1bnunrs/man_accidentally_proves_his_optimised_python_code/)
[7](https://www.linkedin.com/posts/ratan-biswakarmakar-7ab97317a_python-machine-generative-activity-7328493363467296769-RXWh)
[8](https://www.reddit.com/r/rstats/comments/7h76sn/theres_a_paper_comparing_how_long_it_takes/)
