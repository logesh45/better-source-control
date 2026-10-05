# Self-host Better Remote

This directory contains an optional Docker image for running `better-remote`.
It downloads the published Better release tarball, installs `better` and
`better-remote`, and starts the remote service. Compose has three real modes:

- Filesystem: `docker compose up -d --build` (this directory's `docker-compose.yml`)
- Single-node SeaweedFS: add `docker-compose.seaweedfs.yml`
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

## Single-node SeaweedFS

SeaweedFS 4.48 is pinned by version and immutable image digest. It is
Apache-2.0 licensed and runs its master, volume server, filer, and S3 gateway
in one process. This is a small self-hosted deployment, **not** an HA cluster.
For larger deployments, use a separately operated distributed S3 service
with the external S3 overlay.

```bash
export BETTER_REMOTE_AUTH_TOKEN="$BETTER_REPO_TOKEN"
export SEAWEEDFS_ACCESS_KEY="better-$(openssl rand -hex 8)"
export SEAWEEDFS_SECRET_KEY="$(openssl rand -hex 32)"
docker compose -f docker-compose.yml -f docker-compose.seaweedfs.yml up -d --build
```

Keep credentials in a protected environment file or secret manager and reuse
them after restarts. They bootstrap SeaweedFS identities; changing environment
variables is not a documented credential-rotation mechanism.
Only S3 port `127.0.0.1:8333` is published. Master/filer ports stay on the
Compose network. Do not expose those internal unauthenticated services.
Unused WebDAV, Admin UI, Iceberg, and Lance interfaces are disabled.
For remote access, put Better behind a TLS reverse proxy; don't expose S3
unless a trusted client needs it.

The named `better-seaweedfs-data` volume persists storage. Back up it **and**
`better-remote-data` while both services are stopped, and test restores.
`docker compose down` preserves volumes; `down --volumes` destroys them.
A single disk/host failure is not covered by replication.

### Existing MinIO users

`docker-compose.minio.yml` is a deprecated filename alias. It refuses to run
unless `BETTER_MINIO_MIGRATION_ACK` is explicitly set, preventing an unnoticed
backend switch. Once acknowledged it starts SeaweedFS, not MinIO. Prefer the
new filename after migration. It does **not** read or migrate `better-minio-data`.
Before upgrading, stop and back up your old stack and preserve the MinIO
volume. Use a new Compose project/volume and remote repository ID, push from
a complete Better checkout, and verify a fresh pull plus `better restore frontier`
before retiring the old server. Do not mount MinIO disk data into SeaweedFS.
For large installations use a tested S3 migration tool; no automatic migration
is provided.

To upgrade SeaweedFS, change its version and digest together in the canonical
overlay, then run the image-pin guard and real Docker push/pull/restore tests.
The released Better Dockerfile remains unchanged.

## External S3

Point `better-remote` at real AWS S3 or another S3-compatible endpoint without
starting a local object store:

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

`BETTER_REMOTE_S3_PATH_STYLE` should stay `true` for SeaweedFS and most
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
BETTER_VERSION=0.5.0
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
# SEAWEEDFS_ACCESS_KEY=          # required for the SeaweedFS overlay
# SEAWEEDFS_SECRET_KEY=          # required; no insecure default
```
