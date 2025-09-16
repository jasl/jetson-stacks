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

# ====

FROM --platform=$BUILDPLATFORM ${BASE_IMAGE}

WORKDIR /root

COPY --from=builder /root/cuda-samples-13.0/Samples/0_Introduction/vectorAdd/vectorAdd .
COPY --from=builder /root/cuda-samples-13.0/Samples/0_Introduction/matrixMul/matrixMul .
COPY --from=builder /root/cuda-samples-13.0/Samples/1_Utilities/deviceQuery/deviceQuery .
COPY --from=builder /usr/src/cudnn_samples_v9/conv_sample/conv_sample .
COPY --from=builder /root/nccl-tests-2.17.1/build/all_reduce_perf ./
COPY test.sh .

CMD [ "test.sh" ]
