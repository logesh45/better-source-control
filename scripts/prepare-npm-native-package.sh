#!/usr/bin/env bash
set -euo pipefail

usage() {
  cat <<'USAGE'
Usage: scripts/prepare-npm-native-package.sh --target <target> --version <version> --artifact <tar.gz> --out-dir <dir>

Creates a platform-native npm package from a Better release tarball for private
smoke tests and future publication.
USAGE
}

target=""
version=""
artifact=""
out_dir=""

while [ "$#" -gt 0 ]; do
  case "$1" in
    --target)
      target="${2:-}"
      shift 2
      ;;
    --version)
      version="${2:-}"
      shift 2
      ;;
    --artifact)
      artifact="${2:-}"
      shift 2
      ;;
    --out-dir)
      out_dir="${2:-}"
      shift 2
      ;;
    -h|--help)
      usage
      exit 0
      ;;
    *)
      echo "unknown argument: $1" >&2
      usage >&2
      exit 2
      ;;
  esac
done

if [ -z "$target" ] || [ -z "$version" ] || [ -z "$artifact" ] || [ -z "$out_dir" ]; then
  usage >&2
  exit 2
fi

case "$target" in
  aarch64-apple-darwin) package_name="@better-scm/better-darwin-arm64"; npm_os="darwin"; npm_cpu="arm64" ;;
  x86_64-apple-darwin) package_name="@better-scm/better-darwin-x64"; npm_os="darwin"; npm_cpu="x64" ;;
  aarch64-unknown-linux-gnu) package_name="@better-scm/better-linux-arm64"; npm_os="linux"; npm_cpu="arm64" ;;
  x86_64-unknown-linux-gnu) package_name="@better-scm/better-linux-x64"; npm_os="linux"; npm_cpu="x64" ;;
  *) echo "unsupported npm native target: $target" >&2; exit 1 ;;
esac

package_dir="$out_dir/${package_name#@better-scm/}"
rm -rf "$package_dir"
mkdir -p "$package_dir/bin"

tmp="$(mktemp -d)"
trap 'rm -rf "$tmp"' EXIT
tar -xzf "$artifact" -C "$tmp"

better_src="$(find "$tmp" -type f -path '*/bin/better' | head -n 1)"
if [ -z "$better_src" ]; then
  better_src="$(find "$tmp" -type f -name better | head -n 1)"
fi
[ -n "$better_src" ] || { echo "artifact does not contain better" >&2; exit 1; }

cp "$better_src" "$package_dir/bin/better"
chmod +x "$package_dir/bin/better"

cat >"$package_dir/package.json" <<JSON
{
  "name": "$package_name",
  "version": "$version",
  "description": "Native Better binary for $target.",
  "license": "MIT OR Apache-2.0",
  "os": ["$npm_os"],
  "cpu": ["$npm_cpu"],
  "files": ["bin/better"]
}
JSON

printf '%s\n' "$package_dir"
