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
se desea incorporar un agente para ayudar con pruebas y análisis, hay dos
opciones: GitHub Copilot en modo **Agent** o un modelo local servido por
Ollama desde una extensión de VS Code compatible, como Continue. En ambos
casos, el cliente debe tener acceso al repositorio abierto. Para ejecutar las
pruebas desde el agente, habilite el modo de agente y las herramientas de
terminal en esa extensión; la disponibilidad de herramientas y llamadas a
funciones depende del cliente y del modelo seleccionado.

### Opción local con Ollama

Instale Ollama siguiendo las instrucciones para Linux de su sitio oficial,
descargue un modelo que quepa en la memoria disponible y compruebe que responde:

```bash
ollama pull <modelo>
ollama run <modelo>
```

En VS Code, instale una extensión que admita Ollama (por ejemplo, Continue),
seleccione el proveedor Ollama y el modelo descargado. La dirección local
habitual de la API es `http://localhost:11434`. Active el modo de agente y las
herramientas que vaya a permitir. La inferencia se ejecuta localmente; descargar
el modelo requiere conexión a Internet. No conceda acceso a terminal o archivos
que no sean necesarios para la tarea.

El modelo no es por sí solo un agente de enfoque lógico: ese enfoque se define
con instrucciones explícitas en el perfil o reglas del cliente. Puede usar
instrucciones como estas:

> Trabaja como agente de análisis lógico para el simulador CartPole. Antes de
> proponer cambios, identifica las invariantes y sigue el flujo
> `reset`/`step` hasta el núcleo C++. Para cada conclusión, indica la evidencia
> en el código o una prueba reproducible; separa hechos de hipótesis. Prioriza
> pruebas deterministas y compara con la referencia de Gymnasium solo bajo las
> mismas condiciones iniciales y acciones. No cambies ecuaciones, parámetros
> físicos ni semántica de la API sin autorización. Antes de terminar, ejecuta
> la compilación y las pruebas pertinentes e informa los resultados.

Con Copilot, esas instrucciones pueden guardarse en
`.github/copilot-instructions.md` o en un perfil de agente propio. Con Ollama,
guárdelas en las reglas o configuración del cliente elegido; el formato y la
ubicación dependen de la extensión.

Un encargo inicial útil sería:

> Añade pruebas reproducibles para la simulación CartPole. Comprueba la API,
> las transiciones y los límites frente a la referencia documentada de
> Gymnasium. No cambies las ecuaciones ni los parámetros físicos sin pedirlo;
> compila la extensión y ejecuta `test_cartpole.py`. Resume las pruebas que
> pasaron y cualquier diferencia respecto de Gymnasium.

Revise los cambios del agente como cualquier otro cambio de código, en especial
los resultados de pruebas y cualquier afirmación sobre equivalencia física.

## Referencias del proyecto

- [Simuladores físicos para aprendizaje por refuerzo](../README.md)
- [Benchmark Python/pybind11](../benchmark.py)
- [Pruebas de CartPole](../test_cartpole.py)