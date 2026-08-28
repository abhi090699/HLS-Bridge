FROM ubuntu:24.04

ENV DEBIAN_FRONTEND=noninteractive

RUN apt-get update \
    && apt-get install -y --no-install-recommends \
        bash \
        bc \
        build-essential \
        ca-certificates \
        curl \
        git \
        iverilog \
        make \
        python3 \
        verilator \
    && rm -rf /var/lib/apt/lists/*

USER ubuntu
