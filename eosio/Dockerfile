FROM ubuntu:bionic

ARG DOWNLOAD=https://github.com/eosio/eos/releases/download
ARG VER=2.0.11

RUN                                                                            \
  apt-get update                                                            && \
  apt-get --yes --no-install-recommends install                                \
    ca-certificates                                                            \
    wget

RUN                                                                            \
  wget -P /tmp $DOWNLOAD/v${VER}/eosio_${VER}-1-ubuntu-18.04_amd64.deb      && \
  apt-get --yes install                                                        \
    /tmp/eosio_${VER}-1-ubuntu-18.04_amd64.deb
