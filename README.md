# Agent Skills

[Agent Skills](https://agentskills.io) are a simple, open format for giving agents new capabilities and expertise.

Skills are folders of instructions, scripts, and resources that agents can discover and use to perform better at specific tasks. Write once, use everywhere.

## Getting Started

- **[Documentation](https://agentskills.io)** — Guides and tutorials
- **[Specification](https://agentskills.io/specification)** — Format details
- **[Example Skills](https://github.com/anthropics/skills)** — See what's possible
- **[Discord](https://discord.gg/MKPE9g8aUy)** — Join the discussion!

This repo contains the specification, documentation, and reference SDK. Also see a list of example skills [here](https://github.com/anthropics/skills).

## Install Slash Commands

This repo ships ready-to-use Claude Code slash commands under `commands/`. To install them into a project, copy (or symlink) the command directory into the project's `.claude/commands/`.

From the root of the project where you want to use the commands:

```bash
mkdir -p .claude/commands

# Install the code-review command (available as /code-review:review)
cp -r /path/to/agentskills/commands/code-review .claude/commands/

# Install the repo-cleanup-audit command (available as /repo-cleanup-audit:audit)
cp -r /path/to/agentskills/commands/repo-cleanup-audit .claude/commands/

# Install the github-issue-delivery command (available as /github-issue-delivery:deliver-issue)
cp -r /path/to/agentskills/commands/github-issue-delivery .claude/commands/
```

To track upstream updates, symlink instead of copying:

```bash
ln -s /path/to/agentskills/commands/code-review          .claude/commands/code-review
ln -s /path/to/agentskills/commands/repo-cleanup-audit   .claude/commands/repo-cleanup-audit
ln -s /path/to/agentskills/commands/github-issue-delivery .claude/commands/github-issue-delivery
```

See each command's `README.md` (e.g. [`commands/code-review/README.md`](commands/code-review/README.md)) for usage details and how to expose the bare command name (e.g. `/review` instead of `/code-review:review`).

## About

Agent Skills is an open format maintained by [Anthropic](https://anthropic.com) and open to contributions from the community.

## License

Code in this repository is licensed under [Apache 2.0](LICENSE). Documentation is licensed under [CC-BY-4.0](https://creativecommons.org/licenses/by/4.0/). See individual directories for details.
