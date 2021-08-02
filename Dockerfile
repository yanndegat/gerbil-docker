ARG GAMBIT_VERSION=v4.9.3
ARG GERBIL_VERSION=v0.16

FROM alpine:latest

ENV GAMBIT_HOME=/opt/gambit
ENV GERBIL_HOME=/opt/gerbil
ENV GERBIL_PATH=/src/.gerbil
ENV PATH=${GAMBIT_HOME}/bin:${GERBIL_HOME}/bin:/usr/bin:/usr/sbin:/sbin:/bin
ENV GERBIL_BUILD_CORES=4

RUN mkdir -p /src /opt

RUN apk update && apk add \
    autoconf \
    automake \
    curl \
    gcc \
    git \
    leveldb \
    leveldb-dev \
    libgcc \
    libtool \
    libxml2-dev \
    linux-headers \
    lmdb-dev \
    make \
    mariadb-dev \
    musl \
    musl-dev \
    openssl-dev \
    openssl-libs-static \
    sqlite-dev \
    yaml-dev \
    yaml-static \
    zlib-static

RUN git config --global url.https://github.com/.insteadOf git://github.com/

# install gambit
RUN cd /opt \
    && git clone https://github.com/gambit/gambit gambit-src \
    && cd gambit-src \
    && git fetch -a \
    && git checkout ${GAMBIT_VERSION} \
    && ./configure \
    --prefix=${GAMBIT_HOME} \
    --enable-single-host \
    --enable-openssl \
    --enable-default-runtime-options=f8,-8,t8 \
    --enable-poll \
    && make -j4 \
    && make install

# install gerbil
RUN cd /opt \
    && git clone https://github.com/vyzo/gerbil gerbil-src \
    && cd gerbil-src && git checkout ${GERBIL_VERSION} \
    && cd src \
    && ./configure \
    --prefix=${GERBIL_HOME} \
    --enable-leveldb \
    --enable-libxml \
    --enable-libyaml \
    --enable-lmdb \
     && ./build.sh \
     && ./install

RUN mkdir -p /src

WORKDIR /src

CMD ["gxi"]
