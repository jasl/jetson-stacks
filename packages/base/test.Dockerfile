# syntax=docker/dockerfile:1

ARG BASE_IMAGE
FROM --platform=$BUILDPLATFORM ${BASE_IMAGE}

ADD https://github.com/NVIDIA/cuda-samples/archive/refs/tags/v13.0.tar.gz /root

WORKDIR /root/cuda-samples-13.0

RUN mkdir build && cd build && cmake .. && make -j$(nproc)
