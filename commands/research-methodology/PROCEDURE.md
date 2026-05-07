# Research Methodology — Procedure

Agent-neutral procedure for running a structured research session that
produces a cited, traceable artifact and registers that artifact in
`AGENT.md` so future agents can find it.

## Operating principles

1. **Question before sources.** Pin down the research question and what
   "good enough to act" looks like before opening any source.
2. **No invention.** Every claim in the final artifact must trace to a
   source or be explicitly labeled as the agent's inference.
3. **Cross-check load-bearing claims.** Any claim the user is likely to
   act on must be confirmed in at least two independent sources, or
   marked single-source.
4. **Cite inline.** Sources go next to the claim they support, not in a
   detached bibliography.
5. **Distinguish fact / inference / opinion.** Use those three labels in
   the notes; never blur them.
6. **Preserve disconfirming evidence.** If sources disagree, record the
   disagreement — do not silently pick a winner.
7. **Persist results.** The session must end with a file on disk and a
   pointer in `AGENT.md`. A research session that leaves no artifact has
   failed, even if the conversation was useful.

## Phase 1 — Frame the question

Goal: turn a vague topic into an answerable research question.

Confirm with the user, in this order:

1. The **research question** (one sentence, answerable).
2. The **decision or output** the answer feeds into (so scope matches
   need).
3. **Stop conditions** — what would make the research "done enough."
4. **Out of scope** — what the user explicitly does *not* want covered.
5. **Time budget** — rough effort ceiling (e.g., 30 min, 2 hours).

Write Phase 1 results into the research notes file under
`## Question and scope`.

## Phase 2 — Plan the sources

Before gathering, list:

- The **kinds of sources** that would actually answer this (primary
  docs, specs, source code, papers, vendor docs, regulator filings,
  benchmarks, etc.).
- Sources to **prefer** (authoritative, primary, current).
- Sources to **distrust by default** (SEO content farms, undated blog
  posts, AI-generated summaries, forums without citations).
- Known **biases or conflicts of interest** for likely sources.

Confirm the plan with the user before gathering. Adjust if the user
flags missing source types.

## Phase 3 — Gather

For each source consulted, record in the notes:

- Title, author/publisher, date, URL or local path.
- One-sentence description of what it covers.
- **Verbatim quotes** for any claim you intend to use, with location
  (page, section, line range, commit hash).
- A `fact` / `inference` / `opinion` label on each extracted claim.

Stop gathering when stop conditions are met or the time budget is
exhausted. Do not pad.

## Phase 4 — Cross-check and reconcile

For each load-bearing claim:

- Mark it `confirmed` (≥2 independent sources agree),
  `single-source`, or `disputed` (sources disagree).
- For `disputed`, record both positions with their sources and a
  one-line note on which is more credible and why.
- For `single-source`, note what would be needed to upgrade it.

Flag every claim that depends on a source the user said to distrust.

## Phase 5 — Synthesize

Write the final artifact using `final-report-template.md`. It must:

- Answer the research question directly in the first paragraph.
- Separate **what is known** from **what is inferred** from **what is
  still open**.
- Carry inline citations (`[#]` or `[name, year]`) to entries in the
  source list.
- Include a **confidence statement** per major claim (high / medium /
  low) tied to the cross-check status.
- List **open questions** the research could not resolve.

## Phase 6 — Persist and register

This phase is mandatory. The session is not complete until both steps
land on disk.

1. **Write the artifact.** Save the final report to
   `research/<YYYY-MM-DD>-<slug>.md` at the repository root (create the
   `research/` directory if missing). The slug is a short, kebab-case
   summary of the question. Save the working notes alongside as
   `research/<YYYY-MM-DD>-<slug>.notes.md`.

2. **Register in `AGENT.md`.** Open `AGENT.md` at the repository root.
   If it does not exist, create it with this skeleton:

   ```markdown
   # AGENT.md

   Notes for future agents working in this repository.

   ## Research index

   Prior research artifacts produced by `/research-methodology`. Each
   entry links to a self-contained report with inline citations.

   | Date | Question | Artifact | Status |
   | ---- | -------- | -------- | ------ |
   ```

   If `AGENT.md` exists but has no `## Research index` section, append
   that section (heading, intro paragraph, and table header) without
   modifying anything else.

   Append one row to the table:

   ```
   | YYYY-MM-DD | <one-line research question> | [report](research/<YYYY-MM-DD>-<slug>.md) | <complete | partial | superseded> |
   ```

   Use `partial` if stop conditions were not fully met or open questions
   remain that block the user's decision. Use `superseded` only when
   updating an older row that a new artifact replaces — leave the old
   row in place and add a `superseded by` note in its Status cell.

3. **Tell the user** the artifact path and that `AGENT.md` was updated.

## Validation checklist

Before declaring the session complete, confirm:

- [ ] The research question is recorded verbatim and was confirmed by the user.
- [ ] Every load-bearing claim is labeled `confirmed`, `single-source`, or `disputed`.
- [ ] Every claim in the final artifact carries an inline citation or an explicit `inference` / `opinion` label.
- [ ] Disconfirming evidence is preserved, not dropped.
- [ ] The artifact file exists at `research/<YYYY-MM-DD>-<slug>.md`.
- [ ] `AGENT.md` exists and has a row under `## Research index` pointing to the artifact.
- [ ] Open questions are listed in the artifact and not silently dropped.

If any item fails, fix it before reporting "done."
