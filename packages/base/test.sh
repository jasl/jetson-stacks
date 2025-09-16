#!/usr/bin/env bash

echo "=== CUDA version files ==="
cat /usr/local/cuda/version*

echo ""
echo "=== Location of nvcc ==="
which nvcc

echo ""
echo "=== nvcc version ==="
nvcc --version

echo ""
echo "=== Supported GPU architectures by nvcc ==="
nvcc --list-gpu-arch

echo ""
echo "=== CUDA Samples/1_Utilities/deviceQuery ==="
./deviceQuery

echo ""
echo "=== CUDA Samples/0_Introduction/vectorAdd ==="
./vectorAdd

echo ""
echo "=== CUDA Samples/0_Introduction/matrixMul ==="
./matrixMul
