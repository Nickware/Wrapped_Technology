#!/usr/bin/env sh
set -eu

cd "$(dirname "$0")"
PYTHON=${PYTHON:-python3}
CXX=${CXX:-c++}
mkdir -p build

extension_suffix=$("$PYTHON" -c 'import sysconfig; print(sysconfig.get_config_var("EXT_SUFFIX"))')
"$CXX" -O3 -Wall -shared -std=c++11 -fPIC \
    $("$PYTHON" -m pybind11 --includes) \
    cartpole_core.cpp cartpole.cpp -o "build/cartpole${extension_suffix}"
"$CXX" -O3 -Wall -std=c++17 \
    cartpole_core.cpp native_benchmark.cpp -o build/native_benchmark

printf 'Built extension and native benchmark in %s/build\n' "$PWD"