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
./cuda_deviceQuery

echo ""
echo "=== cuda-samples-13.0/0_Introduction/vectorAdd ==="
./cuda_vectorAdd

echo ""
echo "=== cuda-samples-13.0/0_Introduction/matrixMul ==="
./cuda_matrixMul

echo ""
echo "=== cudnn_samples_v9/conv_sample ==="
./cudnn_conv_sample

echo ""
echo "=== nccl-tests/all_reduce_perf ==="
./nccl_all_reduce_perf

echo ""
echo "=== gdrcopy/tests/apiperf ==="
./gdrcopy_apiperf

echo ""
echo "=== cuSPARSELt/matmul ==="
./cuSPARSELt_matmul

echo ""
echo "=== NVSHMEM/jacobi ==="
mpirun --allow-run-as-root -np 1 ./nvshmem_jacobi
