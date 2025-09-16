# syntax=docker/dockerfile:1

ARG BASE_IMAGE=jetson-stacks/base
FROM --platform=$BUILDPLATFORM ${BASE_IMAGE} AS builder

WORKDIR /root

ADD https://github.com/NVIDIA/cuda-samples/archive/refs/tags/v13.0.tar.gz ./
RUN tar -xvf v13.0.tar.gz && rm v13.0.tar.gz

WORKDIR /root/cuda-samples-13.0

RUN (cd Samples/0_Introduction/vectorAdd && cmake . && make)
RUN (cd Samples/0_Introduction/matrixMul && cmake . && make)
RUN (cd Samples/1_Utilities/deviceQuery && cmake . && make)

# ====

FROM --platform=$BUILDPLATFORM ${BASE_IMAGE}

WORKDIR /root

COPY --from=builder /root/cuda-samples-13.0/Samples/0_Introduction/vectorAdd/vectorAdd .
COPY --from=builder /root/cuda-samples-13.0/Samples/0_Introduction/matrixMul/matrixMul .
COPY --from=builder /root/cuda-samples-13.0/Samples/1_Utilities/deviceQuery/deviceQuery .
COPY test.sh .

CMD [ "test.sh" ]
