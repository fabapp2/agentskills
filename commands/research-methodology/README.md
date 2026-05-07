# research-methodology

A Claude Code slash command that runs a structured **research session** on
a topic and produces a cited, self-contained report. Every load-bearing
claim is cross-checked, every source is recorded with a verbatim quote,
and the final artifact is **registered in `AGENT.md`** so future agents
working in the same repository can discover and reuse the research.

It is intentionally **domain-agnostic**. It works for technical
investigations (library comparison, protocol behavior, performance
claims), policy/compliance questions, market or vendor research, and
anything else where the user needs an evidence trail rather than a
confident-sounding summary.

## Layout

```
research-methodology/
├── README.md                       ← you are here
├── PROCEDURE.md                    ← canonical, agent-neutral procedure
├── research.md                     ← Claude Code slash command wrapper
├── research-notes-template.md      ← working notes structure
└── final-report-template.md        ← required final-artifact structure
```

## Install for Claude Code

Installation is two steps. **Step 1 is required**; step 2 is optional and
only changes the command name from `/research-methodology:research` to the
bare `/research`.

### Step 1 (required) — install the directory

```bash
# From the root of the project where you want to use the command:
mkdir -p .claude/commands
cp -r /path/to/this/research-methodology .claude/commands/

# Or, if you want to track upstream updates, symlink instead:
ln -s /path/to/this/research-methodology .claude/commands/research-methodology
```

After this step the command is available as
`/research-methodology:research`.

### Step 2 (optional) — bare command name

```bash
ln -s research-methodology/research.md .claude/commands/research.md
```

This requires step 1, since the wrapper references files under
`.claude/commands/research-methodology/`.

## Usage

```
/research-methodology:research
/research-methodology:research <topic>
```

The optional argument seeds the starting topic — for example,
`/research-methodology:research "is Postgres LISTEN/NOTIFY safe under
heavy write load?"` — which the agent will use as a hint while still
asking the user to confirm the actual research question.

## What it produces

Every successful session leaves three things on disk:

1. **`research/<YYYY-MM-DD>-<slug>.md`** — the final report, with inline
   citations, confidence tags per claim, a disagreements section, and a
   sources table.
2. **`research/<YYYY-MM-DD>-<slug>.notes.md`** — the working notes
   (verbatim quotes, source credibility notes, cross-check log).
3. **A row in `AGENT.md`** under `## Research index`, pointing to the
   report. `AGENT.md` is created at the repo root if it does not yet
   exist.

The `AGENT.md` registration is the durable handoff: a future agent
opening the repo can scan one table and see what has already been
researched, when, and where the evidence lives.

## How it works

The wrapper:

1. Loads operating principles inline.
2. Points the agent at `PROCEDURE.md` (Phase 1 → Phase 6 + Validation).
3. Tells the agent to maintain working notes per
   `research-notes-template.md`.
4. Tells the agent to deliver the final artifact per
   `final-report-template.md`.
5. Requires the agent to update `AGENT.md` before declaring done.

The agent then runs the session phase by phase:

- Frame the question and confirm scope and stop conditions.
- Plan source kinds, preferred sources, and sources to distrust.
- Gather with verbatim quotes and `fact` / `inference` / `opinion` labels.
- Cross-check; mark each load-bearing claim `confirmed`,
  `single-source`, or `disputed`.
- Synthesize a self-contained report with inline citations.
- Persist to `research/` and register in `AGENT.md`.

## Guarantees

- **No invented facts.** Every claim traces to a source or is labeled an
  inference / opinion.
- **Cross-checking by default.** Load-bearing claims need ≥2 independent
  sources or are explicitly marked single-source.
- **Disconfirming evidence preserved.** Source disagreements are
  recorded, not silently resolved.
- **Durable handoff.** Results always land in `research/` and are
  indexed in `AGENT.md` — a research session that leaves no artifact is
  considered failed.
- **Read-mostly.** The command only writes the artifact, the notes
  file, and the `AGENT.md` index row. It does not modify other repo
  files.

## Use from other agents

`PROCEDURE.md` is consumer-neutral. To run the workflow with a non-Claude
client:

1. Have the agent read `PROCEDURE.md`, `research-notes-template.md`, and
   `final-report-template.md` as context.
2. Have the agent open with the scripted opening message.
3. Have the agent follow Phases 1–6 and the Validation checklist,
   including the `AGENT.md` registration step.

## License

Apache-2.0 (matches the parent repository).
