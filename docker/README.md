# Self-host Better Remote

This directory contains an optional Docker image for running `better-remote`.
It downloads the published Better release tarball, installs `better` and
`better-remote`, and starts the remote service with durable Docker volume
storage.

## Authentication

The container binds `0.0.0.0:8787` (non-loopback), so it requires either
repository credential files or the `BETTER_REMOTE_AUTH_TOKEN` compatibility
fallback.

Protected routes expect:

```http
Authorization: Bearer <token>
```

`/health` stays unauthenticated. Configure the CLI with an environment-variable
reference so the token is not written to Better metadata:

```bash
export BETTER_REPO_TOKEN="$(openssl rand -hex 32)"
better-remote --bind 127.0.0.1:8787 --storage-root .better-remote
better remote init local --url http://127.0.0.1:8787 \
  --repo-id repo-example --credential-env BETTER_REPO_TOKEN
better sync push
```

## Start

From the repository root:

```bash
export BETTER_REPO_TOKEN="${BETTER_REPO_TOKEN:-$(openssl rand -hex 32)}"
export BETTER_REMOTE_AUTH_TOKEN="$BETTER_REPO_TOKEN"
docker compose up -d --build
curl http://127.0.0.1:8787/health
```

The service listens on `http://127.0.0.1:8787` by default (host port mapped to
the container's non-loopback bind).

For repository-specific server credentials, create an owner-only file named
`<repo-id>.token`, mount its directory read-only into the container, and set
`BETTER_REMOTE_CREDENTIALS_DIR` to the mounted path. The packaged Compose file
uses `BETTER_REMOTE_AUTH_TOKEN` as a simpler compatibility fallback.

## Target Override

The Dockerfile auto-selects the Better Linux tarball from Docker's build
architecture. To force a specific release target, set `BETTER_TARGET`:

```bash
BETTER_TARGET=aarch64-unknown-linux-gnu docker compose up -d --build
```

## Configuration

```bash
BETTER_VERSION=0.3.2
BETTER_TARGET=
BETTER_REMOTE_PORT=8787
BETTER_REMOTE_AUTH_TOKEN=   # required for the container's 0.0.0.0 bind
# Optional alternative: directory containing owner-only <repo-id>.token files
BETTER_REMOTE_CREDENTIALS_DIR=
```

Remote state is stored in the `better-remote-data` Docker volume.
