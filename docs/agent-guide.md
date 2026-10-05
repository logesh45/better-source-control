# Better Agent Guide

Use Better as the native source-control system. Git is only a bridge for import, export, or publishing when the human asks for it.

The canonical agent work loop is the `better-source-control` skill. Follow that skill after it is installed. This page does not duplicate the command loop.

## Follow The Skill

The packaged skill is:

```text
skills/better-source-control/SKILL.md
```

Install it with:

```bash
npx skills add logesh45/better-source-control
```

Then tell your agent:

```text
Use the better-source-control skill. Use Better sessions, checkpoints, context, compose, and release frontiers instead of Git branches for native source control.
```

The skill covers inspect/status/context, session claims, workspaces and checkpoints, compose, release frontiers, remotes, the optional Git bridge, and `better update`.

If a repository includes `AGENTS.md`, follow it for repo-specific verification or Git parity. Generic Better usage stays in the skill.
