# Better Agent Guide

Use Better as the native source-control system for this project. Git is only a bridge for import, export, or publishing when the human asks for it.

This guide assumes the `better-source-control` skill is installed. Follow the skill first when it is available; use this page as the public release-repo reference.

## First Checks

Before editing, inspect Better state and prior related work:

```bash
better --json status
better --json release status
better changes
better --json context --task "short task description" --file path/to/file --symbol SymbolName
```

Read the context result. If Better returns `reuse_or_inspect`, inspect the referenced checkpoint or replacement session before duplicating the work. If it returns `coordinate`, related active work exists and you should avoid touching the same surface blindly.

## Start A Session

Create a session with a clear task and accurate file claims:

```bash
better --json session start \
  --task "short task description" \
  --owner agent:<name> \
  --file path/to/file
```

Keep the returned session id.

If you later touch more files, update the claim before checkpointing:

```bash
better session update <session-id> --file path/to/other-file
```

## Prefer Workspaces

For isolated parallel work, create a Better workspace:

```bash
better workspace create --session <session-id>
```

Edit files under:

```text
.better/workspaces/<session-id>/
```

Check workspace changes:

```bash
better --json workspace status --session <session-id>
```

After local release acceptance, Better automatically reclaims each completed isolated workspace that is clean and exact-pinned by default. Stop writing before acceptance. Uncheckpointed source changes and unverifiable state are preserved, but ignored files are removed with an otherwise eligible workspace; keep valuable `.env`-style files outside the workspace. Set `workspace_cleanup = "off"` at the top level of `.better/policy.toml` to opt out. Use `better workspace gc --dry-run` to preview candidates and `better workspace gc` to reclaim them or retry cleanup residue.

Checkpoint workspace work:

```bash
better --json checkpoint \
  --session <session-id> \
  --workspace \
  --message "what changed"
```

## Main-Checkout Edits

If you edit the main checkout directly, checkpoint without `--workspace`:

```bash
better changes --session <session-id>
better --json checkpoint --session <session-id> --message "what changed"
```

If `better changes` reports unclaimed files, update the session claim first.

## Before Integration

Run the project checks the human or repo instructions require. Better records check metadata, but it does not replace actually running the commands.

Then check composition:

```bash
better --json status
better compose --json
```

If compose fails:

- file or symbol overlap: coordinate, reconcile, or supersede overlapping work.
- stale session: refresh from the current frontier, redo or restore the needed work, checkpoint again, then supersede the stale session.
- missing checkpoint: create a checkpoint.
- broad integration provenance risk: prefer composing worker sessions directly. Use a narrow glue session only for true glue files.

## Session Cleanup

```bash
better session abandon <session-id> --reason "discarded approach"
```

Use `abandon` when work is intentionally discarded. Use `supersede` when a checkpointed replacement owns the work, and use `refresh` when continuing stale work from the current frontier. Abandonment releases active claims but preserves the session, checkpoints, operation history, workspace, files, and stored objects for inspection. It does not delete a workspace or files, and `missing_claimed_path` remains strict for active sessions. Syncing abandoned sessions requires Better v0.1.0 or later on both peers.

## Release Frontier

When compose is clean and the human wants the work accepted:

```bash
better --json release propose --message "release message"
better --json release accept <release-id> --by agent:<name>
better restore frontier
```

Report the session id, checkpoint id, release id, checks run, and any compose signals.

## Remote Sync

If a Better remote is configured:

```bash
better remote status
better sync pull
better sync push
```

If push says the remote frontier advanced, pull and inspect Better status before continuing. Do not force remote state.

## Git Bridge

Use Git only when requested for migration or publishing.

Import current Git `HEAD` into a new Better repo:

```bash
better init
better --json import git
```

Adopt upstream Git changes after a pull or rebase when Better has no native-only frontier work:

```bash
better --json import git --adopt-upstream
better --json verify git-export --target HEAD
```

Export the accepted Better frontier as a Git patch:

```bash
better export git frontier --patch /tmp/better-frontier.patch
better verify git-export
```

If the repo's own instructions require Git parity, commit the accepted Better frontier through Git and run:

```bash
better --json verify git-export --target HEAD
```

Otherwise, skip Git and stay native to Better.

## Report Back

End with the concrete evidence:

- session id
- checkpoint id
- release id, if accepted
- remote sync result, if used
- verification commands and outcomes
- any remaining Better signals or risks
