FROM ubuntu:bionic

# Download folder for EOSIO releases
ARG DOWNLOAD=https://github.com/eosio/eos/releases/download

# Default EOSIO version, see .env file
ARG VER=2.0.12

# Install required packages, including EOSIO
RUN                                                                            \
  DEBIAN_FRONTEND=noninteractive                                               \
  apt-get update                                                            && \
  apt-get --yes --no-install-recommends install                                \
    ca-certificates                                                            \
    coreutils                                                                  \
    curl                                                                       \
    jq                                                                         \
    libjson-pp-perl                                                            \
    wget                                                                       \
    xxd                                                                     && \
  wget -P /tmp $DOWNLOAD/v${VER}/eosio_${VER}-1-ubuntu-18.04_amd64.deb      && \
  apt-get --yes install                                                        \
    /tmp/eosio_${VER}-1-ubuntu-18.04_amd64.deb

# Copy our entrypoint scripts into the path for shorthand execution
COPY bin/ /usr/local/bin/
