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

This repo ships ready-to-use Claude Code slash commands under `commands/`. The snippets below pull each command directly from GitHub into the current project's `.claude/commands/` — run them from your project root, no edits required.

Install all bundled commands:

```bash
mkdir -p .claude/commands
curl -L https://github.com/fabapp2/agentskills/archive/refs/heads/main.tar.gz \
  | tar -xz --strip-components=2 -C .claude/commands \
      agentskills-main/commands/code-review \
      agentskills-main/commands/repo-cleanup-audit \
      agentskills-main/commands/github-issue-delivery
```

Or install a single command (pick the one you want):

```bash
# code-review (available as /code-review:review)
mkdir -p .claude/commands && curl -L https://github.com/fabapp2/agentskills/archive/refs/heads/main.tar.gz \
  | tar -xz --strip-components=2 -C .claude/commands agentskills-main/commands/code-review

# repo-cleanup-audit (available as /repo-cleanup-audit:audit)
mkdir -p .claude/commands && curl -L https://github.com/fabapp2/agentskills/archive/refs/heads/main.tar.gz \
  | tar -xz --strip-components=2 -C .claude/commands agentskills-main/commands/repo-cleanup-audit

# github-issue-delivery (available as /github-issue-delivery:deliver-issue)
mkdir -p .claude/commands && curl -L https://github.com/fabapp2/agentskills/archive/refs/heads/main.tar.gz \
  | tar -xz --strip-components=2 -C .claude/commands agentskills-main/commands/github-issue-delivery
```

See each command's `README.md` (e.g. [`commands/code-review/README.md`](commands/code-review/README.md)) for usage details and how to expose the bare command name (e.g. `/review` instead of `/code-review:review`).

## About

Agent Skills is an open format maintained by [Anthropic](https://anthropic.com) and open to contributions from the community.

## License

Code in this repository is licensed under [Apache 2.0](LICENSE). Documentation is licensed under [CC-BY-4.0](https://creativecommons.org/licenses/by/4.0/). See individual directories for details.
