FROM mcr.microsoft.com/devcontainers/base:bullseye

RUN sudo apt-get update

# setup Flutter
RUN sudo apt-get install -y curl git unzip xz-utils zip libglu1-mesa

# setup Flutter for native desktop apps on Linux
RUN sudo apt-get install -y \
        clang cmake git \
        ninja-build pkg-config \
        libgtk-3-dev liblzma-dev