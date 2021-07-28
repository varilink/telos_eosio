# Telos UK - EOSIO

David Wiiliamson @ Varilink Computing Ltd

------

Docker Compose services that implement:

- The cleos, keosd and nodeos commands that are components of EOSIO, the Block.one, open-source blockchain protocol.
- A couple of convenience tools, one for generating snapshots and the other for gaining access to the nodeos data within Docker containers.

This repository has been created as it has proved useful in my support role for [Telos UK](https://telosuk.io/), "a Founding Block Producer on the Telos Public Network". I'm sharing it in case it might prove useful to anybody else in the Telos community, or the wider EOSIO community.

These tools/services are implemented as Docker Compose services and so you will require that Docker is installed on your client in order to use them as illustrated below. They encapsulate all the setup required to use EOSIO.

## Image Build

The Docker Compose services defined in this repository use the common image varilink/eosio, which can be built via the command:

```bash
docker-compose build
```

Or, if you prefer:

```bash
docker-compose build [service]
```

Where *service* is any one of "cleos", "keosd", "nodeos", "snapshot" or "data", which avoids performing the build five times but if the *service* is omitted then the second build and onward use the cached result of the first build, so it doesn't really matter.

By default the build will use version 2.0.12 of EOSIO. However, this can be overridden via the environment variable VER - see the .env file for further information on this. The images will be automatically tagged with the EOSIO version used if the build is done as per the above instructions.

## Usage by Docker Compose Service

### cleos

cleos is a CLI tool rather than a background service, consequently I use `docker-compose run` rather than `docker-compose up` to execute it and set the `--rm` flag as the container is entirely disposable; for example:

```bash
docker-compose run --rm cleos --help
```

This cleos service wraps the EOSIO cleos command so that:

1. The cleos command line option `--wallet-url` is set to http://eosio-keosd:8888 and cannot be overridden. This is the address that the [keosd service](#keosd) listens on. In this way the cleos and keosd services are automatically integrated and running the cleos service will bring up the keosd service via the Docker Compose `depends_on` instruction.
2. The cleos service can be run with no `-u` or `--url` option set, in which case it will access the API endpoint corresponding to the [nodeos service](#nodeos), again providing integration between the services. However, this can be overridden when the cleos service is run.

So. this command will query the API endpoint associated with the nodeos service (http://eosio-nodeos:8888):

```bash
docker-compose run --rm cleos get info
```

Whereas this command will of course query the API endpoint provided by Telos UK at https://api.telosuk.io

```bash
docker-compose run --rm cleos -u https://api.telosuk.io get info
```

Be aware that the nodeos service will only be listening for API requests at http://eosio-nodeos:8888 if it is started via `docker-compose up` rather than `docker-compose run`, the former should be considered the default means of starting the service whereas the latter facilitates the override of command line options, which is sometimes needed.

Since the cleos command can be used *not* in conjunction with the nodeos service, running the cleos service does *not* automatically start the nodeos service.

### keosd

As stated above, the keosd service will be automatically brought up whenever the [cleos service](#cleos) is run and the startup time is trivial. Since interaction with the wallet is exclusively via the cleos command, there is never any need to directly run or bring up the keosd service.

 So, I can for example create and populate a local wallet via:

```bash
docker-compose run --rm cleos wallet create --to-console
```

And, having made a note of the wallet password for future reference:

```bash
docker-compose run --rm cleos wallet import --private-key ...
```

Repeatedly, for one or more private keys that I wish to have in that local wallet.

Note: Any wallets created in this way are persisted in the eosio_wallet Docker volume - see [Docker Volumes](#docker-volumes).

### nodeos

Note: I do *not* use this Docker Compose service to run nodes for [Telos UK](https://telosuk.io) block production and P2P peer and API service provision. It was *not* created for that purpose. For one thing, as defined in this repository it does not provide a P2P or API endpoint externally. I use this service solely for learning/test experiments.

Since the nodeos `--data-dir` is persisted using the eosio_data Docker volume (see [Docker Volumes](#docker-volumes)), I can start synchronising from genesis using suitable `config.ini` and `genesis.json` files:

```bash
docker-compose run --rm nodeos --delete-all-blocks --genesis-json /config/genesis.json
```

The `--delete-all-blocks` option when starting synchronisation from genesis is only necessary if the eosio_data Docker volume needs to be cleared down. Once synchronisation is up and running, I can gracefully shutdown nodeos using CTRL+C and then bring the service up again:

```bash
docker-compose up nodeos
```

As mentioned above, when the nodeos service has been brought up again, it provides an API endpoint to the local, Docker network and so I can query that API service using the [cleos service](#cleos) if I wish:

```bash
docker-compose run --rm cleos get info
```

As explained above under the [cleos service](#cleos), this will default -u or --url to http://eosio-nodeos:8888.

### snapshot

This is a convenience service provided to facilitate the generation of snapshots. As with the [nodeos service](#nodeos), I use this for learning/test experiments only.

To use this service, I first stop the [nodeos service](#nodeos) if it is running. A snapshot can then be easily generated via:

```bash
docker-compose run --rm snapshot
```

The generated snapshot will be written to the snapshots direcotry within the eosio_data Docker volume.

### data

This is a convenience service for the inspection and manipulation of the eosio_data Docker volume. This command opens a shell positioned within that volume in order to inspect or manipulate its contents:

```bash
docker-compose run --rm data
```

## Docker Volumes

These services use the following Docker volumes:

### config

The contents of a `config` directory created in this repository's top-level directory on the host is mapped to `/config` in the nodeos and snapshot service containers. Furthermore the entrypoint scripts for those services have `/config` set as the `--config-dir` for the nodeos processes that they run. Thus if a file `config.ini` is placed within the `config` directory in this repository's top-level directory on the host, then this will be used as the configuration file for nodeos.

To prevent nodeos writing the `protocol_features` folder within its `--config-dir` and hence back to the host, which it would do by default, the nodeos commands within the nodeos and snapshot services set `--protocol-features-dir` to `/protocol_features` within the containers they create. This means of course that the contents of this folder can't be set prior to running nodeos, which will populate this folder with defaults if it is empty, and furthermore those contents are not persisted beyond the life of the container. However, to date I have not had the need to do otherwise for my learning/test purposes.

### eosio_data

The contents of the nodeos `--data-dir` must be shared between different containers because:

1. As described in the notes on the [nodeos service](#nodeos), I have cause to use `docker-compose run nodeos` as well as `docker-compose up nodeos` commands acting on the same nodeos `--data-dir`.
2. Regardless of this, I share the `--data-dir` between the [nodeos service](#nodeos) and the [snapshot service](#snapshot).

Thus there is a need to persist the contents of the `--data-dir` via a Docker volume.

### eosio_wallet

Though in theory there is no need to persist the contents of the `--wallet-dir` beyond the life of a container associated with the [keosd service](#keosd), I choose to store those contents within a Docker volume so that wallet data is not inadvertently lost by, for example, removing a container.
