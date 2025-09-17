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
echo "=== cuda-samples-13.0/1_Utilities/deviceQuery ==="
./deviceQuery

echo ""
echo "=== cuda-samples-13.0/0_Introduction/vectorAdd ==="
./vectorAdd

echo ""
echo "=== cuda-samples-13.0/0_Introduction/matrixMul ==="
./matrixMul

echo ""
echo "=== cudnn_samples_v9/conv_sample ==="
./conv_sample

echo ""
echo "=== cnccl-tests/all_reduce_perf ==="
./all_reduce_perf

echo ""
echo "=== gdrcopy_apiperf ==="
./gdrcopy_apiperf
