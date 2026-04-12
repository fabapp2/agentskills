# Agent Skills

Reusable AI agent skills for IDE assistants. Drop them into any project and your
agent (Windsurf Cascade, Codex, etc.) gains structured capabilities like fixing
bugs, checking OSS readiness, and more.

## Skills

<!-- SKILL_TABLE_START -->
| Skill | Description |
|---|---|
| [bugfix](skills/bugfix/) | Fix a bug in the code. |
| [check-oss-readiness](skills/check-oss-readiness/) | Check module or project for open source readiness and offers fixes to user (3 supporting files) |
<!-- SKILL_TABLE_END -->

Each skill lives in its own directory under `skills/`. The agent reads `SKILL.md`
when the skill is invoked. This table is auto-generated — see
[scripts/update-skill-table.sh](scripts/update-skill-table.sh).

## Quick start (curl)

Run this from your project root:

```bash
curl -fsSL https://raw.githubusercontent.com/promptics/agentskills/main/install.sh | bash
```

Pin to a specific release:

```bash
curl -fsSL https://raw.githubusercontent.com/promptics/agentskills/main/install.sh | bash -s v1.0.0
```

Then commit:

```bash
git add .agents/skills && git commit -m "Import agent-skills"
```

## Git subtree (recommended for your own repos)

Subtree keeps the skills as normal tracked files — no submodule init dance, and
`git clone` just works for all contributors.

```bash
# First import
git subtree add --prefix=.agents/skills \
  https://github.com/promptics/agentskills.git main --squash

# Update later
git subtree pull --prefix=.agents/skills \
  https://github.com/promptics/agentskills.git main --squash
```

Tip: add a Makefile target so the team doesn't have to remember the command:

```makefile
.PHONY: update-skills
update-skills:
	git subtree pull --prefix=.agents/skills \
	  https://github.com/promptics/agentskills.git main --squash
```

## Updating

- **Subtree users:** `git subtree pull` (or `make update-skills`)
- **Curl users:** re-run `install.sh`, review the diff, commit

Both methods support tags instead of `main` for version pinning.

## Compatibility

These skills work with any IDE agent that reads `.agents/skills/` directories:

- **Windsurf** — Cascade discovers skills automatically
- **Codex** — supports the `.agents/skills/` convention
- **Other agents** — any tool that can read Markdown skill files

## Related Resources

- [agentskills.io](https://agentskills.io/) — The official Agent Skills format documentation
- [agentskills.so](https://agentskills.so/) — Community platform for Agent Skills
- [agentskillsdb.com](https://www.agentskillsdb.com/) — Database of available Agent Skills
- [Anthropic Agent Skills](https://www.anthropic.com/engineering/equipping-agents-for-the-real-world-with-agent-skills) — Original spec and announcement from Anthropic

## Contributing

See [CONTRIBUTING.md](CONTRIBUTING.md) for how to add or improve skills, and
[DEVELOPER.md](DEVELOPER.md) for repo internals (hooks, CI, automation).

## License

Apache-2.0 — see [LICENSE](LICENSE).
