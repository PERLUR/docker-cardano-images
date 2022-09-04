FROM ghcr.io/perlur/opensuse-leap-haskell-ghcup:latest AS builder

ENV CABAL_VERSION="3.6.2.0"
ENV GHC_VERSION="8.10.7"

ENV CARDANO_NODE_VERSION="1.35.3"

RUN zypper update -y && \
    zypper install -y openssl-devel libtool zlib-devel
RUN ghcup upgrade
RUN ghcup install cabal ${CABAL_VERSION}
RUN ghcup install ghc ${GHC_VERSION} && \
    ghcup set ghc ${GHC_VERSION}


WORKDIR /usr/src
RUN git clone https://github.com/input-output-hk/libsodium
WORKDIR /usr/src/libsodium
RUN git checkout 66f017f1
RUN ./autogen.sh
RUN ./configure
RUN make
RUN make install

WORKDIR /usr/src
RUN git clone https://github.com/bitcoin-core/secp256k1
WORKDIR /usr/src/secp256k1
RUN git checkout ac83be33
RUN ./autogen.sh
RUN ./configure --enable-module-schnorrsig --enable-experimental
RUN make
RUN make install

RUN zypper install -y systemd-devel gmp-devel

WORKDIR /usr/src
RUN git clone --recurse-submodules https://github.com/input-output-hk/cardano-node
WORKDIR /usr/src/cardano-node
RUN git fetch --all
RUN git checkout ${CARDANO_NODE_VERSION}
RUN scripts/gen-cabal-nosystemd.sh
COPY cabal.project.local ./

# Ugly workaround for vty-5.25.1
RUN ln -s /usr/lib64/libtinfo.so.6 /usr/lib64/libtinfo.so
RUN cabal update
RUN cabal install cardano-cli \
      --project-file=cabal.nosystemd.project \
      --installdir=/usr/local/bin \
      --install-method=copy
RUN cabal install cardano-node \
      --project-file=cabal.nosystemd.project \
      --installdir=/usr/local/bin \
      --install-method=copy

FROM ghcr.io/perlur/opensuse-leap-base:latest

LABEL maintainer="Mark Stopka <mark.stopka@perlur.cloud>"

ENV SERVICE_NAME "cardano-node"

RUN zypper update -y && \
    zypper install -y jq

EXPOSE 9000

COPY --from=builder /usr/local/bin/cardano-node /usr/local/bin/
COPY --from=builder /usr/local/bin/cardano-cli /usr/local/bin/


COPY --from=builder /usr/local/lib/libsodium.so.23.3.0 /usr/local/lib/
COPY --from=builder /usr/local/lib/libsodium.so.23 /usr/local/lib/
COPY --from=builder /usr/local/lib/libsodium.so /usr/local/lib/

COPY --from=builder /usr/local/lib/libsecp256k1.so.0.0.0 /usr/local/lib/
COPY --from=builder /usr/local/lib/libsecp256k1.so.0 /usr/local/lib/
COPY --from=builder /usr/local/lib/libsecp256k1.so /usr/local/lib/

COPY usr/local/lib/* /usr/local/lib/
COPY usr/local/bin/* /usr/local/bin/

RUN mkdir -p /srv/cardano/

RUN useradd -c "Cardano node user" \
            -d /srv/cardano/cardano-node/ \
            -m \
            -r \
            -s /sbin/nologin \
            -U \
            cardano-node

RUN mkdir -p /var/run/cardano/
RUN chown cardano-node.cardano-node /var/run/cardano/
USER cardano-node

USER root
COPY srv/cardano/cardano-node/ /srv/cardano/cardano-node/
RUN chown -R cardano-node.cardano-node /srv/cardano/cardano-node/etc/
USER cardano-node

RUN mkdir /srv/cardano/cardano-node/{log,storage}/
RUN mkdir /srv/cardano/cardano-node/etc/secrets/

WORKDIR /srv/cardano/cardano-node/

HEALTHCHECK --interval=1s --timeout=2s CMD cnode-ctl healthcheck || exit 1

ENTRYPOINT ["/usr/local/bin/docker-entrypoint.sh"]
