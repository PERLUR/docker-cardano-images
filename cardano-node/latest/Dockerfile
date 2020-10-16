FROM perlur/centos-haskell-ghcup AS builder

ENV CABAL_VERSION="3.2.0.0"
ENV GHC_VERSION="8.10.2"

ENV CARDANO_NODE_VERSION="master"

RUN yum update -y && \
    yum install -y libsodium-devel openssl-devel zlib-devel
RUN ghcup upgrade
RUN ghcup install cabal ${CABAL_VERSION}
RUN ghcup install ghc ${GHC_VERSION} && \
    ghcup set ghc ${GHC_VERSION}

WORKDIR /usr/src
RUN git clone --recurse-submodules https://github.com/input-output-hk/cardano-node
WORKDIR /usr/src/cardano-node
RUN git fetch --all
RUN git checkout ${CARDANO_NODE_VERSION}
RUN git cherry-pick -n 155fc25cbb4377d86fbce1fa6476a14384b719de # Add the upcoming Allegra and Mary eras to CardanoBlock #1958
RUN git cherry-pick -n a81007b2e31c0aee9771208405fd78c41f398865 # Add the upcoming Allegra and Mary eras to CardanoBlock #1958
RUN git cherry-pick -n 4d7af4c50f7635b7fb32e977a1c2e9c8c887b3e6 # Add the upcoming Allegra and Mary eras to CardanoBlock #1958
RUN git cherry-pick -n 85e3fa880786dcd7278f8b70cc59348d38898cad # Add the upcoming Allegra and Mary eras to CardanoBlock #1958
RUN scripts/gen-cabal-nosystemd.sh

# Ugly workaround for vty-5.25.1
RUN ln -s /usr/lib64/libtinfo.so.6 /usr/lib64/libtinfo.so
RUN cabal v2-update
RUN cabal v2-install cardano-cli \
--allow-newer=base \
--ghc-options="-Wno-error=unused-imports" \
--project-file=cabal.nosystemd.project \
--installdir=/usr/local/bin \
--install-method=copy \
-f -external-libsodium-vrf \
-j
RUN cabal v2-install cardano-node \
--allow-newer=base \
--ghc-options="-Wno-error=unused-imports" \
--project-file=cabal.nosystemd.project \
--installdir=/usr/local/bin \
--install-method=copy \
-f -external-libsodium-vrf \
-j 

FROM perlur/centos-base

LABEL maintainer="Mark Stopka <mark.stopka@perlur.cloud>"

ENV SERVICE_NAME "cardano-node"

RUN yum update -y && \
    yum install -y libsodium jq && \
    yum clean all && \
    dnf clean all && \
    rm -rf /var/cache/yum && \
    rm -rf /var/cache/dnf

EXPOSE 9000

COPY --from=builder /usr/local/bin/cardano-node /usr/local/bin/
COPY --from=builder /usr/local/bin/cardano-cli /usr/local/bin/
COPY usr/local/lib/* /usr/local/lib/
COPY usr/local/bin/* /usr/local/bin/

RUN mkdir -p /srv/cardano/

RUN useradd -c "Cardano node user" \
            -d /srv/cardano/cardano-node/ \
            -m \
            -r \
            -s /bin/nologin \
            cardano-node

RUN mkdir -p /var/run/cardano/
RUN chown cardano-node.cardano-node /var/run/cardano/
USER cardano-node

RUN mkdir /srv/cardano/cardano-node/{etc,log,storage}/
RUN mkdir /srv/cardano/cardano-node/etc/secrets/

WORKDIR /srv/cardano/cardano-node/

COPY srv/cardano/cardano-node/ /srv/cardano/cardano-node/

HEALTHCHECK --interval=1s --timeout=2s CMD cnode-ctl healthcheck || exit 1

ENTRYPOINT ["/usr/local/bin/docker-entrypoint.sh"]
