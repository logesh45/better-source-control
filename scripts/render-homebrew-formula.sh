#!/usr/bin/env bash
set -euo pipefail

usage() {
  cat <<'USAGE'
Usage: scripts/render-homebrew-formula.sh --manifest <manifest.json> --template <template> --out <formula.rb> [--base-url <url>]

Renders the Better Homebrew formula template by replacing version and per-target
SHA256 placeholders from a release manifest.
USAGE
}

manifest=""
template=""
out=""
base_url=""

while [ "$#" -gt 0 ]; do
  case "$1" in
    --manifest)
      manifest="${2:-}"
      shift 2
      ;;
    --template)
      template="${2:-}"
      shift 2
      ;;
    --out)
      out="${2:-}"
      shift 2
      ;;
    --base-url)
      base_url="${2:-}"
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

if [ -z "$manifest" ] || [ -z "$template" ] || [ -z "$out" ]; then
  usage >&2
  exit 2
fi

if [ ! -f "$manifest" ] || [ ! -f "$template" ]; then
  echo "manifest and template must exist" >&2
  exit 1
fi

manifest_one_line="$(tr '\n' ' ' <"$manifest")"

manifest_value() {
  key="$1"
  block="$2"
  printf '%s\n' "$block" |
    sed -n "s/.*\"$key\"[[:space:]]*:[[:space:]]*\"\\([^\"]*\\)\".*/\\1/p"
}

manifest_version="$(manifest_value version "$manifest_one_line")"
if [ -z "$manifest_version" ]; then
  echo "manifest is missing version" >&2
  exit 1
fi

if [ -z "$base_url" ]; then
  base_url="https://github.com/logesh45/better-source-control/releases/download/v$manifest_version"
fi

sha_for_target() {
  target="$1"
  block="$(
    printf '%s\n' "$manifest_one_line" |
      grep -o "{[^{}]*\"target\"[[:space:]]*:[[:space:]]*\"$target\"[^{}]*}" |
      head -n 1
  )"
  manifest_value sha256 "$block"
}

tmp="$(mktemp)"
trap 'rm -f "$tmp"' EXIT

cp "$template" "$tmp"

replace() {
  placeholder="$1"
  value="$2"
  if [ -n "$value" ]; then
    escaped_value="$(printf '%s' "$value" | sed 's/[&|]/\\&/g')"
    sed -i.bak "s|$placeholder|$escaped_value|g" "$tmp"
    rm -f "$tmp.bak"
  fi
}

replace "__VERSION__" "$manifest_version"
replace "__BASE_URL__" "$base_url"
replace "__SHA256_AARCH64_APPLE_DARWIN__" "$(sha_for_target aarch64-apple-darwin)"
replace "__SHA256_X86_64_APPLE_DARWIN__" "$(sha_for_target x86_64-apple-darwin)"
replace "__SHA256_AARCH64_UNKNOWN_LINUX_GNU__" "$(sha_for_target aarch64-unknown-linux-gnu)"
replace "__SHA256_X86_64_UNKNOWN_LINUX_GNU__" "$(sha_for_target x86_64-unknown-linux-gnu)"

mkdir -p "$(dirname "$out")"
cp "$tmp" "$out"
