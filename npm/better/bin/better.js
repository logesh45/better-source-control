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

function resolveNativeBinary() {
  if (process.env.BETTER_BINARY_PATH) {
    return process.env.BETTER_BINARY_PATH;
  }

  const platformPackage = nativePackages[`${process.platform}-${process.arch}`];
  if (!platformPackage) {
    throw new Error(`Unsupported Better platform: ${process.platform}-${process.arch}`);
  }

  const packageJson = require.resolve(`${platformPackage.packageName}/package.json`, {
    paths: resolvePaths()
  });
  return path.join(path.dirname(packageJson), "bin", platformPackage.binary);
}

function main() {
  let binaryPath;
  try {
    binaryPath = resolveNativeBinary();
  } catch (error) {
    console.error(error.message);
    console.error("Set BETTER_BINARY_PATH to a local Better binary or install the matching native optional dependency.");
    process.exit(1);
  }

  if (!fs.existsSync(binaryPath)) {
    console.error(`Better binary not found at ${binaryPath}`);
    console.error("Set BETTER_BINARY_PATH to a local Better binary or reinstall @better-scm/better.");
    process.exit(1);
  }

  const result = spawnSync(binaryPath, process.argv.slice(2), { stdio: "inherit" });
  if (result.error) {
    console.error(`Failed to run Better binary at ${binaryPath}: ${result.error.message}`);
    process.exit(1);
  }

  process.exit(result.status ?? 0);
}

main();
