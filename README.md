# Better Source Control

**A complete source-control system built for coding agents.**

Website: https://betterforagents.com/

Better replaces branches and pull requests as the native coordination model for agent work. Import an existing Git repo, point your agent to the Better skill, let agents work through sessions and checkpoints, then export back to Git when you are ready.

Git stays useful as the migration and publishing bridge. Better becomes the coordination layer for agents working in parallel.

## Guides

Start here depending on who is doing the work:

- [Human guide](docs/human-guide.md): install Better, initialize a project, understand the workflow, and operate remotes.
- [Agent guide](docs/agent-guide.md): points agents at the Better skill (and repo `AGENTS.md` when present) instead of duplicating the command loop.

## Why Better?

Modern coding agents can run in parallel, but Git's default collaboration model still asks them to coordinate through branches, commits, merges, and PRs. That works for humans. It creates avoidable conflict, duplicate work, and lost context when many agents are active.

Better gives agents source-control primitives designed for that world:

- sessions for scoped agent work
- checkpoints as native save points
- workspaces for isolated parallel changes
- context lookup across files, symbols, sessions, and checkpoints
- compose checks before integration
- accepted release frontiers
- Git import/export when you need compatibility

Completed isolated workspaces are reclaimed after local release acceptance, keeping projects tidy while preserving uncheckpointed source changes. Agents should stop writing before acceptance. Non-ignored changes and unverifiable workspace state are preserved; ignored files are removed with an otherwise eligible workspace, so valuable `.env`-style files should not live only in a workspace. Set the top-level `workspace_cleanup = "off"` key in `.better/policy.toml` before any signal tables to opt out. You can preview cleanup with `better workspace gc --dry-run` and run it explicitly with `better workspace gc`.

## Built For Parallel Subagents

The core difference is that Better lets agents ask source control for context before they duplicate work:

- Who is working on this file or symbol?
- Was similar work checkpointed before?
- Was that previous attempt superseded?
- Is there a checkpoint from an earlier session that should be reused?
- Can these active sessions compose safely into the next release frontier?

Instead of every agent starting from a blank `git status` view, an agent can inspect related sessions and checkpoints, bring back past work when useful, restore or reuse a prior checkpoint, or coordinate before touching the same surface area.

That is the coordination layer Git was not designed to provide for many agents working in parallel.

## Use It With Git

Better is designed to meet existing repos where they are:

```bash
better init
better import git
```

Then point your agent to the Better skill and let it take over:

```bash
npx skills add logesh45/better-source-control
```

When you are ready to publish through Git again:

```bash
better export git frontier --patch /tmp/better-frontier.patch
better verify git-export
```

Hosted remote sync is coming soon. You can self-host `better-remote` today.

## Install

Install the latest release with the curl installer:

```bash
curl -fsSL https://raw.githubusercontent.com/logesh45/better-source-control/main/install.sh | bash
```

The installer places `better` and `better-remote` in `$HOME/.local/bin` by default. If that directory is not on your `PATH`, the installer prints the export command to add it. It does not modify your shell startup files.

On Windows, use the PowerShell installer:

```powershell
irm https://raw.githubusercontent.com/logesh45/better-source-control/main/install.ps1 | iex
```

The installer places `better.exe` and `better-remote.exe` in `%USERPROFILE%\.local\bin` by default. If that directory is not on your `PATH`, the installer prints the directory to add, then restart the terminal.

Verify the install:

```bash
better --version
better-remote --help
```

Current stable release: **v0.5.0**. See the [v0.5.0 release](https://github.com/logesh45/better-source-control/releases/tag/v0.5.0) for highlights and downloadable artifacts.

## Verify Release Integrity

Every release publishes `SHA256SUMS`, `manifest.json`, and provenance JSON files for the platform archives plus release metadata.

If you download artifacts manually, verify the checksum first:

```bash
shasum -a 256 -c SHA256SUMS
```

Then inspect the provenance file for the artifact you downloaded:

```bash
cat better-<version>-<target>.provenance.json
cat SHA256SUMS.provenance.json
cat manifest.provenance.json
```

Use the artifact name for your platform and release version. Each provenance file records the artifact SHA-256, source commit, workflow, run id, version, and target that produced the asset.

### Homebrew

Better also ships a Homebrew formula from this repository:

```bash
brew tap logesh45/better-source-control https://github.com/logesh45/better-source-control
brew install logesh45/better-source-control/better
```

### npm

npm packaging is coming soon. Until then, use the curl installer or Homebrew.

### Update

Curl-installed users can check for or install a newer release with:

```bash
better update --check
better update
```

Homebrew users should update through Homebrew:

```bash
brew update
brew upgrade better
```

Release builds check the stable update manifest at most once per day after successful eligible commands. A newer version produces a short notice; Better never installs an update automatically. Managed daemons are handed off during `better update`, with retained binary backups and recovery guidance if the replacement cannot start. Set `BETTER_UPDATE_CHECK=off` in ephemeral CI or agent containers to disable the periodic check.

## Start A New Better Repo

Create an empty Better repository:

```bash
better init
better doctor
```

Import an existing Git repository as the initial Better frontier:

```bash
better init
better import git
better status
```

`better import git` imports the current Git `HEAD` as an accepted Better release frontier. After that, agents can work through Better sessions and checkpoints.

If Git is still the public upstream and you pull or rebase commits that were not created from your local Better frontier, adopt the new Git `HEAD` before starting more Better-native work:

```bash
git pull --ff-only
better import git --adopt-upstream
better verify git-export --target HEAD
```

`--adopt-upstream` preserves previous Better releases, records Git `HEAD` as the current accepted frontier, and refuses to overwrite native-only Better frontier work. Use it only when your current Better frontier is already the latest Git-imported/adopted frontier or already matches Git `HEAD`; otherwise export, commit, or reconcile the Better work first.

## Give Your Agent The Better Skill

This repo includes a drop-in agent skill at:

```text
skills/better-source-control/SKILL.md
```

The easiest path is the Vercel Skills CLI:

```bash
npx skills add logesh45/better-source-control
```

That installs the packaged `better-source-control` skill into the current project or detected agent environment. Use these options when you want more control.

Install globally:

```bash
npx skills add logesh45/better-source-control -g
```

Install into a specific agent:

```bash
npx skills add logesh45/better-source-control -g --agent claude-code
npx skills add logesh45/better-source-control -g --agent codex
npx skills add logesh45/better-source-control -g --agent windsurf
npx skills add logesh45/better-source-control -g --agent cursor
```

Install into several agents at once:

```bash
npx skills add logesh45/better-source-control -g \
  --agent claude-code codex windsurf cursor
```

Other agent targets supported by the Skills CLI include Gemini CLI, Qwen Code, opencode, Amp, Claude Desktop, VS Code, Warp, Zed, Roo Code, Kilo Code, LM Studio, and more. Run `npx skills --help` to see the current options, or use `--agent '*' -g` to install into every detected supported agent.

Check or update installed skills:

```bash
npx skills list -g
npx skills update better-source-control
```

Manual install for Claude Code:

```bash
mkdir -p ~/.claude/skills/better-source-control
curl -fsSL \
  https://raw.githubusercontent.com/logesh45/better-source-control/main/skills/better-source-control/SKILL.md \
  -o ~/.claude/skills/better-source-control/SKILL.md
```

Manual install for Codex:

```bash
mkdir -p ~/.codex/skills/better-source-control
curl -fsSL \
  https://raw.githubusercontent.com/logesh45/better-source-control/main/skills/better-source-control/SKILL.md \
  -o ~/.codex/skills/better-source-control/SKILL.md
```

Manual install for Windsurf:

```bash
mkdir -p .windsurf/skills/better-source-control
curl -fsSL \
  https://raw.githubusercontent.com/logesh45/better-source-control/main/skills/better-source-control/SKILL.md \
  -o .windsurf/skills/better-source-control/SKILL.md
```

Cursor also supports Agent Skills in the editor and CLI. Prefer `npx skills add ... --agent cursor` for Cursor so the skill lands in the location expected by your installed Cursor version.

For other agents, prefer `npx skills add ... --agent <name>` when supported. If your tool does not support skills yet, add the same `SKILL.md` content to its project or global instruction system.

Then tell your agent:

```text
Use the better-source-control skill. Use Better sessions, checkpoints, context, compose, and release frontiers instead of Git branches for native source control.
```

## Agent Workflow

The canonical agent work loop is the Better skill, not this README:

```text
skills/better-source-control/SKILL.md
```

Install that skill, then follow it for status, context, sessions, workspaces, checkpoints, compose, release, remotes, and session cleanup. If a repository includes `AGENTS.md`, follow it for repo-specific Git parity or verification; the skill remains the shared Better loop. See the [agent guide](docs/agent-guide.md) for the public pointer and the [human guide](docs/human-guide.md) for install, review, remotes, and SeaweedFS/S3.

## Native Remote Sync

`better-remote` is the native remote service. It stores Better objects, metadata, and release frontier state.

Start a local remote service:

```bash
better-remote --bind 127.0.0.1:8787 --storage-root .better-remote
```

Configure a repo and sync:

```bash
better remote init local --url http://127.0.0.1:8787
better sync push
better sync pull
```

If push reports that the remote frontier advanced, pull first and reconcile instead of overwriting remote state.

### Optional Docker Compose

If you want to self-host the remote service in a container, this repository also includes a Docker Compose setup:

```bash
docker compose up -d --build
```

`docker compose up -d --build` is filesystem storage. For single-node SeaweedFS S3 storage, set `SEAWEEDFS_ACCESS_KEY` and `SEAWEEDFS_SECRET_KEY`, then add `-f docker-compose.seaweedfs.yml`. See [setup, backups, and migration](docker/README.md#single-node-seaweedfs). For external S3 add `-f docker-compose.s3.yml` with `BETTER_REMOTE_S3_*` set.
To force a specific archive target, set `BETTER_TARGET`, for example:

```bash
BETTER_TARGET=aarch64-unknown-linux-gnu docker compose up -d --build
```

See `docker/README.md` for the build arguments and storage notes.

## Git Bridge

Use Git only when you need migration, interoperability, or publishing to an existing Git remote:

```bash
better import git
better import git --adopt-upstream
better export git frontier --patch /tmp/better-frontier.patch
better verify git-export
```

Better's accepted release frontier is the native source of truth. Git patches and commits are bridge artifacts.

## Status

Better v0.5.0 is the current stable release. Self-hosted `better-remote` can use filesystem storage or an S3-compatible object store, with Compose examples for local SeaweedFS and external S3. The hosted remote service is still forthcoming.

## Report Issues

Please report bugs, confusing workflows, and release/install problems through GitHub Issues:

```text
https://github.com/logesh45/better-source-control/issues
```

Useful reports include:

- operating system and architecture
- `better --version`
- command that failed
- error output
- whether the repo was new, imported from Git, or synced from a Better remote

## License

Better is dual-licensed under MIT OR Apache-2.0.
