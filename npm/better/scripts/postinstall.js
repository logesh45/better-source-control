#!/usr/bin/env node

const { spawnSync } = require("node:child_process");
const fs = require("node:fs");
const path = require("node:path");

const nativePackages = {
  "darwin-arm64": { packageName: "@better-scm/better-darwin-arm64", binary: "better" },
  "darwin-x64": { packageName: "@better-scm/better-darwin-x64", binary: "better" },
  "linux-arm64": { packageName: "@better-scm/better-linux-arm64", binary: "better" },
  "linux-x64": { packageName: "@better-scm/better-linux-x64", binary: "better" },
  "win32-x64": { packageName: "@better-scm/better-win32-x64", binary: "better.exe" }
};

function resolvePaths() {
  return [process.env.INIT_CWD, process.cwd(), __dirname].filter(Boolean);
}

function selectedNativePackage() {
  return nativePackages[`${process.platform}-${process.arch}`];
}

function resolveNativeBinary() {
  if (process.env.BETTER_BINARY_PATH) {
    return process.env.BETTER_BINARY_PATH;
  }

  const platformPackage = selectedNativePackage();
  if (!platformPackage) {
    return null;
  }

  try {
    const packageJson = require.resolve(`${platformPackage.packageName}/package.json`, {
      paths: resolvePaths()
    });
    return path.join(path.dirname(packageJson), "bin", platformPackage.binary);
  } catch {
    return null;
  }
}

const binaryPath = resolveNativeBinary();
if (!binaryPath || !fs.existsSync(binaryPath)) {
  const platformPackage = selectedNativePackage();
  const installHint = platformPackage
    ? `npm install ${platformPackage.packageName}`
    : "npm install @better-scm/better-<platform>-<arch> or set BETTER_BINARY_PATH to a compatible Better binary";

  console.error("Unable to find a Better native binary for this installation.");
  console.error(`Detected platform: ${process.platform}-${process.arch}.`);
  console.error(`Set BETTER_BINARY_PATH or run ${installHint}.`);
  process.exit(1);
}

const result = spawnSync(binaryPath, ["--version"], { encoding: "utf8" });
if (result.error || result.status !== 0) {
  const detail = result.error ? result.error.message : result.stderr;
  console.error("Unable to verify Better after install with better --version.");
  console.error(String(detail || "").trim());
  process.exit(1);
}
