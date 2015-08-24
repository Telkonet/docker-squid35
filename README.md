# Telkonet/docker-squid35

- [Introduction](#introduction)
  - [Contributing](#contributing)
  - [Issues](#issues)
- [Getting started](#getting-started)
  - [Installation](#installation)
  - [Quickstart](#quickstart)
  - [Command-line arguments](#command-line-arguments)
  - [Persistence](#persistence)
  - [Configuration](#configuration)
  - [Usage](#usage)
  - [Logs](#logs)
- [Maintenance](#maintenance)
  - [Shell Access](#shell-access)

# Introduction

***NOTE:*** This is essentially a fork from [sameersbn/docker-squid](https://github.com/sameersbn/docker-squid)

`Dockerfile` to create a [Docker](https://www.docker.com/) container image for [Squid proxy server](http://www.squid-cache.org/).

Squid is a caching proxy for the Web supporting HTTP, HTTPS, FTP, and more. It reduces bandwidth and improves response times by caching and reusing frequently-requested web pages. Squid has extensive access controls and makes a great server accelerator.

## Contributing

If you find this image useful here's how you can help:

- Send a pull request with your awesome features and bug fixes
- Help users resolve their [issues](../../issues?q=is%3Aopen+is%3Aissue).

## Issues

Before reporting your issue please try updating Docker to the latest version and check if it resolves the issue. Refer to the Docker [installation guide](https://docs.docker.com/installation) for instructions.

SELinux users should try disabling SELinux using the command `setenforce 0` to see if it resolves the issue.

If the above recommendations do not help then [report your issue](../../issues/new) along with the following information:

- Output of the `docker version` and `docker info` commands
- The `docker run` command or `docker-compose.yml` used to start the image. Mask out the sensitive bits.
- Please state if you are using [Boot2Docker](http://www.boot2docker.io), [VirtualBox](https://www.virtualbox.org), etc.

# Getting started

## Installation

You can build the image yourself.

```bash
git clone https://github.com/telkonet/docker-squid35.git
cd docker-squid
docker build --tag telkonet/squid .
```

## Quickstart

Start Squid using:

```bash
docker run --name squid -d --restart=always \
  --publish 3128:3128 \
  --volume /srv/docker/squid/cache:/var/spool/squid3 \
  telkonet/squid35:latest
```

*Alternatively, you can use the sample [docker-compose.yml](docker-compose.yml) file to start the container using [Docker Compose](https://docs.docker.com/compose/)*

## Command-line arguments

You can customize the launch command of the Squid server by specifying arguments to `squid3` on the `docker run` command. For example the following command prints the help menu of `squid3` command:

```bash
docker run --name squid -it --rm \
  --publish 3128:3128 \
  --volume /srv/docker/squid/cache:/var/spool/squid3 \
  telkonet/squid35:latest -h
```

## Persistence

For the cache to preserve its state across container shutdown and startup you should mount a volume at `/var/spool/squid3`.

> *The [Quickstart](#quickstart) command already mounts a volume for persistence.*

SELinux users should update the security context of the host mountpoint so that it plays nicely with Docker:

```bash
mkdir -p /srv/docker/squid
chcon -Rt svirt_sandbox_file_t /srv/docker/squid
```

## Configuration

Squid is a full featured caching proxy server and a large number of configuration parameters. To configure Squid as per your requirements edit the default [squid.conf](squid.conf) and volume mount it at `/etc/squid3/squid.conf`.

```bash
docker run --name squid -d --restart=always \
  --publish 3128:3128 \
  --volume /path/to/squid.conf:/etc/squid3/squid.conf \
  --volume /srv/docker/squid/cache:/var/spool/squid3 \
  telkonet/squid35:latest
```

To reload the Squid configuration on a running instance you can send the `HUP` signal to the container.

```bash
docker kill -s HUP squid
```

## Usage
***@TODO***

## Logs

To access the Squid logs, located at `/var/log/squid3/`, you can use `docker exec`. For example, if you want to tail the access logs:

```bash
docker exec -it squid tail -f /var/log/squid3/access.log
```

You can also mount a volume at `/var/log/squid3/` so that the logs are directly accessible on the host.

## Shell Access

For debugging and maintenance purposes you may want access the containers shell. If you are using Docker version `1.3.0` or higher you can access a running containers shell by starting `bash` using `docker exec`:

```bash
docker exec -it squid bash
```
