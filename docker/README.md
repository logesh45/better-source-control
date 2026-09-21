# Self-host Better Remote

This directory contains an optional Docker image for running `better-remote`.
It downloads the published Better release tarball, installs `better` and
`better-remote`, and starts the remote service. Compose has three real modes:

- Filesystem: `docker compose up -d --build` (this directory's `docker-compose.yml`)
- Local-dev MinIO: add `docker-compose.minio.yml`
- External S3: add `docker-compose.s3.yml`

`BETTER_REMOTE_STORAGE` is the object store in filesystem mode and the process
lock directory when an S3 overlay is attached.

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

From the repository root. Filesystem mode:

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

## Local-dev MinIO

This is a local-dev overlay, not a production self-host default. It uses
`better` / `betterpassword` and publishes host ports `9000` (S3 API) and
`9001` (console). Override `MINIO_ROOT_USER` and `MINIO_ROOT_PASSWORD`.

```bash
export BETTER_REMOTE_AUTH_TOKEN="$BETTER_REPO_TOKEN"
docker compose -f docker-compose.yml -f docker-compose.minio.yml up -d --build
```

The overlay is the only Compose file that pins the MinIO image
(`release-repo/docker-compose.minio.yml`). The developer checkout includes that
same file from `docker-compose.remote.yml`.

## External S3

Point `better-remote` at real AWS S3 or another S3-compatible endpoint without
starting MinIO:

```bash
export BETTER_REMOTE_AUTH_TOKEN="$BETTER_REPO_TOKEN"
export BETTER_REMOTE_S3_ENDPOINT=https://s3.us-east-1.amazonaws.com   # omit for default AWS
export BETTER_REMOTE_S3_BUCKET=better-remotes
export BETTER_REMOTE_S3_REGION=us-east-1
export BETTER_REMOTE_S3_ACCESS_KEY="$AWS_ACCESS_KEY_ID"
export BETTER_REMOTE_S3_SECRET_KEY="$AWS_SECRET_ACCESS_KEY"
export BETTER_REMOTE_S3_PATH_STYLE=false
docker compose -f docker-compose.yml -f docker-compose.s3.yml up -d --build
```

`BETTER_REMOTE_S3_PATH_STYLE` should stay `true` for MinIO and most
S3-compatible endpoints, and `false` for real AWS S3 virtual-hosted-style
access. If `BETTER_REMOTE_S3_BUCKET` is set, `AWS_ACCESS_KEY_ID` /
`AWS_SECRET_ACCESS_KEY` are accepted when the `BETTER_REMOTE_S3_*` key
variables are unset. Partial S3 config (endpoint without bucket or keys) is an
error.

## Target Override

The Dockerfile auto-selects the Better Linux tarball from Docker's build
architecture. To force a specific release target, set `BETTER_TARGET`:

```bash
BETTER_TARGET=aarch64-unknown-linux-gnu docker compose up -d --build
```

## Configuration

```bash
BETTER_VERSION=0.4.0
BETTER_TARGET=
BETTER_REMOTE_PORT=8787
BETTER_REMOTE_AUTH_TOKEN=   # required for the container's 0.0.0.0 bind
# Optional alternative: directory containing owner-only <repo-id>.token files
BETTER_REMOTE_CREDENTIALS_DIR=
BETTER_REMOTE_STORAGE=/var/lib/better-remote
# S3 overlays only:
# BETTER_REMOTE_S3_ENDPOINT=
# BETTER_REMOTE_S3_BUCKET=
# BETTER_REMOTE_S3_REGION=us-east-1
# BETTER_REMOTE_S3_ACCESS_KEY=
# BETTER_REMOTE_S3_SECRET_KEY=
# BETTER_REMOTE_S3_PATH_STYLE=
# MINIO_ROOT_USER=better          # local-dev MinIO overlay only
# MINIO_ROOT_PASSWORD=betterpassword
```
