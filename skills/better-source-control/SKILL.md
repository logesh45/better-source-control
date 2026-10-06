---
name: better-source-control
description: Install and use Better for agent-native source control, parallel sessions, checkpoints, release frontiers, and remote sync.
---

# Better Source Control

Use Better as the source-control system. Git operations are optional bridge steps unless the repo's own instructions require them. This skill is self-contained for normal agent use; run command `--help` only for uncommon flags.

## Quick Start

Use the distributed `better` binary, not a source checkout or debug build. Check `better --version` first. If missing, install it before running the work loop; respect the environment's software-installation permissions.

On macOS/Linux (requires curl and bash):

```bash
curl -fsSL https://raw.githubusercontent.com/logesh45/better-source-control/main/install.sh -o /tmp/better-install.sh
bash /tmp/better-install.sh
export PATH="$HOME/.local/bin:$PATH"
better --version
```

The public main installer selects the release; do not hard-code a version. It installs `better` and `better-remote` in `$HOME/.local/bin` by default. The export affects only this shell: do not edit shell startup files silently. If installed but absent from PATH, use `$HOME/.local/bin/better` or the shell-local export, rather than reinstalling. Do not disable checksum checks or TLS validation. On Windows, use the Windows instructions/assets at https://betterforagents.com/install/; the bash installer is not a native PowerShell installer. If installation is blocked, report the precise blocker rather than trying source builds.

For a repository without `.better/`, initialize it or import its Git snapshot as described below. For an existing repository, inspect state before changing it:

```bash
better --json status
better --json release status
better changes
better --json context --task "short task" --file path/to/file --symbol SymbolName
```

Default `better --json status` is live coordination. Use `--all --limit <n>` with `pagination.sessions.next_after` for historical session inventory; use `better history log --limit <n>` for chronology. `coordination_clear` still requires `better compose` before release.

Inspect `context` matches before duplicating work. `reuse_or_inspect` means inspect the checkpoint/replacement session first; `coordinate` means related active work exists.

For a new native repo, run `better init`. To migrate an existing Git repo:

```bash
better init
better --json import git            # imports HEAD as accepted frontier
better --json import git <ref>      # import another commit/ref
better --json import git --adopt-upstream  # adopt current Git HEAD after pulling/rebasing upstream
```

Use `--adopt-upstream` only after a pull/rebase when the current Better frontier is already the latest Git-imported/adopted frontier or already matches Git `HEAD`. It preserves previous Better releases, refuses native-only frontier work, and only accepts `HEAD` as the ref.

## Work Loop

```bash
better --json session start --task "short task" --owner agent:codex --file path/to/file --check "test command"
session=<returned-session-id>
better workspace create --session "$session"      # preferred for parallel work
# edit .better/workspaces/$session/ when using a workspace
better --json workspace status --session "$session"
better --json checkpoint --session "$session" --workspace --message "what changed"
```

By default, `workspace_cleanup = "on_release_accept"` reclaims a clean, exact-pinned workspace after local release acceptance. Stop writing before acceptance. Uncheckpointed source changes and unverifiable state are preserved; ignored files are removed with an otherwise eligible workspace, so keep valuable `.env`-style files outside the workspace. Set top-level `workspace_cleanup = "off"` in `.better/policy.toml` to opt out. Use `better workspace gc --dry-run` to preview cleanup, `better workspace gc` to reclaim eligible workspaces or retry residue, and `better doctor` to inspect remaining cleanup issues.

Optional shell helper if `jq` is available: append `| jq -r '.id'` to the session start command.

For main-checkout edits, skip `--workspace` and run:

```bash
better changes --session "$session"
better session update "$session" --file newly/touched/file
better --json checkpoint --session "$session" --message "what changed"
```

Update claims before checkpointing. Git status is not enough for Better release composition. Run the actual test/check commands before checkpointing: `--check` records intent, not test execution. Each subagent owns its own session and workspace; compose those worker checkpoints directly, never replace their provenance with a catch-all parent session. A workspace starts from the accepted frontier, not arbitrary uncheckpointed checkout edits.

## Inspect and Restore

```bash
better history log --limit 20
better restore checkpoint <checkpoint-id> --dry-run
better restore release <release-id> --dry-run
better restore frontier --dry-run
```

Use full returned IDs, not invented short names. A dry-run reports planned filesystem changes, not checkpoint source contents or test results. Inspect saved code in a safe checkout before deciding to reuse it. Actual restore omits `--dry-run` and changes files in the current checkout; protect unrelated edits first. Absent paths are preserved by default. Use `--delete-absent` only for intentional removal and `--force` only after reviewing why protection blocked the restore. Never repair state by editing SQLite or object files directly.

For optional semantic/graph context: `better index scan`, `better graph status`, and `better daemon scan`. These advisory indexes do not replace saved checkpoints, tests, or the accepted frontier.

## Session Cleanup

```bash
better session abandon <session-id> --reason "discarded approach"
```

Use `abandon` when work is intentionally discarded. Use `supersede` when a checkpointed replacement owns the work, and use `refresh` when continuing stale work from the current frontier. Abandonment releases active claims but preserves the session, checkpoints, operation history, workspace, files, and stored objects for inspection. It does not delete a workspace or files, and `missing_claimed_path` remains strict for active sessions. Syncing abandoned sessions requires Better v0.1.0 or later on both peers.

## Release

```bash
better --json status
better compose --json
better --json release propose --message "release message"
better --json release accept <release-id> --by agent:codex
better restore frontier
```

In a fresh workspace-only repository, the main checkout may still lack the newly accepted files. If restore reports uncheckpointed changes, review `better restore frontier --dry-run` and the checkout first. Only when the accepted frontier is the intended state and no unrelated edits need preserving, use `better restore frontier --force`.

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

For a new remote repository: `better remote init local --url <remote-url>`. For another checkout of an existing remote, initialize Better and reuse the source repository's `repo_id` from `.better/remotes/<name>.toml`:

```bash
better init
better remote init local --url <remote-url> --repo-id <source-repo-id>
better sync pull
better restore frontier --dry-run
better restore frontier
```

Do not omit `--repo-id` when joining an existing repository. Pull imports stored state; restore materializes its accepted frontier. Configure authentication with `--credential-env <ENV_VAR>` when required; never commit bearer credentials. Self-hosting setup: https://betterforagents.com/remote/.
If push says `remote frontier advanced; pull first`, pull and inspect status; do not force-push.
First/high-history pushes can still upload many reachable objects. Sync uses bounded missing-object negotiation, separate object upload, progress output, and metadata deltas when the remote supports them.

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

If Git remains the public upstream and new Git commits arrive outside Better, run `better --json import git --adopt-upstream` before starting new Better-native sessions when the current Better frontier is still the latest Git-imported/adopted frontier or already matches Git `HEAD`. This records Git `HEAD` as an accepted Better frontier without rewriting the checkout or erasing earlier Better releases. If Better has native-only frontier work, export/commit/reconcile that work first.

## Optional Distribution Update

`better update` is distribution plumbing, not a source-control workflow step. Use it only when the installed Better binary itself needs updating. For curl-installed binaries:

```bash
better update --check
better update --dry-run
better update
```

Homebrew users should run `brew upgrade better`.

Managed daemon handoff during `better update` is automatic when Better can classify the repository daemon as managed. `better update --check`, `better update --dry-run`, and `better --version` do no daemon lifecycle work. The first upgrade from legacy `v0.1.2` may fail closed and emit an exact `better daemon run` recovery command.

Preserved `v0.1.2` must update before sync against current remotes. Migrated schema-v2 repositories reject incompatible old binaries locally before network access. Do not downgrade or reset their metadata to bypass that guard.

## Report Back

Include session id, checkpoint id, release id if accepted, remote result if used, verification commands, and any compose/remote signals.
