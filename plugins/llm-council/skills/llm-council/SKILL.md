---
name: llm-council
description: >-
  Convene an "LLM Council" — a panel of independent expert personas that deliberate on a hard
  question, decision, design, or piece of code. Each persona answers independently, they
  blind-rank each other's answers, and a chairman synthesizes one verdict with the disagreement
  made visible. Use when the user wants rigorous multi-perspective analysis, to stress-test a
  plan / design / claim / code, weigh trade-offs, choose between options, or pressure-test a
  decision. Also triggers on "convene the council", "ask the council", "/council", or any request
  for a panel, debate, or multiple independent perspectives. Not for simple lookups or quick edits.
---

# LLM Council

Convene a panel of independent expert personas to deliberate on a hard question and return one
well-reasoned verdict — with the disagreement surfaced instead of averaged away.

This skill adapts the **LLM Council** pattern (multiple models answer → blind-rank each other → a
chairman synthesizes) to run on **sub-agents, on any model**. The original got its diversity from
different model *providers*; this version gets it from four orthogonal *personas* — and you can
optionally assign a different model to each member for true ensemble diversity. It depends on no
pre-installed agents: every persona is bundled with this skill.

## When to use
- Hard decisions, design choices, "which approach should I take", trade-off analysis.
- Stress-testing a plan, architecture, claim, or piece of code before committing.
- Any question where one confident answer is risky and multiple angles add real value.

## When NOT to use
- Simple factual lookups, quick edits, mechanical tasks — a single agent is faster and cheaper.
- When you just need one fast answer; use `quick` mode or skip the council entirely.

## The council
Four members, each a deliberately non-overlapping lens. Their persona briefs live in the
`personas/` folder beside this file. When this skill runs as an installed plugin, that path is
`${CLAUDE_PLUGIN_ROOT}/skills/llm-council/personas/`; when it runs as a plain skill, it is
`personas/` relative to this `SKILL.md`. Resolve the directory this file lives in and read from there.

| File | Member | Lens |
| --- | --- | --- |
| `personas/architect.md` | Architect | systems thinking, correctness, long-term consequences |
| `personas/innovator.md` | Innovator | reframing, lateral alternatives, the option nobody mentions |
| `personas/skeptic.md` | Skeptic | failure modes, hidden assumptions, what breaks |
| `personas/pragmatist.md` | Pragmatist | what actually ships, effort vs. value |
| `personas/chairman.md` | Chairman | synthesizes the final verdict |

## Modes
- **full** (default) — all three stages including blind peer review. For high-stakes calls.
- **quick** — Stage 1 + Stage 3 only (skip the ranking round). Faster multi-perspective fusion.
- **ideate** — divergent: generate many genuinely different approaches and deliberately do NOT
  converge. For brainstorming and novel options.

If the invocation names a mode, use it; otherwise default to **full**.

---

## Execution protocol — FULL mode

You are the **orchestrator**. **Do not answer the question yourself** — your job is to run the
process and present the council's output.

### Stage 0 — Scope (briefly; do NOT solve)
- If the request concerns a codebase, locate the relevant files first (search/read) so members can
  be handed concrete paths. Gather pointers only.
- Write one clear **Council Question** that captures the ask plus the context/paths members need.

### Stage 1 — Independent answers (in parallel)
For each of the four members:
1. Read its persona brief from `personas/<member>.md`.
2. Spawn a sub-agent using your environment's sub-agent / Task tool. Use a generic agent type
   (e.g. `general-purpose`, or whatever default general sub-agent your environment offers). The
   sub-agent's prompt = **the full persona brief** + a line `MODE A — ANSWER` + the Council Question
   + any context/file paths.

Spawn all four **in a single batch** so they run concurrently. Wait for all. If a member fails,
continue with those that succeeded (minimum 2 — graceful degradation).

> **Maximize diversity (optional, recommended).** If your environment lets you choose a model per
> sub-agent, give the members *different* models — e.g. a strong reasoning model for the
> Architect and Skeptic, a fast model for the Pragmatist. This restores the original LLM Council's
> cross-model decorrelation (less-correlated errors = a stronger ensemble). If you cannot vary
> models, the persona differences alone still produce strong diversity.

> **No sub-agent tool available?** Fallback: adopt each persona brief in turn and produce that
> member's answer **inline, independently, and sequentially** — fully finish one member before
> starting the next, and do not let an earlier answer bias a later one. Keep the answers separate.

### Stage 2 — Blind peer review (in parallel)
1. Collect the four answers and **shuffle** them before labeling, so the label order does NOT match
   the spawn order. Assign `Response A`, `Response B`, …, and keep a **private** map
   (label → member). Never reveal this map to the reviewers — the review must stay blind.
2. Build one anonymized bundle:
   ```
   Response A:
   <full text of one answer>

   Response B:
   <full text of another answer>
   ...
   ```
3. Spawn the same four members again **in a single batch**, each in **MODE B — PEER REVIEW**, each
   receiving the full anonymized bundle + the Council Question. Each member sees its own answer
   anonymized among the others — that is intended. Each returns an evaluation that ends with a
   `FINAL RANKING:` block in the exact format its brief specifies.

### Stage 2.5 — Aggregate ranking (you)
Parse each member's `FINAL RANKING:` block. Convert labels to positions (1 = best). For each
response, average its position across all reviewers who ranked it. Sort ascending (lower average =
better). De-anonymize using your private map. This is the council's collective verdict on answer
quality.

### Stage 3 — Chairman synthesis
Read `personas/chairman.md`. Spawn one chairman sub-agent (or adopt the brief inline) with the full
**de-anonymized** picture:
- The Council Question
- STAGE 1: each member's answer, labeled by member name
- STAGE 2: each member's evaluation + ranking
- The aggregate ranking (member → average rank)

The chairman returns the single final verdict.

### Present the result
- **## 🏛️ Council Verdict** — the chairman's synthesis, verbatim. This is the headline answer.
- **## 📊 Aggregate ranking** — a compact table (rank · member · avg position · # of votes) and one
  line on what it reveals (clear winner? consensus? a real split?).
- **## 🔍 Transparency** — a one-line gist of each member's answer and where peers ranked it; reveal
  the anonymization map so the result can be audited; and **explicitly flag any point where members
  genuinely disagreed** and how the chairman adjudicated it. Never paper over disagreement —
  surfacing it is the whole point.

Keep the verdict front and center and the transparency section skimmable.

---

## QUICK mode
Stage 0 → Stage 1 (parallel independent answers) → Stage 3 (chairman). Skip Stages 2 and 2.5. Tell
the chairman there are no peer rankings this round — weigh the answers on their merits and flag
genuine disagreement. Present **## ⚡ Council Verdict** (chairman, verbatim) + **## 🔍 The four takes**
(one tight paragraph per member so the raw diversity behind the verdict is visible).

## IDEATE mode
Goal: **maximize the spread of good ideas; do NOT converge.** Spawn five generators **in parallel**,
varying the creative constraint per spawn so the ideas decorrelate (reuse the persona briefs as the
base, with these extra instructions):
- **Reframer** (innovator): "Is the stated problem the real problem? Solve the problem behind the problem."
- **10x'er** (innovator): "Assume 10× the budget / time / compute. What becomes possible that's off the table today?"
- **Constraint** (pragmatist): "Assume 1/10th the time and no new dependencies. What's the scrappy move that still wins?"
- **Cross-domain** (innovator): "Steal the winning pattern from a completely different field and apply it here."
- **Elegant wildcard** (architect): "What structural change makes the whole problem smaller or makes it disappear?"

Then **cluster, don't collapse**: dedupe near-identical ideas and group into 3–6 distinct
**directions**, each with a punchy name, the core idea in 1–2 sentences, why it's interesting, and
its main risk. Add 2–3 of your own **cross-pollinations** (fuse the best elements across directions).
Present **## 💡 Directions** (ordered by "most worth exploring") and **## 🔀 Cross-pollinations**, then
offer: *"Run the council in full mode on any direction to pressure-test it."* Do not pick a winner.

---

## Customization
- **Add a member:** drop a new `personas/<name>.md` (give it a Mode A and a Mode B using the same
  `FINAL RANKING:` format) and add it to the Stage 1 / Stage 2 member list.
- **Assign models per member:** vary the model at spawn time (see the Stage 1 note) for true
  multi-model diversity.
- **Tune a lens:** edit that member's persona brief — it is the single source of truth for that voice.
