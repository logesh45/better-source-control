#!/usr/bin/env bash
set -euo pipefail

BETTER_VERSION="${BETTER_VERSION:-0.1.0-rc.3}"
BETTER_INSTALL_DIR="${BETTER_INSTALL_DIR:-$HOME/.local/bin}"
BETTER_GITHUB_RELEASES_URL="${BETTER_GITHUB_RELEASES_URL:-https://github.com/logesh45/better-source-control/releases}"

if [ -z "${BETTER_RELEASE_BASE_URL:-}" ]; then
  if [ "$BETTER_VERSION" = "latest" ]; then
    BETTER_RELEASE_BASE_URL="$BETTER_GITHUB_RELEASES_URL/latest/download"
  else
    BETTER_RELEASE_BASE_URL="$BETTER_GITHUB_RELEASES_URL/download/v$BETTER_VERSION"
  fi
fi

die() {
  printf 'better installer: %s\n' "$*" >&2
  exit 1
}

need() {
  command -v "$1" >/dev/null 2>&1 || die "required command not found: $1"
}

release_target() {
  os="$(uname -s)"
  arch="$(uname -m)"

  case "$os:$arch" in
    Linux:x86_64 | Linux:amd64)
      printf '%s\n' "x86_64-unknown-linux-gnu"
      ;;
    Linux:aarch64 | Linux:arm64)
      printf '%s\n' "aarch64-unknown-linux-gnu"
      ;;
    Darwin:x86_64)
      printf '%s\n' "x86_64-apple-darwin"
      ;;
    Darwin:arm64 | Darwin:aarch64)
      printf '%s\n' "aarch64-apple-darwin"
      ;;
    *)
      die "unsupported platform: $os $arch"
      ;;
  esac
}

fetch() {
  url="$1"
  dest="$2"

  case "$url" in
    file://*)
      src="${url#file://}"
      cp "$src" "$dest"
      ;;
    http://* | https://*)
      curl --fail --location --silent --show-error "$url" --output "$dest"
      ;;
    *)
      die "unsupported download URL: $url"
      ;;
  esac
}

sha256_file() {
  path="$1"

  if command -v shasum >/dev/null 2>&1; then
    shasum -a 256 "$path" | awk '{print $1}'
  elif command -v sha256sum >/dev/null 2>&1; then
    sha256sum "$path" | awk '{print $1}'
  else
    die "required command not found: shasum or sha256sum"
  fi
}

manifest_value() {
  key="$1"
  printf '%s\n' "$artifact_block" |
    sed -n "s/.*\"$key\"[[:space:]]*:[[:space:]]*\"\\([^\"]*\\)\".*/\\1/p"
}

need awk
need cp
need mkdir
need sed
need tar

target="$(release_target)"
workdir="$(mktemp -d "${TMPDIR:-/tmp}/better-install.XXXXXX")"
trap 'rm -rf "$workdir"' EXIT INT TERM

manifest="$workdir/manifest.json"
fetch "${BETTER_RELEASE_BASE_URL%/}/manifest.json" "$manifest"

artifact_block="$(
  tr '\n' ' ' <"$manifest" |
    grep -o "{[^{}]*\"target\"[[:space:]]*:[[:space:]]*\"$target\"[^{}]*}" |
    head -n 1
)"

[ -n "$artifact_block" ] || die "manifest does not include target: $target"

artifact_name="$(manifest_value name)"
artifact_url="$(manifest_value url)"
expected_sha256="$(manifest_value sha256)"

[ -n "$artifact_name" ] || die "manifest entry for $target is missing name"
[ -n "$expected_sha256" ] || die "manifest entry for $target is missing sha256"
[ -n "$artifact_url" ] || artifact_url="${BETTER_RELEASE_BASE_URL%/}/$artifact_name"
case "$artifact_url" in
  file://* | http://* | https://*) ;;
  *) artifact_url="${BETTER_RELEASE_BASE_URL%/}/$artifact_url" ;;
esac

archive="$workdir/$artifact_name"
fetch "$artifact_url" "$archive"

actual_sha256="$(sha256_file "$archive")"
[ "$actual_sha256" = "$expected_sha256" ] ||
  die "checksum mismatch for $artifact_name: expected $expected_sha256, got $actual_sha256"

extract_dir="$workdir/extract"
mkdir -p "$extract_dir" "$BETTER_INSTALL_DIR"
tar -xzf "$archive" -C "$extract_dir"

better_src="$(find "$extract_dir" -type f -name better -perm -u+x | head -n 1)"
if [ -z "$better_src" ]; then
  better_src="$(find "$extract_dir" -type f -name better | head -n 1)"
fi
[ -n "$better_src" ] || die "artifact does not contain better executable"

better_remote_src="$(find "$extract_dir" -type f -name better-remote -perm -u+x | head -n 1)"
if [ -z "$better_remote_src" ]; then
  better_remote_src="$(find "$extract_dir" -type f -name better-remote | head -n 1)"
fi
[ -n "$better_remote_src" ] || die "artifact does not contain better-remote executable"

cp "$better_src" "$BETTER_INSTALL_DIR/better"
chmod +x "$BETTER_INSTALL_DIR/better"
cp "$better_remote_src" "$BETTER_INSTALL_DIR/better-remote"
chmod +x "$BETTER_INSTALL_DIR/better-remote"

PATH="$BETTER_INSTALL_DIR:$PATH" better --version

printf 'Installed better to %s\n' "$BETTER_INSTALL_DIR/better"
printf 'Installed better-remote to %s\n' "$BETTER_INSTALL_DIR/better-remote"
case ":$PATH:" in
  *":$BETTER_INSTALL_DIR:"*) ;;
  *)
    printf '\nAdd it to your PATH:\n'
    if [ "$BETTER_INSTALL_DIR" = "$HOME/.local/bin" ]; then
      printf '  export PATH="$HOME/.local/bin:$PATH"\n'
    else
      printf '  export PATH="%s:$PATH"\n' "$BETTER_INSTALL_DIR"
    fi
    printf '\nThen restart your terminal or run the export command above.\n'
    ;;
esac
