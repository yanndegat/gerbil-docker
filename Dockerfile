FROM yanndegat/gambit:latest

ARG GERBIL_VERSION=master

ENV GERBIL_HOME /usr/local/gerbil
ENV GERBIL_PATH /src/.gerbil
ENV GERBIL_BUILD_CORES 4

ENV PATH "${GERBIL_HOME}/bin:${PATH}"

RUN git config --global url.https://github.com/.insteadOf git://github.com/

# install gerbil
RUN cd /tmp \
    && git clone --single-branch --branch ${GERBIL_VERSION} https://github.com/vyzo/gerbil \
    && cd gerbil/src \
    && ./configure \
    --prefix=${GERBIL_HOME} \
    --enable-leveldb \
    --enable-libxml \
    --enable-libyaml \
    --enable-lmdb \
    && ./build.sh \
    && ./install \
    && cd /tmp && rm -Rf gerbil

RUN mkdir -p /src

WORKDIR /src

CMD ["gxi"]
