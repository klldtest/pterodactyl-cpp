FROM debian:12

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
        iproute2 \
        iproute2 \
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

# Copy start script and default C++ file
COPY ./start.sh /start.sh
COPY ./main.cpp /home/container/main.cpp
RUN chmod +x /start.sh

USER container
ENV USER=container HOME=/home/container
WORKDIR /home/container

CMD ["/bin/bash", "/start.sh"]
