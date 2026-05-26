#!/usr/bin/env bash
set -e
cd "$(dirname "$0")"
mkdir -p build
EXT_SUFFIX=$(python3 -c "import sysconfig; print(sysconfig.get_config_var('EXT_SUFFIX'))")
c++ -O3 -Wall -shared -std=c++17 -fPIC \
    $(python3 -m pybind11 --includes) \
    data_transfer.cpp \
    -o "build/data_transfer${EXT_SUFFIX}"
echo "Compilado en build/data_transfer${EXT_SUFFIX}"
