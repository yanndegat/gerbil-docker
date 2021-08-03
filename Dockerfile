ARG GERBIL_VERSION=master

FROM yanndegat/gambit:latest

ENV GERBIL_HOME /opt/gerbil
ENV GERBIL_PATH /src/.gerbil
ENV PATH "${GERBIL_HOME}/bin:${PATH}"
ENV GERBIL_BUILD_CORES 4

RUN mkdir -p /opt

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
