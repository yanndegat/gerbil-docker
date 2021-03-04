FROM centos:centos7

ARG GAMBIT_VERSION=v4.9.3
ARG GERBIL_VERSION=v0.16
ARG LIBYAML_VERSION=0.2.4
ARG OPENSSL_VERSION=1.1.1

ENV GAMBIT_HOME=/opt/gerbil
ENV GERBIL_HOME=/opt/gerbil
ENV GERBIL_PATH=/src/.gerbil
ENV PATH=${GAMBIT_HOME}/bin:${GERBIL_HOME}/bin:/bin:/sbin:/usr/bin:/usr/sbin
ENV GERBIL_BUILD_CORES=4

RUN mkdir -p /src /opt

RUN yum install -y epel-release \
    && yum update -y \
    && yum groupinstall -y 'Development Tools' \
    && yum install -y \
    glibc-static \
    leveldb \
    leveldb-devel \
    libxml2-devel \
    libyaml-devel \
    lmdb-devel \
    mariadb-devel \
    sqlite-devel \
    zlib-static

# install
RUN git config --global url.https://github.com/.insteadOf git://github.com/

# install libyaml
RUN curl -k -L -o /tmp/yaml.tgz \
    https://github.com/yaml/libyaml/archive/${LIBYAML_VERSION}/libyaml-dist-${LIBYAML_VERSION}.tar.gz \
    && cd /tmp \
    && tar -xf yaml.tgz \
    && cd libyaml-0* \
    && ./bootstrap \
    && ./configure --prefix=/usr \
    && make -j4 \
    && make install

# install openssl
RUN curl -k -L -o /tmp/openssl.tgz \
    https://openssl.org/source/openssl-${OPENSSL_VERSION}.tar.gz \
    && cd /tmp \
    && tar -xf openssl.tgz \
    && cd openssl-* \
    && ./config --prefix=/usr --openssldir=/etc/ssl --libdir=lib64 shared zlib-dynamic \
    && make && make install

# install gambit
RUN cd /opt \
    && git clone https://github.com/gambit/gambit gambit-src\
    && cd gambit-src \
    && git fetch -a \
    && git checkout ${GAMBIT_VERSION} \
    && ./configure \
    --prefix=${GAMBIT_HOME} \
    --enable-single-host \
    --enable-openssl \
    --enable-default-runtime-options=f8,-8,t8 \
    --enable-poll\
    && make -j4 \
    && make install

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
