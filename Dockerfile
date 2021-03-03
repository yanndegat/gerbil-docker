FROM centos:centos7

ARG GAMBIT_VERSION=v4.9.3
ARG GERBIL_VERSION=v0.16
ARG LIBYAML_VERSION=0.2.4
ARG OPENSSL_VERSION=1.1.1

RUN yum groupinstall -y 'Development Tools'
RUN yum install -y epel-release
RUN yum update -y
RUN yum install -y \
    glibc-static \
    leveldb \
    leveldb-devel \
    libxml2-devel \
    libyaml-devel \
    lmdb-devel \
    mariadb-devel \
    sqlite-devel \
    zlib-static

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

RUN git config --global url.https://github.com/.insteadOf git://github.com/
RUN cd /root \
    && git clone https://github.com/gambit/gambit \
    && cd /root/gambit \
    && git fetch -a \
    && git checkout ${GAMBIT_VERSION}

ENV LDFLAGS  "-L/usr/lib64"
RUN cd /root/gambit \
    && ./configure \
    --prefix=/usr/local/gambit \
    --enable-single-host \
    --enable-openssl \
    --enable-default-runtime-options=f8,-8,t8 \
    --enable-poll

RUN cd /root/gambit && make -j4
RUN cd /root/gambit && make install

ENV PATH "/usr/local/gambit/bin:$PATH"

RUN cd /root && git clone https://github.com/vyzo/gerbil && cd /root/gerbil && git checkout ${GERBIL_VERSION}

RUN cd /root/gerbil/src && ls && ./configure --prefix=/usr/local/gerbil --enable-leveldb --enable-libxml --enable-libyaml --enable-lmdb

ENV GERBIL_BUILD_CORES 4
RUN cd /root/gerbil/src && ./build.sh
RUN cd /root/gerbil/src && ./install

ENV GERBIL_HOME "/root/gerbil"
ENV PATH "/root/gerbil/bin:$PATH"

ENV PATH=/usr/local/gambit/bin:/root/gerbil/bin:/bin:/sbin:/usr/bin:/usr/sbin
ENV GERBIL_HOME=/root/gerbil
ENV GERBIL_PATH=/src/.gerbil

RUN mkdir -p /src

WORKDIR /src

CMD ["gxi"]
