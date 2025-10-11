#!/bin/bash
set -euo pipefail

BUILD_MATRIX_PATH=build.yaml
CONFIG_PATH=config

# Convert YAML matrix file into JSON format
echo "Converting $BUILD_MATRIX_PATH to JSON..."
yaml2json ${BUILD_MATRIX_PATH} | jq -c . > /tmp/build_matrix.json
jq . /tmp/build_matrix.json

echo "Starting matrix builds..."
rm -rf build/*
for row in $(jq -c '.include.[]' /tmp/build_matrix.json); do
    board=$(echo $row | jq -r '.board');
    shield=$(echo $row | jq -r '.shield');

    echo "=== Building for board: $board, shield: $shield ===";

    if [ "$shield" != "null" ] && [ -n "$shield" ]; then
        artifact_name="${shield}-${board}-zmk";
    else
        artifact_name="${board}-zmk";
    fi
    build_dir="build/${artifact_name}";
    mkdir -p "$build_dir";

    extra_cmake_args="";
    if [ "$shield" != "null" ] && [ -n "$shield" ]; then
        extra_cmake_args="-DSHIELD=$shield";
    fi;
    west build -s zmk/app -d "$build_dir" -b "$board" -- -DZMK_CONFIG="/app/${CONFIG_PATH}" $extra_cmake_args || exit 1;

    echo "Packaging firmware...";
    cp "$build_dir/zephyr/zmk.bin" "build/${artifact_name}.bin" 2>/dev/null || true;
    cp "$build_dir/zephyr/zmk.uf2" "build/${artifact_name}.uf2" 2>/dev/null || true;
done
echo "All builds completed.."
