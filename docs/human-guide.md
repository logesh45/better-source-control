# Better Human Guide

Better is source control for teams that run coding agents in parallel. Humans still decide what ships, but agents get native coordination primitives: sessions, checkpoints, context lookup, compose checks, and accepted release frontiers.

Use this guide when you are setting up Better in a project, reviewing agent work, or operating a Better remote.

## Install

Install the latest release:

```bash
curl -fsSL https://raw.githubusercontent.com/logesh45/better-source-control/main/install.sh | bash
```

If the installer says `$HOME/.local/bin` is not visible to this shell, add it yourself:

```bash
export PATH="$HOME/.local/bin:$PATH"
```

Homebrew users can install with:

```bash
brew tap logesh45/better-source-control https://github.com/logesh45/better-source-control
brew install logesh45/better-source-control/better
```

Verify the install:

```bash
better --version
better-remote --help
```

## Add The Agent Skill

Install the Better skill so your coding agent knows how to use Better without searching for instructions:

```bash
npx skills add logesh45/better-source-control
```

Install globally or target a specific agent when useful:

```bash
npx skills add logesh45/better-source-control -g
npx skills add logesh45/better-source-control -g --agent claude-code
npx skills add logesh45/better-source-control -g --agent codex
npx skills add logesh45/better-source-control -g --agent windsurf
npx skills add logesh45/better-source-control -g --agent cursor
```

Then tell your agent:

```text
Use the better-source-control skill. Use Better sessions, checkpoints, context, compose, and release frontiers instead of Git branches for native source control.
```

## Start A Project

For a new project:

```bash
better init
better doctor
```

For an existing Git repository:

```bash
better init
better import git
better status
```

`better import git` records the current Git `HEAD` as the accepted Better frontier. After that, agents should work through Better sessions and checkpoints.

## Human Review Loop

Before assigning work, check the current coordination state:

```bash
better status
better changes
better release status
```

Ask Better what related work already exists:

```bash
better context --task "describe the work" --file path/to/file.rs --symbol SymbolName
```

Review active sessions:

```bash
better status
better compose --json
```

If compose is clean, propose and accept the next release frontier:

```bash
better release propose --message "describe the release"
better release accept <release-id> --by human:<name>
better restore frontier
```

`better restore frontier` updates the checkout to match the accepted Better frontier.

## Session Cleanup

```bash
better session abandon <session-id> --reason "discarded approach"
```

Use `abandon` when a review determines the work is intentionally discarded. Use `supersede` when a checkpointed replacement owns the work, and use `refresh` when an agent should continue stale work from the current frontier. Abandonment releases active claims but preserves the session, checkpoints, operation history, workspace, files, and stored objects for inspection. It does not delete a workspace or files, and `missing_claimed_path` remains strict for active sessions. Syncing abandoned sessions requires Better v0.1.0 or later on both peers.

## Working With Git

Git is the compatibility bridge, not the native coordination model.

Import from Git:

```bash
better import git
```

If you pull Git commits that were created outside Better, adopt the new Git `HEAD` before more native Better work:

```bash
git pull --ff-only
better import git --adopt-upstream
better verify git-export --target HEAD
```

Export the accepted Better frontier when you need to publish through Git:

```bash
better export git frontier --patch /tmp/better-frontier.patch
better verify git-export
```

Apply or commit the exported change in your Git workflow as needed.

## Remote Sync

`better-remote` stores Better objects, metadata, and frontier state.

Start a local remote:

```bash
better-remote --bind 127.0.0.1:8787 --storage-root .better-remote
```

Configure a repo and sync:

```bash
better remote init local --url http://127.0.0.1:8787
better sync push
better sync pull
```

If push reports that the remote frontier advanced, pull first and reconcile instead of overwriting the remote.

Docker Compose is also available:

```bash
docker compose up -d --build
```

See [docker/README.md](../docker/README.md).

## Verify Downloads

Manual downloads should be checked with both checksums and provenance metadata:

```bash
shasum -a 256 -c SHA256SUMS
cat better-0.1.0-aarch64-apple-darwin.provenance.json
cat SHA256SUMS.provenance.json
```

Use the artifact name for your platform and release version. The provenance JSON records the artifact SHA-256, source commit, workflow, run id, version, and target.

## Troubleshooting

Start with:

```bash
better doctor
better status
better changes
better remote status
```

Useful issue reports include your operating system, architecture, `better --version`, the command that failed, and the full error output.
