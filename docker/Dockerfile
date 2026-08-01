FROM debian:bookworm-slim

ARG BETTER_VERSION=0.1.2
ARG BETTER_TARGET
ARG BETTER_RELEASE_BASE_URL=https://github.com/logesh45/better-source-control/releases/download
ARG TARGETARCH

RUN apt-get update \
  && apt-get install -y --no-install-recommends ca-certificates curl tar \
  && rm -rf /var/lib/apt/lists/*

RUN target="${BETTER_TARGET:-}" \
  && if [ -z "$target" ]; then \
    case "${TARGETARCH:-}" in \
      amd64) target="x86_64-unknown-linux-gnu" ;; \
      arm64) target="aarch64-unknown-linux-gnu" ;; \
      *) echo "unsupported Docker build architecture: ${TARGETARCH:-unknown}; set BETTER_TARGET" >&2; exit 1 ;; \
    esac; \
  fi \
  && artifact="better-${BETTER_VERSION}-${target}.tar.gz" \
  && release_url="${BETTER_RELEASE_BASE_URL}/v${BETTER_VERSION}" \
  && curl -fsSL "${release_url}/${artifact}" -o "/tmp/${artifact}" \
  && curl -fsSL "${release_url}/SHA256SUMS" -o /tmp/SHA256SUMS \
  && grep "  ${artifact}$" /tmp/SHA256SUMS > /tmp/better.sha256 \
  && (cd /tmp && sha256sum -c better.sha256) \
  && tar -xzf "/tmp/${artifact}" -C /tmp \
  && better_src="$(find /tmp -type f -path '*/bin/better' | head -n 1)" \
  && better_remote_src="$(find /tmp -type f -path '*/bin/better-remote' | head -n 1)" \
  && test -n "$better_src" \
  && test -n "$better_remote_src" \
  && install -m 0755 "$better_src" /usr/local/bin/better \
  && install -m 0755 "$better_remote_src" /usr/local/bin/better-remote \
  && rm -rf "/tmp/${artifact}" /tmp/SHA256SUMS /tmp/better.sha256 /tmp/better-*

RUN useradd --create-home --shell /usr/sbin/nologin better

USER better
EXPOSE 8787
VOLUME ["/var/lib/better-remote"]

ENTRYPOINT ["better-remote"]
CMD ["--bind", "0.0.0.0:8787", "--storage-root", "/var/lib/better-remote"]
