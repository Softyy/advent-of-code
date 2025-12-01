FROM mcr.microsoft.com/devcontainers/base:bullseye

ARG LLVM_VERSION=19.1.5
ARG ZIG_VERSION=0.13.0

# RUN curl https://github.com/llvm/llvm-project/releases/download/llvmorg-${LLVM_VERSION}/LLVM-${LLVM_VERSION}-Linux-X64.tar.xz -o llvm.tar.xz


RUN curl -L -o /tmp/zls.tar.xz https://github.com/zigtools/zls/releases/download/${ZIG_VERSION}/zls-x86_64-linux.tar.xz  && \
    tar -xvJf /tmp/zls.tar.xz -C /tmp && \
    mv /tmp/zls /usr/local/bin/zls && \
    rm /tmp/zls.tar.xz

