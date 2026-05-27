---
name: better-source-control
description: Use when a repo uses Better native source control for sessions, checkpoints, workspaces, release frontiers, or remotes.
---

# Better Source Control

Use Better as the source-control system. Git operations are optional bridge steps unless the repo's own instructions require them. This skill is self-contained for normal agent use; run command `--help` only for uncommon flags.

## Quick Start

Use the distributed `better` binary from `PATH`.

If Better is not installed, use the curl installer:

```bash
curl -fsSL https://raw.githubusercontent.com/logesh45/better-source-control/main/install.sh | bash
export PATH="$HOME/.local/bin:$PATH"   # only if the installer says this shell cannot see it
better --version
```

Homebrew users can install with:

```bash
brew tap logesh45/better-source-control https://github.com/logesh45/better-source-control
brew install logesh45/better-source-control/better
```

Use `better update` for curl installs. Use `brew upgrade better` for Homebrew installs.

```bash
better --json status
better --json release status
better changes
better --json context --task "short task" --file path/to/file --symbol SymbolName
```

Inspect `context` matches before duplicating work. `reuse_or_inspect` means inspect the checkpoint/replacement session first; `coordinate` means related active work exists.

For a new native repo, run `better init`. To migrate an existing Git repo:

```bash
better init
better --json import git            # imports HEAD as accepted frontier
better --json import git <ref>      # import another commit/ref
better --json import git --force    # replace an existing frontier
```

## Work Loop

```bash
better --json session start --task "short task" --owner agent:codex --file path/to/file --check "test command"
session=<returned-session-id>
better workspace create --session "$session"      # preferred for parallel work
# edit .better/workspaces/$session/ when using a workspace
better --json workspace status --session "$session"
better --json checkpoint --session "$session" --workspace --message "what changed"
```

Optional shell helper if `jq` is available: append `| jq -r '.id'` to the session start command.

For main-checkout edits, skip `--workspace` and run:

```bash
better changes --session "$session"
better session update "$session" --file newly/touched/file
better --json checkpoint --session "$session" --message "what changed"
```

Update claims before checkpointing. Git status is not enough for Better release composition.

## Release

```bash
better --json status
better compose --json
better --json release propose --message "release message"
better --json release accept <release-id> --by agent:codex
better restore frontier
```

If compose fails, fix the signal:

- `file_overlap` / `symbol_overlap`: reconcile or supersede.
- `stale_session`: refresh, redo/checkpoint, then supersede.
- missing checkpoint: checkpoint the active session.
- `broad_integration_provenance_risk`: compose workers directly; use narrow reconciliation/glue sessions. Use `--allow-degraded-provenance` only as a last resort and explain why.

## Remote

```bash
better remote status
better sync pull
better sync push
```

If no remote exists: `better remote init local --url http://127.0.0.1:8787`.
If push says `remote frontier advanced; pull first`, pull and inspect status; do not force-push.
First/high-history pushes can upload many reachable objects until bounded delta sync lands.

## Optional Git Bridge

Use only when the repo needs Git publishing or patch interoperability. Export from stored Better state, not from a branch:

```bash
better export git frontier --patch /tmp/better-frontier.patch
better export git release <release-id> --patch /tmp/better-release.patch
better export git working-tree --patch /tmp/better-worktree.patch
```

If the repo publishes through Git, commit the accepted Better frontier and then verify parity:

```bash
git add <files> && git commit -m "type: message"
better --json verify git-export --target HEAD
better --json export git frontier --patch /tmp/better-frontier.patch --verify
```

Before the Git commit, parity may fail because Better is ahead. After the commit, `tree_matches` should be `true`. If the repo does not require Git parity, skip the commit/verify steps.

## Optional Distribution Update

`better update` is distribution plumbing, not a source-control workflow step. Use it only when the installed Better binary itself needs updating. For curl-installed binaries:

```bash
better update --check
better update --dry-run
better update
```

Homebrew users should run `brew upgrade better`.

## Report Back

Include session id, checkpoint id, release id if accepted, remote result if used, verification commands, and any compose/remote signals.
