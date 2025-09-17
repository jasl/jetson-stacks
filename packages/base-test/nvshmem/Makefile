# Copyright (c) 2019, NVIDIA CORPORATION. All rights reserved.
NP ?= 1
NVCC=nvcc
MPIRUN ?= mpirun
CUDA_HOME ?= /usr/local/cuda
NVSHMEM_LIB_PATH ?= /usr/lib/$(uname -m)-linux-gnu/nvshmem/13
NVSHMEM_INCLUDE_PATH ?= /usr/include/nvshmem
ifndef NVSHMEM_LIB_PATH
$(error NVSHMEM_LIB_PATH is not set)
endif
ifndef NVSHMEM_INCLUDE_PATH
$(error NVSHMEM_INCLUDE_PATH is not set)
endif

GENCODE_SM89    := -gencode=arch=compute_89,code=sm_89
GENCODE_SM90    := -gencode=arch=compute_90,code=sm_90
GENCODE_SM100   := -gencode=arch=compute_100f,code=sm_100
# GENCODE_SM110   := -gencode=arch=compute_110f,code=sm_110 # NVSHMEM doesn't support Jetson families
GENCODE_SM120   := -gencode=arch=compute_120f,code=sm_120
GENCODE_FLAGS	:= $(GENCODE_SM89) $(GENCODE_SM90) $(GENCODE_SM100) $(GENCODE_SM120)

ifdef DISABLE_CUB
	NVCC_FLAGS = -Xptxas --optimize-float-atomics
else
	NVCC_FLAGS = -DHAVE_CUB
endif
NVCC_FLAGS += -ccbin=mpic++ -dc -Xcompiler -fopenmp -lineinfo -DUSE_NVTX -ldl $(GENCODE_FLAGS) -std=c++17 -I$(NVSHMEM_INCLUDE_PATH)
NVCC_LDFLAGS = -ccbin=mpic++ -L$(NVSHMEM_LIB_PATH) -lnvshmem -L$(CUDA_HOME)/lib64 -lcuda -lcudart -ldl -lnvidia-ml
# ifdef USE_LTO
# 	NVCC_FLAGS += -maxrregcount=32
# 	NVCC_LDFLAGS += -maxrregcount=32 -dlto
# endif
jacobi: Makefile jacobi.cu
	$(NVCC) $(NVCC_FLAGS) jacobi.cu -c -o jacobi.o
	$(NVCC) $(GENCODE_FLAGS) jacobi.o -o jacobi $(NVCC_LDFLAGS)

.PHONY.: clean
clean:
	rm -f jacobi jacobi.o *.nsys-rep jacobi.*.compute-sanitizer.log

sanitize: jacobi
	$(MPIRUN) -np $(NP) compute-sanitizer --log-file jacobi.%q{OMPI_COMM_WORLD_RANK}.compute-sanitizer.log ./jacobi -niter 10

run: jacobi
	$(MPIRUN) --allow-run-as-root -np $(NP) ./jacobi

profile: jacobi
	$(MPIRUN) -np $(NP) nsys profile --trace=mpi,cuda,nvtx -o jacobi.%q{OMPI_COMM_WORLD_RANK} ./jacobi -niter 10
