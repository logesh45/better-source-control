# Self-host Better Remote

This directory contains an optional Docker image for running `better-remote`.
It downloads the published Better release tarball, installs `better` and
`better-remote`, and starts the remote service with durable Docker volume
storage.

## Start

From the repository root:

```bash
docker compose up -d --build
```

The service listens on `http://127.0.0.1:8787` by default.

Configure a Better repo to use it:

```bash
better remote init local --url http://127.0.0.1:8787
better sync push
```

## Target Override

The Dockerfile auto-selects the Better Linux tarball from Docker's build
architecture. To force a specific release target, set `BETTER_TARGET`:

```bash
BETTER_TARGET=aarch64-unknown-linux-gnu docker compose up -d --build
```

## Configuration

```bash
BETTER_VERSION=0.1.1
BETTER_TARGET=
BETTER_REMOTE_PORT=8787
```

Remote state is stored in the `better-remote-data` Docker volume.
