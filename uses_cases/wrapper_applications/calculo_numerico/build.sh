#!/usr/bin/env bash
# Compila wrapper_bench.cpp como extensión Python usando pybind11.
set -e
cd "$(dirname "$0")"
mkdir -p build
EXT_SUFFIX=$(python3 -c "import sysconfig; print(sysconfig.get_config_var('EXT_SUFFIX'))")
c++ -O3 -Wall -shared -std=c++17 -fPIC \
    $(python3 -m pybind11 --includes) \
    wrapper_bench.cpp \
    -o "build/wrapper_bench${EXT_SUFFIX}"
echo "Compilado en build/wrapper_bench${EXT_SUFFIX}"
