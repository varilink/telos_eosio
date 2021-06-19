# Telos UK - EOSIO

Varilink Computing Ltd

------

Docker Compose services that implement:

- The cleos, keosd and nodeos commands that are components of EOSIO, the Block.one, open-source blockchain protocol.
- A tool for conveniently generating snapshots.

This repository has been created as it has proved useful in our support role for [Telos UK](https://telosuk.io/), "a Founding Block Producer on the Telos Public Network". We're sharing it in case it might prove useful to anybody else in the Telos community, or the wider EOSIO community.

## Image Build

The Docker Compose services defined in this repository use the common image varilink/eosio, which can be built via the command:

```bash
docker-compose build
```

Or, if you prefer:

```bash
docker-compose build [service]
```

Where *service* is any one of "cleos", "keosd", "nodeos" or "snapshot", which avoids performing the build four times but if the *service* is omitted then the second build and onward use the cached result of the first build so it doesn't really matter.

By default the build will use version 2.0.12 of EOSIO. However, this can be overridden via the environment variable VER - see the .env file for further information on this. The images will be automatically tagged with the EOSIO version used if the build is done as per the above instructions.

## Usage by Service

### cleos

cleos is a CLI tool rather than a background service. We use `docker-compose run` rather than `docker-compose up` to execute it and set the `--rm` flag as the container is entirely disposable; for example:

```bash
docker-compose run --rm cleos --help
```



```bash
docker-compose run --rm cleos -u https://api.telosuk.io get info
```

Since our cleos service `depends_on` our keosd service, the keosd service will be automatically brought up whenever our cleos service is used and the cleos `--wallet-url` parameter is set to where our keosd service will be listening in the cleos service's entrypoint script. All other cleos options can be passed on the command line, as per the `--help` and `-u https://api.telosuk.io` options in the examples above.

### keosd

As stated above, our keosd service will be automatically brought up whenever the cleos service is run and the startup time is trivial. Since interaction with the wallet is via the cleos command, there is never any need to directly run or bring up the keosd service.

 So, we can for example create and populate a local wallet via:

```bash
docker-compose run --rm cleos wallet create --to-console 
```

And, having made a note of the wallet password for future reference:

```bash
docker-compose run --rm cleos wallet import --private-key ... 
```

Repeatedly, for one or more private keys that we wish to have in that local wallet.

Note: Any wallets we create in this way are persisted in the wallet Docker volume (see [Docker Volumes](#docker-volumes) below).

### nodeos

Note: We do **not** use this Docker Compose service to run nodes for [Telos UK](https://telosuk.io) block production and P2P peer and API service provision. It is not suitable for that purpose. For one thing, as defined in this repository it does not provide a P2P or API endpoint externally. We use this service solely for learning/test experiments only.

Since the nodeos `--data-dir` is persisted using the eosio_data Docker volume (see [Docker Volumes](#docker-volumes) below), we can start synchronising from genesis using suitable `config.ini` and `genesis.json` files:

```bash
docker-compose run --rm nodeos --delete-all-blocks --genesis-json /config/genesis.json
```

And once synchronisation is up and running, we can gracefully shutdown nodeos using CTRL+C and then bring the service up again:

```bash
docker-compose up nodeos
```

The `--delete-all-blocks` option when starting synchronisation from genesis is only necessary if the eosio_data Docker volume needs to be cleared down.

When our nodeos service has been brought up again, it provides an API endpoint to the local, Docker network and so we can query that API service using our cleos service if we wish:

```bash
docker-compose run --rm cleos -u http://eosio-nodeos:8888 get info
```

### snapshot

This is a convenience service provided to facilitate the generation of snapshots. As with the nodeos service, we use this for learning/test experiments only.

To use this service, we first stop our nodeos service if it is running. A snapshot can then be easily generated via:

```bash
docker-compose run --rm snapshot 
```

The generated snapshot will be written to the snapshots folder within the eosio_data Docker volume.

## Docker Volumes

These services use the following docker volumes:

### config

The contents of a `config` directory created in this repository's root folder on the host is mapped to `/config` in the nodeos and snapshot service containers. Furthermore the entrypoint scripts for those services have `/config` set as the `--config-dir` for the nodeos processes that they run. Thus if a file `config.ini` is placed within the `config` directory in this repository's root folder on the host, then this will be used as the configuration file for nodeos.

To prevent nodeos writing the `protocol_features` folder within its `--config-dir` and hence back to the host, which it would do by default, the nodeos commands within our nodeos and snapshot services set `--protocol-features-dir` to `/protocol_features` within the containers they create. This means of course that the contents of this folder can't be set prior to running nodeos, which will populate this folder with defaults if it is empty, and furthermore those contents are not persisted beyond the life of the container. However, to date we have not had the need to do otherwise for our learning/text purposes.

### eosio_data

The contents of our nodeos `--data-dir` must be shared between different containers because:

1. As described in the notes above on [how to use our nodeos service](#nodeos), we may have cause to use `docker-compose run nodeos` as well as `docker-compose up nodeos` commands acting on the same nodeos `--data-dir`.
2. Regardless of this, we may need to share the `--data-dir` between our nodeos and snapshot services.

Thus there a need to persist the contents of the `--data-dir` via a Docker volume.

### eosio_wallet

Though there is no need to persist the contents of the `--wallet-dir` beyond the life of a container associated with our keosd service, we choose to store those contents within a Docker volume so that wallet data is not inadvertently lost by for example removing a container.

## Implementation of Command Line Options

The EOSIO commands all accept command line options. In making decisions about how to implement these in our Docker Compose services, we have taken into account the following considerations:

1. Since we are use a common image with entrypoint set in the Docker Compose service definitions, we do not set EOSIO command line options via ENTRYPOINT or CMD settings in the Dockerfile.
2. Any options specified in the entrypoint scripts are fixed and cannot be overridden except by overriding the entrypoint setting for a Docker Compose service using the `--entrypoint` option to the `docker-compose run` command.
3. We can set sensible default options for services defined in our Docker Compose file using the `command` setting.
4. While command line options can be provided with `docker-compose run` they cannot with `docker-compose up`. If they are provided with `docker-compose run` they will override default options set for the service in the Docker Compose file.





