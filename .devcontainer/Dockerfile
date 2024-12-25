FROM mcr.microsoft.com/devcontainers/base:bullseye

RUN sudo apt-get update

# Setup Flutter
RUN sudo apt-get install -y curl git unzip xz-utils zip libglu1-mesa

# Setup Flutter for native desktop apps on Linux
RUN sudo apt-get install -y \
        clang cmake git \
        ninja-build pkg-config \
        libgtk-3-dev liblzma-dev

# Setup Flutter for Android apps
RUN sudo apt-get install -y libc6:amd64 libstdc++6:amd64 lib32z1 libbz2-1.0:amd64

## Download and install JDK 21
RUN curl https://download.oracle.com/java/21/latest/jdk-21_linux-x64_bin.deb -O && \
    sudo apt-get install ./jdk-21_linux-x64_bin.deb

## Set up environment variables
ENV ANDROID_HOME=/opt/android
ENV PATH=$PATH:$ANDROID_HOME/cmdline-tools/latest/bin:$ANDROID_HOME/platform-tools

## Download and install Android SDK command line tools
RUN mkdir ${ANDROID_HOME} && \
    mkdir ${ANDROID_HOME}/cmdline-tools/ && \
    mkdir ${ANDROID_HOME}/cmdline-tools/latest && \
    wget 'https://dl.google.com/android/repository/commandlinetools-linux-11076708_latest.zip' -P /tmp && \
    unzip -d /tmp /tmp/commandlinetools-linux-11076708_latest.zip && \
    mv /tmp/cmdline-tools/* ${ANDROID_HOME}/cmdline-tools/latest && \
    rm /tmp/commandlinetools-linux-11076708_latest.zip

## Install essential packages
RUN sudo chown -R $(id -u):$(id -g) ${ANDROID_HOME} && \
    yes | ${ANDROID_HOME}/cmdline-tools/latest/bin/sdkmanager --install "platform-tools" "platforms;android-35" "build-tools;35.0.0"
