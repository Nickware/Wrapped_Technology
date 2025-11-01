# Configuración de CartPole en VS Code

Esta guía configura en Linux un entorno aislado de Python, compila la extensión
C++/pybind11 y ejecuta las pruebas y benchmarks del caso de simuladores físicos.
Los comandos están pensados para Ubuntu/Debian; en otras distribuciones,
sustituya el comando de instalación de paquetes por el equivalente.

## Requisitos

- VS Code instalado.
- Python 3.10 o posterior.
- Compilador C++ con soporte para C++17, por ejemplo GCC o Clang.
- Git para clonar el repositorio.

En Ubuntu/Debian, instale las herramientas de sistema:

```bash
sudo apt update
sudo apt install build-essential python3 python3-dev python3-venv git
```

## Abrir el repositorio en VS Code

1. Clone el repositorio si todavía no está en el equipo y abra la carpeta raíz:

   ```bash
   git clone <URL-del-repositorio>
   cd Wrapped_Technology
   code .
   ```

   Si ya tiene el repositorio, abra esa carpeta desde **File > Open Folder**.
2. En **Extensions**, instale las extensiones de Microsoft **Python**
   (`ms-python.python`), **Pylance** (`ms-python.vscode-pylance`) y
   **C/C++** (`ms-vscode.cpptools`). C/C++ aporta navegación y diagnósticos
   para el código nativo; no reemplaza el compilador del sistema.
3. Abra una terminal integrada con **Terminal > New Terminal**. Confirme que
   la ubicación actual es la raíz del repositorio.

## Crear el entorno Python

Desde la raíz del repositorio, cree un entorno virtual y active pybind11 en él:

```bash
python3 -m venv .venv
source .venv/bin/activate
python -m pip install --upgrade pip
python -m pip install pybind11
```

En la paleta de comandos de VS Code (`Ctrl+Shift+P`), ejecute **Python: Select
Interpreter** y seleccione `.venv/bin/python`. Si VS Code ya tenía abierta una
terminal, cierre esa terminal y cree otra para que use el entorno virtual.

Verifique que VS Code y el terminal estén usando el mismo Python:

```bash
python --version
python -m pybind11 --includes
which python
```

La ruta de `which python` debe terminar en `Wrapped_Technology/.venv/bin/python`.
El script de compilación usa `python3`; con el entorno activo, ese comando
también debe resolver al ejecutable de `.venv`.

## Compilar y probar CartPole

Desde la raíz del repositorio, cambie a la carpeta del simulador, compile la
extensión y ejecute las pruebas:

```bash
cd uses_cases/wrapper_applications/simuladores_fisicos
sh build.sh
PYTHONPATH=build python -m unittest -v test_cartpole.py
```

La compilación genera `build/cartpole<extension-suffix>` y
`build/native_benchmark`. La carpeta `build/` está excluida de Git. Si cambia
la versión o el entorno de Python, vuelva a ejecutar `sh build.sh` para que el
módulo se compile con ese intérprete.

## Ejecutar los benchmarks

Primero puede hacer una ejecución corta para comprobar ambas rutas:

```bash
PYTHONPATH=build python benchmark.py --episodes 3 --max-steps 50 \
  --warmup-episodes 1 --repeats 1 --seed 1234 \
  --output build/wrapped_smoke.csv
build/native_benchmark --episodes 3 --max-steps 50 \
  --warmup-episodes 1 --repeats 1 --seed 1234 \
  --output build/native_smoke.csv
```

Para una medición más estable, aumente episodios y repeticiones y conserve los
mismos argumentos en ambos comandos. Los resultados se escriben en CSV dentro
de `build/`. La política de prueba es determinista; el benchmark no entrena un
agente.

## Agente de IA opcional

El simulador, las pruebas y los benchmarks funcionan sin extensiones de IA. Si
se desea incorporar un agente para ayudar con pruebas, puede instalar GitHub
Copilot desde **Extensions** y usar el modo **Agent** de VS Code. El agente
debe poder trabajar en el repositorio abierto y usar la terminal integrada para
ejecutar los comandos de compilación y pruebas anteriores.

Al delegarle trabajo, delimite el cambio a las pruebas salvo que se solicite
explícitamente modificar la física. Un encargo inicial útil sería:

> Añade pruebas reproducibles para la simulación CartPole. Comprueba la API,
> las transiciones y los límites frente a la referencia documentada de
> Gymnasium. No cambies las ecuaciones ni los parámetros físicos sin pedirlo;
> compila la extensión y ejecuta `test_cartpole.py`. Resume las pruebas que
> pasaron y cualquier diferencia respecto de Gymnasium.

Cuando se formalicen instrucciones persistentes para el agente, pueden
añadirse en `.github/copilot-instructions.md` o en un perfil de agente propio.
Conviene especificar allí el comando de compilación, el comando de pruebas, la
semilla reproducible y la regla de no alterar la física sin aprobación. Revise
los cambios del agente como cualquier otro cambio de código.

## Referencias del proyecto

- [Simuladores físicos para aprendizaje por refuerzo](../uses_cases/wrapper_applications/simuladores_fisicos/README.md)
- [Benchmark Python/pybind11](../uses_cases/wrapper_applications/simuladores_fisicos/benchmark.py)
- [Pruebas de CartPole](../uses_cases/wrapper_applications/simuladores_fisicos/test_cartpole.py)