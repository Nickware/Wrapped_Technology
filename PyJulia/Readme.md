# Ejemplo de Integración paso a paso entre Python y Julia con PyJulia

Este ejemplo ilustra cómo Python puede actuar como “wrapper” para ejecutar código Julia, invocar funciones definidas en Julia, y procesar resultados dentro de Python, integrando ambos lenguajes en un flujo de trabajo combinado.

## Paso 1: Instalar PyJulia en Python

Antes de comenzar, instalar el paquete PyJulia con pip y configurar Julia para ser utilizado desde Python.

```bash
pip install julia
python -c "import julia; julia.install()"
```

Este último comando instalar el soporte necesario y compila la librería de enlace.

## Paso 2: Crear función en Julia (opcional)

Puede definir funciones Julia directamente desde Python usando `Main.eval` o tener un archivo Julia externo que importarás.

Por ejemplo, definir una función simple que duplique un número:

```python
from julia import Main
Main.eval("""
function doble(x)
    return 2x
end
""")
```

## Paso 3: Invocar función Julia desde Python

Luego, desde Python llama a la función Julia definida:

```python
resultado = Main.doble(10)
print("El doble de 10 calculado por Julia es:", resultado)
# Salida esperada: El doble de 10 calculado por Julia es: 20
```

## Paso 4: Usar archivo Julia externo (opcional)

Si tiene una función definida en un archivo `funciones.jl`, puede cargarla:

```python
Main.include("funciones.jl")
resultado = Main.tu_funcion(5)
```

## Paso 5: Integrar en flujo Python

Ahora puede usar código Julia en medio de tu programa Python para:

- Reutilizar algoritmos y librerías Julia.
- Acelerar operaciones críticas.
- Construir pipelines científicos multi-lenguaje.

## Recomendaciones y consideraciones

- PyJulia funciona mejor si Julia está correctamente instalada y configurada en el sistema.
- El rendimiento será cercano al nativo para las funciones llamas, pero ten en cuenta el coste de llamada entre procesos en llamadas muy frecuentes.
- Usa `Main` para ejecutar código global Julia, o importa módulos específicos si los tienes instalados en Julia.

## Resumen

- Instalar y configurar PyJulia.
- Desde Python definir y llamar funciones Julia.
- Puede extender para llamar módulos, paquetes o archivos Julia externos.
- Se logra un wrapper entre Python y Julia, combinando la flexibilidad de Python con la potencia de Julia.
