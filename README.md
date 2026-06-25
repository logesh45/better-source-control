# Better Source Control

**A complete source-control system built for coding agents.**

Website: https://logesh45.github.io/better-source-control/

Better replaces branches and pull requests as the native coordination model for agent work. Import an existing Git repo, point your agent to the Better skill, let agents work through sessions and checkpoints, then export back to Git when you are ready.

Git stays useful as the migration and publishing bridge. Better becomes the coordination layer for agents working in parallel.

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

Verify the install:

```bash
better --version
better-remote --help
```

### Homebrew

Better also ships a Homebrew formula from this repository:

```bash
brew tap logesh45/better-source-control https://github.com/logesh45/better-source-control
brew install logesh45/better-source-control/better
```

### npm

npm packaging is coming soon. Until then, use the curl installer or Homebrew.

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

Before editing, agents should inspect current Better state and look for prior related work:

```bash
better --json status
better changes
better --json context --task "describe the task" --file path/to/file.rs --symbol SymbolName
```

Start a session and claim the files you expect to touch:

```bash
better --json session start \
  --task "describe the task" \
  --owner agent:codex \
  --file path/to/file.rs
session=<returned-session-id>
```

Use a native Better workspace for isolated parallel work:

```bash
better workspace create --session "$session"
# edit under .better/workspaces/$session/
better --json workspace status --session "$session"
better --json checkpoint --session "$session" --workspace --message "checkpoint message"
```

Check whether active sessions can compose:

```bash
better --json status
better compose --json
```

Accept the next release frontier:

```bash
better --json release propose --message "release message"
release=<returned-release-id>
better --json release accept "$release" --by agent:codex
better restore frontier
```

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

By default it starts `better-remote` on `http://127.0.0.1:8787` and stores data in a Docker volume.
To force a specific archive target, set `BETTER_TARGET`, for example:

```bash
BETTER_TARGET=aarch64-unknown-linux-gnu docker compose up -d --build
```

See `docker/README.md` for the build arguments and storage notes.

## Git Bridge

Use Git only when you need migration, interoperability, or publishing to an existing Git remote:

```bash
better import git
better export git frontier --patch /tmp/better-frontier.patch
better verify git-export
```

Better's accepted release frontier is the native source of truth. Git patches and commits are bridge artifacts.

## Status

Better is early software. It is ready for experimentation by agent-heavy development teams, but the storage and sync protocol should still be treated as evolving.

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

Better is released under the MIT License.
