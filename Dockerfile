FROM ubuntu:22.04

LABEL author="klld" maintainer="klld@klldFN.xyz"

ENV DEBIAN_FRONTEND=noninteractive

RUN apt-get update \
    && apt-get install -y --no-install-recommends \
        apt-utils \
        build-essential \
        ca-certificates \
        cmake \
        curl \
        g++ \
        gcc \
        git \
        gnupg \
        jq \
        libboost-all-dev \
        libssl-dev \
        make \
        nano \
        pkg-config \
        sudo \
        tar \
        unzip \
        wget \
    && apt-get clean \
    && rm -rf /var/lib/apt/lists/*

# Install additional C++ tools
RUN apt-get update \
    && apt-get install -y --no-install-recommends \
        gdb \
        valgrind \
        clang \
    && apt-get clean \
    && rm -rf /var/lib/apt/lists/*

# Set up a user
RUN useradd -m -d /home/container -s /bin/bash container
RUN ln -s /usr/local/bin/cmake /usr/bin/cmake

# Copy start script
COPY ./start.sh /start.sh
RUN chmod +x /start.sh

USER container
ENV USER=container HOME=/home/container
WORKDIR /home/container

CMD ["/bin/bash", "/start.sh"]
