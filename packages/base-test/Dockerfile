# syntax=docker/dockerfile:1

ARG BASE_IMAGE=jetson-stacks/base
FROM --platform=$BUILDPLATFORM ${BASE_IMAGE} AS builder

WORKDIR /root

RUN apt-get update

# CUDA

ADD https://github.com/NVIDIA/cuda-samples/archive/refs/tags/v13.0.tar.gz ./
RUN tar -xvf v13.0.tar.gz && rm v13.0.tar.gz

RUN (cd /root/cuda-samples-13.0/Samples/0_Introduction/vectorAdd && cmake . && make -j$(nproc))
RUN (cd /root/cuda-samples-13.0/Samples/0_Introduction/matrixMul && cmake . && make -j$(nproc))
RUN (cd /root/cuda-samples-13.0/Samples/1_Utilities/deviceQuery && cmake . && make -j$(nproc))

# CUDNN

RUN apt-get -y --no-install-recommends install \
        libcudnn9-samples

RUN (cd /usr/src/cudnn_samples_v9/conv_sample && make -j$(nproc))

# NCCL

ADD https://github.com/NVIDIA/nccl-tests/archive/refs/tags/v2.17.1.tar.gz ./
RUN tar -xvf v2.17.1.tar.gz && rm v2.17.1.tar.gz
RUN (cd /root/nccl-tests-2.17.1 && make -j$(nproc))

# GDRCopy

ADD https://developer.download.nvidia.com/compute/redist/gdrcopy/CUDA%2013.0/ubuntu24_04/aarch64/gdrcopy-tests_2.5.1-1_arm64.Ubuntu24_04+cuda13.0.deb ./
ADD https://developer.download.nvidia.com/compute/redist/gdrcopy/CUDA%2013.0/ubuntu24_04/x64/gdrcopy-tests_2.5.1-1_amd64.Ubuntu24_04+cuda13.0.deb ./
RUN <<EOF
case $(uname -m) in
    "aarch64")
        dpkg -i gdrcopy-tests_2.5.1-1_arm64.Ubuntu24_04+cuda13.0.deb
        ;;
    "x86_64")
        dpkg -i gdrcopy-tests_2.5.1-1_amd64.Ubuntu24_04+cuda13.0.deb
        ;;
    *)
        echo "Unsupported arch $(uname -m)"
        exit 1
        ;;
esac
EOF

COPY ./cuSPARSELt ./cuSPARSELt
RUN (cd /root/cuSPARSELt/matmul && make CUSPARSELT_INCLUDE_PATH=/usr/include/libcusparseLt/13 CUSPARSELT_LIB_PATH=/usr/lib/$(uname -m)-linux-gnu)

COPY ./nvshmem ./nvshmem
RUN (cd /root/nvshmem && make NVSHMEM_INCLUDE_PATH=/usr/include/nvshmem NVSHMEM_LIB_PATH=/usr/lib/$(uname -m)-linux-gnu/nvshmem/13)

# ====

FROM --platform=$BUILDPLATFORM ${BASE_IMAGE}

WORKDIR /root

COPY --from=builder /root/cuda-samples-13.0/Samples/0_Introduction/vectorAdd/vectorAdd ./cuda_vectorAdd
COPY --from=builder /root/cuda-samples-13.0/Samples/0_Introduction/matrixMul/matrixMul ./cuda_matrixMul
COPY --from=builder /root/cuda-samples-13.0/Samples/1_Utilities/deviceQuery/deviceQuery ./cuda_deviceQuery
COPY --from=builder /usr/src/cudnn_samples_v9/conv_sample/conv_sample ./cudnn_conv_sample
COPY --from=builder /root/nccl-tests-2.17.1/build/all_reduce_perf ./nccl_all_reduce_perf
COPY --from=builder /usr/bin/apiperf ./gdrcopy_apiperf
COPY --from=builder /root/cuSPARSELt/matmul/matmul_example ./cuSPARSELt_matmul
COPY --from=builder /root/nvshmem/jacobi ./nvshmem_jacobi
COPY test.sh .

CMD [ "test.sh" ]
